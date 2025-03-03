import 'dart:io';
import 'package:booksum/modules/core/models/enum.dart';
import 'package:booksum/modules/core/widgets/common_style.dart';
import 'package:booksum/modules/core/widgets/default_button.dart';
import 'package:booksum/modules/core/widgets/default_text_field.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DefaultImageField extends StatelessWidget {
  final String imagePath;
  final ui.Image? image;
  final double? height;
  final double? width;
  final ImageFileType imageFileType;
  final BorderRadius? borderRadius;

  const DefaultImageField({
    super.key,
    required this.imagePath,
    this.image,
    this.height,
    this.width,
    this.imageFileType = ImageFileType.file,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Image imageWidget = Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      height: height,
      width: width,
    );
    RawImage? rawImageWidget;

    switch (imageFileType) {
      case ImageFileType.file:
        imageWidget = Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          height: height,
          width: width,
        );
        break;
      case ImageFileType.network:
        imageWidget = Image.network(
          imagePath,
          fit: BoxFit.cover,
          height: height,
          width: width,
        );
        break;
      case ImageFileType.asset:
        imageWidget = Image.asset(
          imagePath,
          fit: BoxFit.cover,
          height: height,
          width: width,
        );
        break;
      case ImageFileType.memory:
        // imageWidget = Image.memory(
        //   File(widget.imageFilePath).readAsBytesSync(),
        //   fit: BoxFit.cover,
        //   height: widget.height,
        //   width: widget.width,
        // );
        break;
      case ImageFileType.image:
        rawImageWidget = RawImage(
          image: image!,
          fit: BoxFit.cover,
          height: height,
          width: width,
        );
        break;
    }

    Image defaultImageWidget = Image.asset(
      imagePath.isNotEmpty
          ? imagePath
          : "assets/images/book-cover-placeholder.jpg",
      fit: BoxFit.cover,
      height: height,
      width: width,
    );

    bool isImageProvided = imagePath.isNotEmpty || image != null;

    Widget imageField = ClipRRect(
      borderRadius: borderRadius ?? defaultBorderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (isImageProvided) (image != null) ? rawImageWidget! : imageWidget,
          if (!isImageProvided) defaultImageWidget,
          // if (isEdit)
          //   Container(
          //     decoration: BoxDecoration(
          //       color: Theme.of(context)
          //           .colorScheme
          //           .surfaceDim
          //           .withOpacity(isImageProvided ? .2 : 1),
          //       borderRadius: defaultBorderRadius,
          //     ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         if (!isImageProvided)
          //           DefaultTextField(
          //             text: "Cover",
          //             isEdit: false,
          //             fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         const SizedBox(
          //           height: 6,
          //         ),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             DefaultButton(
          //               icon: const Icon(Icons.file_upload_outlined, size: 24),
          //               onTap: onUpload,
          //               showShadow: false,
          //             ),
          //             if (isImageProvided)
          //               const SizedBox(
          //                 height: 16,
          //                 width: 16,
          //               ),
          //             if (isImageProvided)
          //               DefaultButton(
          //                 icon: const Icon(
          //                   Icons.close_rounded,
          //                   size: 24,
          //                 ),
          //                 onTap: onClear,
          //                 showShadow: false,
          //               ),
          //           ],
          //         )
          //       ],
          //     ),
          //   ),
        ],
      ),
    );

    return imageField; 
  }
}
