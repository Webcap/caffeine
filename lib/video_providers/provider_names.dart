class ProviderNames {
  /// Supported providers - caffeine-api scraper (vixsrc) first, then others
  static List<VideoProvider> providers = [
    VideoProvider(fullName: 'VidLink', codeName: 'vidlink'),
    VideoProvider(fullName: 'Vixsrc', codeName: 'vixsrc'),
    VideoProvider(fullName: 'VidSrc.su', codeName: 'vidsrcsu'),
    VideoProvider(fullName: 'Goku', codeName: 'goku'),
    VideoProvider(fullName: 'Sflix', codeName: 'sflix'),
    VideoProvider(fullName: 'HiMovies', codeName: 'himovies'),
  ];

  static String get defaultPrecedenceString =>
      providers.map((p) => '${p.codeName}-${p.fullName}').join(' ');

  /// Providers shown in the server status screen (API /providers/status).
  /// Add new providers here and in caffeine-api scraper registry to include them in the status check.
  static const checkableCodeNames = {
    'vidlink',
    'vixsrc',
    'vidsrcsu',
    'goku',
    'sflix',
    'himovies',
    'animekai',
    'animepahe',
    'hianime',
  };
}

class VideoProvider {
  String fullName;
  String codeName;

  VideoProvider({required this.fullName, required this.codeName});
}
