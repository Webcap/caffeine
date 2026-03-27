import 'package:caffiene/video_providers/regularVideoLinks.dart';

class ProviderLoaderResult {
  final List<RegularVideoLinks>? videoLinks;
  final List<RegularSubtitleLinks>? subtitleLinks;
  final bool success;
  final String? errorMessage;

  ProviderLoaderResult({
    this.videoLinks,
    this.subtitleLinks,
    this.success = false,
    this.errorMessage,
  });
}
