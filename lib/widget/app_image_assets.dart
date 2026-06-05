import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:single_clik/constants/constant_color.dart';

import '../constants/constant_string.dart';

class AppImageAsset extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final bool isFile;
  final bool cache;

  const AppImageAsset({
    super.key,
    required this.image,
    this.fit,
    this.height,
    this.width,
    this.color,
    this.isFile = false,
    this.cache = false,
  });

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  @override
  Widget build(BuildContext context) {
    if ((image!.contains('http') || image!.contains('https')) && cache) {
      clearCache();
    }

    if (image!.contains('http') || image!.contains('https')) {
      return CachedNetworkImage(
        imageUrl: image!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        alignment: const Alignment(0, -0.5),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: ConstantColor.primary,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => AppImageAsset(
          image: ConstantString.noImgUrlPath,
          width: width,
          height: height,
          color: color,
          fit: fit,
          isFile: isFile,
        ),
      );
    }

    if (isFile) {
      final imageWidget = Image.file(
        File(image!),
        height: height,
        width: width,
        fit: fit,
      );
      return color != null
          ? ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: imageWidget,
      )
          : imageWidget;
    }

    if (image!.isEmpty || image!.split('.').last != 'svg') {
      final imageWidget = Image.asset(
        image!,
        height: height,
        width: width,
        fit: fit,
      );
      return color != null
          ? ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: imageWidget,
      )
          : imageWidget;
    } else {
      return SvgPicture.asset(
        image!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        colorFilter:
        color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }

  }

}