#!/usr/bin/env python3
# reconstruct_proto_from_pbjson.py
#
# Usage:
#   uv run python scripts/reconstruct_proto_from_pbjson.py lib/src/models/generated/MutationPayload.pbjson.dart -o proto/MutationPayload.proto
#
# Requires:
#   uv pip install -r scripts/requirements.txt

from __future__ import annotations

import argparse
import base64
import re
from collections import Counter
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    from google.protobuf import descriptor_pb2
except ModuleNotFoundError as e:
    raise SystemExit(
        "Missing dependency: protobuf\n"
        "Install with:\n"
        " uv venv\n"
        " uv pip install -r scripts/requirements.txt\n"
    ) from e


BLOCK_RE = re.compile(
    r"/// Descriptor for `(?P<proto_name>[^`]+)`\. Decode as a `google\.protobuf\.(?P<kind>[^`]+)`\.\s*"
    r"\nfinal \$typed_data\.Uint8List (?P<var>\w+)Descriptor\s*=\s*\$convert\.base64Decode\((?P<expr>.*?)\);\s*",
    re.S,
)

STRING_LIT_RE = re.compile(r"""(['"])(.*?)\1""", re.S)


PRIMITIVE_TYPES = {
    descriptor_pb2.FieldDescriptorProto.TYPE_DOUBLE: "double",
    descriptor_pb2.FieldDescriptorProto.TYPE_FLOAT: "float",
    descriptor_pb2.FieldDescriptorProto.TYPE_INT64: "int64",
    descriptor_pb2.FieldDescriptorProto.TYPE_UINT64: "uint64",
    descriptor_pb2.FieldDescriptorProto.TYPE_INT32: "int32",
    descriptor_pb2.FieldDescriptorProto.TYPE_FIXED64: "fixed64",
    descriptor_pb2.FieldDescriptorProto.TYPE_FIXED32: "fixed32",
    descriptor_pb2.FieldDescriptorProto.TYPE_BOOL: "bool",
    descriptor_pb2.FieldDescriptorProto.TYPE_STRING: "string",
    descriptor_pb2.FieldDescriptorProto.TYPE_BYTES: "bytes",
    descriptor_pb2.FieldDescriptorProto.TYPE_UINT32: "uint32",
    descriptor_pb2.FieldDescriptorProto.TYPE_SFIXED32: "sfixed32",
    descriptor_pb2.FieldDescriptorProto.TYPE_SFIXED64: "sfixed64",
    descriptor_pb2.FieldDescriptorProto.TYPE_SINT32: "sint32",
    descriptor_pb2.FieldDescriptorProto.TYPE_SINT64: "sint64",
}


def extract_concat_base64(expr: str) -> str:
    # Dart에서는 'aaaa' 'bbbb' 처럼 문자열 리터럴을 붙이면 컴파일 타임에 concat 됩니다.
    parts = [m.group(2) for m in STRING_LIT_RE.finditer(expr)]
    if not parts:
        raise ValueError(
            f"Could not find string literals inside base64Decode(...) expr: {expr[:120]}..."
        )
    return "".join(parts)


def parse_blocks(pbjson_text: str) -> List[Tuple[str, str, str, bytes]]:
    """
    Returns: list of (proto_name, kind, var_name, raw_bytes)
    kind: DescriptorProto | EnumDescriptorProto (others are ignored)
    """
    out: List[Tuple[str, str, str, bytes]] = []
    for m in BLOCK_RE.finditer(pbjson_text):
        proto_name = m.group("proto_name")
        kind = m.group("kind")
        var = m.group("var")
        expr = m.group("expr")
        b64 = extract_concat_base64(expr)
        raw = base64.b64decode(b64)
        out.append((proto_name, kind, var, raw))
    return out


def infer_package_from_type_names(
    messages: Dict[str, descriptor_pb2.DescriptorProto],
) -> Optional[str]:
    """
    Look at field.type_name values like:
      .com.microsoft.clarity.protomodels.mutationpayload.Color4f
    and infer the most common package prefix.
    """
    candidates: List[str] = []
    for msg in messages.values():
        for f in msg.field:
            if (
                f.type
                in (
                    descriptor_pb2.FieldDescriptorProto.TYPE_MESSAGE,
                    descriptor_pb2.FieldDescriptorProto.TYPE_ENUM,
                )
                and f.type_name
            ):
                full = f.type_name[1:] if f.type_name.startswith(".") else f.type_name
                parts = full.split(".")
                if len(parts) >= 2:
                    candidates.append(".".join(parts[:-1]))  # drop last symbol
    if not candidates:
        return None

    counts = Counter(candidates)
    best_freq = max(counts.values())
    best = [p for p, c in counts.items() if c == best_freq]
    # tie-break: prefer the longest (more specific) package
    best.sort(key=lambda s: (len(s.split(".")), len(s)), reverse=True)
    return best[0]


def normalize_type_name(type_name: str, package: Optional[str]) -> str:
    # keep leading '.' for external packages to keep meaning unambiguous
    if not type_name:
        return type_name
    raw = type_name
    full = raw[1:] if raw.startswith(".") else raw

    if package and full.startswith(package + "."):
        return full[len(package) + 1 :]  # strip "pkg."
    # external: keep fully-qualified
    return "." + full


def render_enum(enum: descriptor_pb2.EnumDescriptorProto) -> str:
    lines: List[str] = []
    lines.append(f"enum {enum.name} {{")
    if enum.options and enum.options.allow_alias:
        lines.append("  option allow_alias = true;")

    # reserved
    if enum.reserved_range:
        for rr in enum.reserved_range:
            if rr.end == rr.start + 1:
                lines.append(f"  reserved {rr.start};")
            else:
                lines.append(f"  reserved {rr.start} to {rr.end - 1};")
    for rn in enum.reserved_name:
        lines.append(f'  reserved "{rn}";')

    for v in enum.value:
        lines.append(f"  {v.name} = {v.number};")
    lines.append("}")
    return "\n".join(lines)


