/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
// ignore_for_file: one_member_abstracts

library;

abstract class IProtoModel<T> {
  T toProtobufInstance();
}

abstract class IProtoPageEventModel<T> {
  T toProtobufInstance(int pageTimestamp);
}
