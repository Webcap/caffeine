import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache size presets (2x for retina) to limit decoded image memory.
enum CachePreset {
  poster, // ~150x225 display -> 300x450
  posterLarge, // ~300x450 display -> 600x900
  profile, // ~80x120 display -> 160x240
  logo, // ~100x100 display -> 200x200
  backdrop, // ~400x225 display -> 800x450
}

class PresetSize {
  const PresetSize(this.width, this.height);
  final int width;
  final int height;
}

extension CachePresetSizes on CachePreset {
  PresetSize get sizes {
    switch (this) {
      case CachePreset.poster:
        return const PresetSize(300, 450);
      case CachePreset.posterLarge:
        return const PresetSize(600, 900);
      case CachePreset.profile:
        return const PresetSize(160, 240);
      case CachePreset.logo:
        return const PresetSize(200, 200);
      case CachePreset.backdrop:
        return const PresetSize(800, 450);
    }
  }
}

/// CachedNetworkImage wrapper with memory limits to reduce RAM usage.
class CachedPosterImage extends StatelessWidget {
  const CachedPosterImage({
    super.key,
    required this.imageUrl,
    required this.themeMode,
    required this.placeholder,
    required this.errorWidget,
    this.cacheManager,
    this.preset = CachePreset.poster,
    this.imageBuilder,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final String themeMode;
  final Widget Function(BuildContext, String) placeholder;
  final Widget Function(BuildContext, String, dynamic) errorWidget;
  final CacheManager? cacheManager;
  final CachePreset preset;
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final size = preset.sizes;
    return CachedNetworkImage(
      cacheManager: cacheManager,
      imageUrl: imageUrl,
      memCacheWidth: size.width,
      memCacheHeight: size.height,
      fadeOutDuration: const Duration(milliseconds: 300),
      fadeOutCurve: Curves.easeOut,
      fadeInDuration: const Duration(milliseconds: 700),
      fadeInCurve: Curves.easeIn,
      imageBuilder: imageBuilder ??
          (context, imageProvider) => Image(
                image: imageProvider,
                fit: fit,
              ),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
