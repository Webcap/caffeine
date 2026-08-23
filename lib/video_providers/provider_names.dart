class ProviderNames {
  /// Supported active providers - fast multi scrapers ordered by empirical performance
  static List<VideoProvider> providers = [
    VideoProvider(fullName: 'Vixsrc', codeName: 'vixsrc'),
    VideoProvider(fullName: 'CoorenLabs', codeName: 'coorenlabs'),
    VideoProvider(fullName: 'VidZee', codeName: 'vidzee'),
    VideoProvider(fullName: 'VidFun', codeName: 'vidfun'),
  ];

  static String get defaultPrecedenceString =>
      providers.map((p) => '${p.codeName}-${p.fullName}').join(' ');

  /// Providers shown in the server status screen (API /providers/status).
  /// Add new providers here and in caffeine-api scraper registry to include them in the status check.
  static const checkableCodeNames = {
    'vixsrc',
    'coorenlabs',
    'vidzee',
    'vidfun',
    'vidlink',
    'vidsrcsu',
  };

  /// Headless browser scrapers disabled due to timeouts / Cloudflare blocks
  static const disabledCodeNames = {
    'vidlink',
    'vidsrcsu',
  };
}

class VideoProvider {
  String fullName;
  String codeName;

  VideoProvider({required this.fullName, required this.codeName});
}