def render_message(msg: descriptor_pb2.DescriptorProto, package: Optional[str]) -> str:
    lines: List[str] = []
    lines.append(f"message {msg.name} {{")

    # reserved
    for rr in msg.reserved_range:
        if rr.end == rr.start + 1:
            lines.append(f"  reserved {rr.start};")
        else:
            lines.append(f"  reserved {rr.start} to {rr.end - 1};")
    for rn in msg.reserved_name:
        lines.append(f'  reserved "{rn}";')

    # oneofs (exclude synthetic proto3 optional oneofs)
    # NOTE: In proto3, optional fields are represented as a synthetic oneof in descriptors.
    synthetic_oneof_idx = set()
    for i, _oneof in enumerate(msg.oneof_decl):
        for f in msg.field:
            if f.proto3_optional and f.HasField("oneof_index") and f.oneof_index == i:
                synthetic_oneof_idx.add(i)

    oneof_fields: Dict[int, List[descriptor_pb2.FieldDescriptorProto]] = {}
    for f in msg.field:
        if f.HasField("oneof_index") and f.oneof_index not in synthetic_oneof_idx:
            oneof_fields.setdefault(f.oneof_index, []).append(f)

    # fields not in real oneofs
    normal_fields: List[descriptor_pb2.FieldDescriptorProto] = []
    for f in msg.field:
        if f.HasField("oneof_index") and f.oneof_index in oneof_fields:
            continue
        normal_fields.append(f)

    def render_field(f: descriptor_pb2.FieldDescriptorProto) -> str:
        label = ""
        if f.label == descriptor_pb2.FieldDescriptorProto.LABEL_REPEATED:
            label = "repeated "
        elif f.proto3_optional:
            label = "optional "

        if f.type in PRIMITIVE_TYPES:
            typ = PRIMITIVE_TYPES[f.type]
        elif f.type in (
            descriptor_pb2.FieldDescriptorProto.TYPE_MESSAGE,
            descriptor_pb2.FieldDescriptorProto.TYPE_ENUM,
        ):
            typ = normalize_type_name(f.type_name, package)
        else:
            # uncommon (groups etc.)
            typ = f.type_name or f"/*UNKNOWN_TYPE_{f.type}*/"

        opts: List[str] = []
        if f.options and f.options.deprecated:
            opts.append("deprecated=true")

        opt_str = f" [{', '.join(opts)}]" if opts else ""
        return f"  {label}{typ} {f.name} = {f.number}{opt_str};"

    for f in normal_fields:
        lines.append(render_field(f))

    # render real oneofs
    for idx, oneof in enumerate(msg.oneof_decl):
        if idx in synthetic_oneof_idx:
            continue
        if idx not in oneof_fields:
            continue
        lines.append(f"  oneof {oneof.name} {{")
        for f in oneof_fields[idx]:
            # oneof fields never use label/optional keyword
            if f.type in PRIMITIVE_TYPES:
                typ = PRIMITIVE_TYPES[f.type]
            else:
                typ = normalize_type_name(f.type_name, package)
            opts: List[str] = []
            if f.options and f.options.deprecated:
                opts.append("deprecated=true")
            opt_str = f" [{', '.join(opts)}]" if opts else ""
            lines.append(f"    {typ} {f.name} = {f.number}{opt_str};")
        lines.append("  }")

    lines.append("}")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pbjson_path", help="Path to *.pbjson.dart")
    ap.add_argument("-o", "--out", required=True, help="Output .proto path")
    ap.add_argument("--package", help="Override inferred package")
    ap.add_argument(
        "--no-package", action="store_true", help="Do not emit package line"
    )
    args = ap.parse_args()

    pbjson_path = Path(args.pbjson_path)
    src = pbjson_path.read_text(encoding="utf-8")

    blocks = parse_blocks(src)

    messages: Dict[str, descriptor_pb2.DescriptorProto] = {}
    enums: Dict[str, descriptor_pb2.EnumDescriptorProto] = {}

    ordered_items: List[Tuple[str, str]] = (
        []
    )  # (kind, name) where kind in {"enum","message"}

    for _proto_name, kind, _var, raw in blocks:
        if kind == "DescriptorProto":
            msg = descriptor_pb2.DescriptorProto()
            msg.ParseFromString(raw)
            messages[msg.name] = msg
            ordered_items.append(("message", msg.name))
        elif kind == "EnumDescriptorProto":
            enum = descriptor_pb2.EnumDescriptorProto()
            enum.ParseFromString(raw)
            enums[enum.name] = enum
            ordered_items.append(("enum", enum.name))
        else:
            # ignore unexpected kinds
            continue

    inferred = infer_package_from_type_names(messages)
    package = args.package or inferred

    out_lines: List[str] = []
    out_lines.append('syntax = "proto3";')
    out_lines.append("")

    if not args.no_package and package:
        out_lines.append(f"package {package};")
        out_lines.append("")

    seen = set()
    for kind, name in ordered_items:
        key = (kind, name)
        if key in seen:
            continue
        seen.add(key)

        if kind == "enum" and name in enums:
            out_lines.append(render_enum(enums[name]))
            out_lines.append("")
        elif kind == "message" and name in messages:
            out_lines.append(render_message(messages[name], package))
            out_lines.append("")

    Path(args.out).write_text("\n".join(out_lines).rstrip() + "\n", encoding="utf-8")
    print(
        f"✅ Wrote: {args.out} (package={package or '(none)'}, messages={len(messages)}, enums={len(enums)})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
