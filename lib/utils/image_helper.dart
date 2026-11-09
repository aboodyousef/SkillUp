import 'package:flutter/material.dart';

const _fallbackAsset = 'assets/course_images/general.png';

bool isAssetPath(String url) {
  return url.startsWith('assets/');
}

String resolveCoverPath(String path) {
  if (path.isEmpty) return _fallbackAsset;
  if (isAssetPath(path)) return path;
  return _fallbackAsset;
}

ImageProvider resolveImage(String url, {String fallbackAsset = _fallbackAsset}) {
  if (url.isEmpty) return AssetImage(fallbackAsset);
  if (isAssetPath(url)) return AssetImage(url);
  return NetworkImage(url);
}

Widget buildImageWidget(String url, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  double borderRadius = 0,
}) {
  final widget = isAssetPath(url)
      ? Image.asset(url, height: height, width: width, fit: fit)
      : Image.network(url, height: height, width: width, fit: fit,
          errorBuilder: (_, __, ___) => _placeholderBox(height, width),
        );

  if (borderRadius > 0) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: widget,
    );
  }
  return widget;
}

Widget buildCourseCover(String imageUrl, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  double borderRadius = 0,
}) {
  final url = imageUrl.isNotEmpty && isAssetPath(imageUrl) ? imageUrl : _fallbackAsset;

  final widget = Image.asset(
    url,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (_, __, ___) => _placeholderBox(height, width),
  );

  if (borderRadius > 0) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: widget,
    );
  }
  return widget;
}

Widget _placeholderBox(double? height, double? width) {
  return Container(
    height: height,
    width: width,
    color: Colors.grey.shade200,
    child: const Center(
      child: Icon(Icons.image, color: Colors.white70, size: 30),
    ),
  );
}
