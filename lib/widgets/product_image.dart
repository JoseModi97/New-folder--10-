import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

typedef ProductImagePlaceholderBuilder = Widget Function(BuildContext context);
typedef ProductImageErrorBuilder = Widget Function(BuildContext context, Object error);

class ProductImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final ProductImagePlaceholderBuilder? placeholderBuilder;
  final ProductImageErrorBuilder? errorBuilder;

  const ProductImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  String get _normalized => image.trim();

  bool get _isRemote => _normalized.toLowerCase().startsWith('http');

  String get _assetPath {
    final sanitized = _normalized.replaceAll('\\', '/');
    if (sanitized.startsWith('assets/') || sanitized.startsWith('Sale/')) {
      return sanitized;
    }
    if (sanitized.startsWith('/')) {
      return 'Sale/${sanitized.substring(1)}';
    }
    if (sanitized.startsWith('images/')) {
      return 'Sale/$sanitized';
    }
    return 'Sale/$sanitized';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemote) {
      return CachedNetworkImage(
        imageUrl: _normalized,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholder: placeholderBuilder != null ? (context, _) => placeholderBuilder!(context) : null,
        errorWidget: (context, _, error) =>
            errorBuilder != null ? errorBuilder!(context, error) : const Icon(Icons.error),
      );
    }

    return Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) =>
          errorBuilder != null ? errorBuilder!(context, error) : const Icon(Icons.error),
    );
  }
}
