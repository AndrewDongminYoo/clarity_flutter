// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/render_object_utils.dart';

void main() {
  group('RenderObjectUtils.isSafeToPaint', () {
    test('returns false when render object is not attached', () {
      final renderBox = RenderConstrainedBox(additionalConstraints: const BoxConstraints());
      expect(renderBox.isSafeToPaint(), isFalse);
    });

    test('returns false when RenderBox has no size', () {
      final renderBox = RenderConstrainedBox(additionalConstraints: const BoxConstraints());
      // Attach without layout to test hasSize check
      final pipelineOwner = PipelineOwner();
      renderBox.attach(pipelineOwner);
      expect(renderBox.isSafeToPaint(), isFalse);
      renderBox.dispose();
    });

    test('returns true when attached and has size', () {
      final renderBox = RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 100, height: 100),
      );
      final pipelineOwner = PipelineOwner();
      renderBox.attach(pipelineOwner);
      renderBox.layout(const BoxConstraints());
      expect(renderBox.isSafeToPaint(), isTrue);
      renderBox.dispose();
    });
  });

  group('RenderObjectUtils.isClickable', () {
    test('returns true when parent has onTap callback', () {
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints());
      final parent = RenderSemanticsAnnotations(
        properties: SemanticsProperties(onTap: () {}),
        child: child,
      );
      expect(child.isClickable(), isTrue);
      parent.dispose();
    });

    test('returns true when parent is marked as button', () {
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints());
      final parent = RenderSemanticsAnnotations(properties: const SemanticsProperties(button: true), child: child);
      expect(child.isClickable(), isTrue);
      parent.dispose();
    });

    test('returns false when parent has no clickable properties', () {
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints());
      final parent = RenderConstrainedBox(additionalConstraints: const BoxConstraints(), child: child);
      expect(child.isClickable(), isFalse);
      parent.dispose();
    });
  });

  group('RenderObjectUtils.globalPaintBounds', () {
    test('returns paint bounds when ancestor is null', () {
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 50, height: 50));
      final pipelineOwner = PipelineOwner();
      child.attach(pipelineOwner);
      child.layout(const BoxConstraints());

      // When ancestor is null and owner is available, getTransformTo returns identity
      final bounds = child.paintBounds;
      expect(bounds.width, 50);
      expect(bounds.height, 50);
      child.dispose();
    });

    test('transforms child bounds through parent chain with offsets', () {
      // Create a parent positioned at (100, 200)
      final parent = RenderPositionedBox(alignment: Alignment.topLeft);

      // Create a child with size 50x50
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 50, height: 50));

      final pipelineOwner = PipelineOwner();

      // Set up the parent-child relationship
      parent.child = child;
      parent.attach(pipelineOwner);

      // Layout parent with offset
      parent.layout(const BoxConstraints.tightFor(width: 300, height: 400));

      // Position the child at (100, 200) within parent
      final childParentData = child.parentData! as BoxParentData;
      childParentData.offset = const Offset(100, 200);

      child.layout(const BoxConstraints());

      // Get global bounds relative to parent
      final globalBounds = child.globalPaintBounds(parent);

      // Should be transformed by the offset
      expect(globalBounds.left, 100);
      expect(globalBounds.top, 200);
      expect(globalBounds.width, 50);
      expect(globalBounds.height, 50);

      parent.dispose();
    });

    test('transforms through multiple parent levels', () {
      // Grandparent
      final grandparent = RenderPositionedBox(alignment: Alignment.topLeft);

      // Parent
      final parent = RenderPositionedBox(alignment: Alignment.topLeft);

      // Child
      final child = RenderConstrainedBox(additionalConstraints: const BoxConstraints.tightFor(width: 30, height: 40));

      final pipelineOwner = PipelineOwner();

      // Set up hierarchy: grandparent -> parent -> child
      grandparent.child = parent;
      parent.child = child;
      grandparent.attach(pipelineOwner);

      grandparent.layout(const BoxConstraints.tightFor(width: 500, height: 600));

      // Position parent at (50, 60) within grandparent
      final parentParentData = parent.parentData! as BoxParentData;
      parentParentData.offset = const Offset(50, 60);

      parent.layout(const BoxConstraints.tightFor(width: 400, height: 500));

      // Position child at (10, 20) within parent
      final childParentData = child.parentData! as BoxParentData;
      childParentData.offset = const Offset(10, 20);

      child.layout(const BoxConstraints());

      // Get global bounds relative to grandparent (cumulative offset: 50+10, 60+20)
      final globalBounds = child.globalPaintBounds(grandparent);

      expect(globalBounds.left, 60); // 50 + 10
      expect(globalBounds.top, 80); // 60 + 20
      expect(globalBounds.width, 30);
      expect(globalBounds.height, 40);

      grandparent.dispose();
    });
  });
}
