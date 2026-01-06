/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
library;

// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/utils/asset_utils.dart';
import 'package:clarity_flutter/src/utils/dev_utils.dart';

@immutable
// ignore: must_be_immutable "This class (or a class that this class inherits from) is marked as '@immutable', but one or more of its instance fields aren't final: NativeImageWrapper.hashCode, NativeImageWrapper._imageCloneRef, NativeImageWrapper._pictureRef"
class NativeImageWrapper {
  NativeImageWrapper({
    required this.hashCode,
    Image? image,
    Picture? picture,
    int pictureWidth = 0,
    int pictureHeight = 0,
    this.isFromPicture = false,
  }) : _imageCloneRef = image?.clone(),
       // Creating the image source from a clone, will dispose it after image is fetched the first time
       _pictureRef = picture,
       _weakImageRef = image == null ? null : WeakReference(image),
       _weakPictureRef = picture == null ? null : WeakReference(picture),
       _size = ImageSize(
         width: isFromPicture ? pictureWidth : image!.width,
         height: isFromPicture ? pictureHeight : image!.height,
       );

  NativeImageWrapper.fromImage(Image image) : this(hashCode: image.hashCode, image: image);

  NativeImageWrapper.fromPicture(Picture picture, int height, int width)
    : this(
        hashCode: picture.hashCode,
        picture: picture,
        pictureHeight: height,
        pictureWidth: width,
        isFromPicture: true,
      );

  @override
  int hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NativeImageWrapper && other.hashCode == hashCode;
  }

  Image? _imageCloneRef;
  Picture? _pictureRef;

  final WeakReference<Image>? _weakImageRef;
  final WeakReference<Picture>? _weakPictureRef;

  final ImageSize _size;
  final bool isFromPicture;

  Future<Image?> get imageData async {
    Image? returnedImage;
    if (isFromPicture) {
      returnedImage = await (_pictureRef ?? _weakPictureRef?.target)?.toImage(
        _size.width,
        _size.height,
      );
    } else {
      returnedImage = _imageCloneRef ?? _weakImageRef?.target;
    }
    return returnedImage;
  }

  Image? get imageDataSync {
    Image? returnedImage;
    if (isFromPicture) {
      returnedImage = (_pictureRef ?? _weakPictureRef?.target)?.toImageSync(
        _size.width,
        _size.height,
      );
    } else {
      returnedImage = _imageCloneRef ?? _weakImageRef?.target;
    }
    return returnedImage;
  }

  ImageSize get size => _size;

  bool isDisposed() {
    return _weakImageRef?.target == null && _weakPictureRef?.target == null;
  }

  bool get debugDisposed =>
      DebuggingUtils.isDebugMode &&
      ((_weakPictureRef?.target?.debugDisposed ?? false) || (_weakImageRef?.target?.debugDisposed ?? false));

  // Only valid if source is an Image not a Picture
  bool isCloneOf(NativeImageWrapper other) {
    return !isFromPicture &&
        !other.isFromPicture &&
        other.imageDataSync != null &&
        imageDataSync != null &&
        (imageDataSync == other.imageDataSync || imageDataSync!.isCloneOf(other.imageDataSync!));
  }

  // Free up any held memory
  void disposeData() {
    // Disposing _imageCloneRef since it is a clone we created
    _imageCloneRef?.dispose();
    _imageCloneRef = null;
    _pictureRef = null;
  }
}
