import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/controller/recently_watched_database_controller.dart';
import 'package:reelriot/models/sub_languages.dart';
import 'package:reelriot/models/external_subtitles.dart';
import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/functions/video_utils.dart';
import 'package:reelriot/models/movie_stream_metadata.dart';
import 'package:reelriot/models/provider_video_source.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/models/tv_stream_metadata.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/player/widgets/cast_bottom_sheet.dart';
import 'package:reelriot/services/analytics_service.dart';
import 'package:reelriot/services/cast_service.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/video_providers/provider_loader.dart';
import 'package:reelriot/video_providers/provider_names.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/services/player/caffeine_player_controller.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/screens/player/widgets/language_picker_sheet.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/screens/player/widgets/subtitle_selection_sheet.dart';
import 'package:reelriot/screens/player/widgets/glass_player_controls.dart';

class Player extends StatefulWidget {
  final Map<String, String> sources;
  final List<CaffeinePlayerSubtitlesSource> subs;
  final List<Color> colors;
  final SettingsProvider settings;
  final MovieStreamMetadata? movieMetadata;
  final TVStreamMetadata? tvMetadata;
  final MediaType? mediaType;
  final String? subtitleStyle;
  final List<VideoProvider>? availableProviders;
  final String? currentProviderCode;
  final Map<String, String>? headers;

  const Player(
      {required this.sources,
      required this.subs,
      required this.colors,
      required this.settings,
      this.movieMetadata,
      this.tvMetadata,
      required this.mediaType,
      required this.subtitleStyle,
      this.availableProviders,
      this.currentProviderCode,
      this.headers,
      super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with WidgetsBindingObserver {
  late CaffeinePlayerController _betterPlayerController;
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();
  int duration = 0;

  final GlobalKey _betterPlayerKey = GlobalKey();

  int totalMinutesWatched = 0;
  bool isVideoPaused = false;

  int playbackDurationInSeconds = 0;
  Timer? _durationTimer;
  // ignore: unused_field
  Timer? _resetTimer;

  late SettingsProvider settings;

  Map<String, String> _currentSources = {};
  List<CaffeinePlayerSubtitlesSource> _currentSubs = [];
  CaffeinePlayerSubtitlesSource? _currentSubtitleSource;
  bool _isSearchingSubtitles = false;
  final int _retryProviderIndex = 0;
  bool _isRetrying = false;

  DateTime? _loadStartTime;
  DateTime? _bufferingStartTime;

  Timer? _periodicSaveTimer;

  @override
  void initState() {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Periodic save every 30 seconds
    _periodicSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_betterPlayerController.isVideoInitialized() == true) {
        final elapsed =
            _betterPlayerController.player.state.position.inMilliseconds;
        if (widget.mediaType == MediaType.movie) {
          insertRecentMovieData(manualElapsed: elapsed);
        } else {
          insertRecentEpisodeData(manualElapsed: elapsed);
        }
      }
    });

    // Force landscape and keep screen on
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable();

    _currentSources = Map.from(widget.sources);
    _currentSubs = List.from(widget.subs);

    String keyToFind = widget.settings.defaultVideoResolution == 0
        ? 'auto'
        : widget.settings.defaultVideoResolution.toString();
    String? link;

    if (widget.sources.entries
        .where((entry) => entry.key == keyToFind)
        .isNotEmpty) {
      link = widget.sources.entries
          .where((entry) => entry.key == keyToFind)
          .map((entry) => entry.value)
          .first;
    } else if (widget.sources.isNotEmpty) {
      link = widget.sources.values.first;
    }

    _betterPlayerController = CaffeinePlayerController();
    // Set data source with initial seek if resuming
    final initialElapsed = widget.mediaType == MediaType.movie
        ? (widget.movieMetadata?.elapsed ?? 0)
        : (widget.tvMetadata?.elapsed ?? 0);

    _betterPlayerController.setDataSource(
      link ?? '',
      headers: widget.headers,
      subtitles: widget.subs,
      startAt: Duration(milliseconds: initialElapsed),
    );

    _loadStartTime = DateTime.now();
    AnalyticsService.instance.trackQoSEvent('Playback Attempt', {
      'type': widget.mediaType == MediaType.movie ? 'movie' : 'tv_show',
      'id': widget.mediaType == MediaType.movie
          ? widget.movieMetadata?.movieId
          : widget.tvMetadata?.tvId,
      'name': widget.mediaType == MediaType.movie
          ? widget.movieMetadata?.movieName
          : widget.tvMetadata?.seriesName,
    });

    _betterPlayerController.addEventsListener((event) {
      if (event.type == CaffeinePlayerEventType.error) {
        _tryNextProvider();
      }
      if (event.type == CaffeinePlayerEventType.play) {
        startDurationTimer();
      }
      if (event.type == CaffeinePlayerEventType.pause) {
        pauseDurationTimer();
      }
      
      // Update duration when it becomes available or changes
      if (mounted) {
        final newDuration = _betterPlayerController.duration.inMilliseconds;
        if (newDuration > 0 && newDuration != duration) {
          setState(() {
            duration = newDuration;
          });
        }
      }
    });

    AnalyticsService.instance.trackEvent('Playback Started', {
      'type': widget.mediaType == MediaType.movie ? 'movie' : 'tv_show',
      'id': widget.mediaType == MediaType.movie
          ? widget.movieMetadata?.movieId
          : widget.tvMetadata?.tvId,
      'name': widget.mediaType == MediaType.movie
          ? widget.movieMetadata?.movieName
          : widget.tvMetadata?.seriesName,
      'episode': widget.tvMetadata?.episodeName,
      'season': widget.tvMetadata?.seasonNumber,
      'provider': widget.currentProviderCode,
    });

    // Auto-discover subtitles after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _autoDiscoverSubtitles();
      }
    });
  }

  Future<void> _autoDiscoverSubtitles() async {
    // MediaKit handle auto discovery differently (often via mpv)
    // For now, we manually loaded subs in initState.
  }

  void startDurationTimer() {
    if (_durationTimer == null) {
      _durationTimer =
          Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        setState(() {
          playbackDurationInSeconds++;
        });
      });

      _resetTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
        resetDurationTimer();
      });
    }
  }

  void pauseDurationTimer() {
    updateAndLogTotalStreamingDuration(playbackDurationInSeconds);
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void resetDurationTimer() {
    setState(() {
      playbackDurationInSeconds = 0;
    });
  }

  Future<void> _tryNextProvider() async {
    debugPrint('[Player] 🔄 _tryNextProvider called. Current: ${widget.currentProviderCode}');
    if (_isRetrying ||
        widget.availableProviders == null ||
        widget.currentProviderCode == null) {
      debugPrint('[Player] 🔄 Retry aborted: _isRetrying=$_isRetrying, availableProviders=${widget.availableProviders?.length}, currentProviderCode=${widget.currentProviderCode}');
      return;
    }

    final providers = widget.availableProviders!;
    final currentIndex =
        providers.indexWhere((p) => p.codeName == widget.currentProviderCode);
    if (currentIndex < 0 || currentIndex >= providers.length - 1) {
      return;
    }

    _isRetrying = true;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final language = settings.defaultAudioLanguage;
    final country = settings.defaultCountry;
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final route = appDep.fetchRoute.toLowerCase() == 'tmdb'
        ? StreamRoute.tmDB
        : StreamRoute.flixHQ;

    for (int i = currentIndex + 1; i < providers.length; i++) {
      ProviderLoaderResult result;
      if (widget.mediaType == MediaType.movie && widget.movieMetadata != null) {
        result = await ProviderLoader.loadMovieFromProvider(
          providerCode: providers[i].codeName,
          route: route,
          movieId: widget.movieMetadata!.movieId!,
          movieName: widget.movieMetadata!.movieName ?? '',
          releaseYear: widget.movieMetadata!.releaseYear?.toString(),
          consumetUrl: appDep.consumetUrl,
          newFlixHQUrl: appDep.newFlixHQUrl,
          flixApiUrl: appDep.flixApiUrl,
          newFlixhqServer: appDep.newFlixhqServer,
          streamingServerFlixHQ: appDep.streamingServerFlixHQ,
          streamingServerDCVA: appDep.streamingServerDCVA,
          streamingServerZoro: appDep.streamingServerZoro,
          gokuServer: appDep.gokuServer,
          sflixServer: appDep.sflixServer,
          himoviesServer: appDep.himoviesServer,
          animekaiServer: appDep.animekaiServer,
          hianimeServer: appDep.hianimeServer,
          language: language,
          country: country,
        );
      } else if (widget.mediaType == MediaType.tvShow &&
          widget.tvMetadata != null) {
        result = await ProviderLoader.loadTVFromProvider(
          providerCode: providers[i].codeName,
          route: route,
          tvId: widget.tvMetadata!.tvId!,
          seriesName: widget.tvMetadata!.seriesName ?? '',
          seasonNumber: widget.tvMetadata!.seasonNumber ?? 1,
          episodeNumber: widget.tvMetadata!.episodeNumber ?? 1,
          consumetUrl: appDep.consumetUrl,
          newFlixHQUrl: appDep.newFlixHQUrl,
          flixApiUrl: appDep.flixApiUrl,
          newFlixhqServer: appDep.newFlixhqServer,
          streamingServerFlixHQ: appDep.streamingServerFlixHQ,
          streamingServerDCVA: appDep.streamingServerDCVA,
          streamingServerZoro: appDep.streamingServerZoro,
          gokuServer: appDep.gokuServer,
          sflixServer: appDep.sflixServer,
          himoviesServer: appDep.himoviesServer,
          animekaiServer: appDep.animekaiServer,
          hianimeServer: appDep.hianimeServer,
          language: language,
          country: country,
        );
      } else {
        break;
      }

      if (result.success &&
          result.videoLinks != null &&
          result.videoLinks!.isNotEmpty &&
          mounted) {
        final newSources = VideoUtils.reverseVideoQualityMap(
          VideoUtils.convertVideoLinksToMap(result.videoLinks!),
        );
        _currentSources = newSources;
        if (result.subtitleLinks != null && result.subtitleLinks!.isNotEmpty) {
          _currentSubs = result.subtitleLinks!
              .map((s) => CaffeinePlayerSubtitlesSource(
                    name: s.language ?? 'Unknown',
                    urls: [s.url ?? ''],
                  ))
              .toList();
        }

        final keyToFind = widget.settings.defaultVideoResolution == 0
            ? 'auto'
            : widget.settings.defaultVideoResolution.toString();
        final link = newSources[keyToFind] ?? newSources.values.first;

        final elapsed = await _currentElapsedMilliseconds;
        _betterPlayerController.setDataSource(
          link,
          headers: VideoUtils.extractHeaders(result.videoLinks!),
          subtitles: _currentSubs,
          startAt: Duration(milliseconds: elapsed),
        );
        _selectPreferredAudioTrack();
        if (mounted) {
          setState(() {});
        }
        break;
      }
    }
    _isRetrying = false;
  }

  void _selectPreferredAudioTrack() {
    if (!mounted) return;
    final tracks = _betterPlayerController.audioTracks;
    if (tracks.isEmpty) {
      debugPrint('[Player] 🎧 No audio tracks available yet.');
      return;
    }

    final preferred = settings.defaultAudioLanguage.toLowerCase();
    debugPrint('[Player] 🎧 Attempting to select audio track: $preferred');

    for (final track in tracks) {
      final lang = track.language?.toLowerCase() ?? '';
      final label = track.title?.toLowerCase() ?? '';
      debugPrint('[Player]   - Track: lang="$lang", label="$label"');

      final isMatch = lang == preferred ||
          lang.startsWith(preferred) ||
          label.startsWith(preferred) ||
          label.contains(preferred) ||
          (preferred == 'en' && label.contains('english'));

      if (isMatch) {
        debugPrint('[Player] ✅ Match found! Selecting track: $label ($lang)');
        _betterPlayerController.setAudioTrack(track);
        return;
      }
    }

    // Secondary fallback: if default audio language was used but not found, try app language
    if (settings.defaultAudioLanguage != settings.appLanguage) {
      final fallback = settings.appLanguage.toLowerCase();
      debugPrint('[Player] 🎧 Fallback to app language: $fallback');
      for (final track in tracks) {
        final lang = track.language?.toLowerCase() ?? '';
        final label = track.title?.toLowerCase() ?? '';

        final isMatch = lang == fallback ||
            lang.startsWith(fallback) ||
            label.startsWith(fallback) ||
            label.contains(fallback) ||
            (fallback == 'en' && label.contains('english'));

        if (isMatch) {
          debugPrint(
              '[Player] ✅ Fallback match found! Selecting: $label ($lang)');
          _betterPlayerController.setAudioTrack(track);
          return;
        }
      }
    }
  }

  Future<void> insertRecentMovieData({int? manualElapsed}) async {
    if (!mounted || duration <= 0) return;

    int elapsed = manualElapsed ??
        _betterPlayerController.player.state.position.inMilliseconds;

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedMoviesController
        .contain(widget.movieMetadata!.movieId!);

    if (!mounted) return;
    final prv = Provider.of<RecentProvider>(context, listen: false);

    RecentMovie rMov = RecentMovie(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.movieMetadata?.movieId ?? 0,
        posterPath: widget.movieMetadata?.posterPath ?? '',
        releaseYear: widget.movieMetadata?.releaseYear ?? 0,
        remaining: remaining,
        title: widget.movieMetadata?.movieName ?? '',
        backdropPath: widget.movieMetadata?.backdropPath ?? '');

    double percentage = 0.0;
    if (duration > 0) {
      percentage = (elapsed / duration) * 100;
    }

    if (!isBookmarked) {
      await prv.addMovie(rMov);
    } else {
      if (percentage <= 90) {
        await prv.updateMovie(rMov, widget.movieMetadata!.movieId!);
      } else {
        final completed = RecentMovie(
          dateTime: dt,
          elapsed: duration,
          id: widget.movieMetadata!.movieId!,
          posterPath: widget.movieMetadata!.posterPath!,
          releaseYear: widget.movieMetadata!.releaseYear!,
          remaining: 0,
          title: widget.movieMetadata!.movieName,
          backdropPath: widget.movieMetadata!.backdropPath!,
        );
        await prv.updateMovie(completed, widget.movieMetadata!.movieId!);
      }
    }
  }

  Future<void> insertRecentEpisodeData({int? manualElapsed}) async {
    if (!mounted || duration <= 0) return;

    int elapsed = manualElapsed ??
        _betterPlayerController.player.state.position.inMilliseconds;

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedEpisodeController
        .contain(widget.tvMetadata!.episodeId!);

    if (!mounted) return;
    final prv = Provider.of<RecentProvider>(context, listen: false);

    RecentEpisode rEpisode = RecentEpisode(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.tvMetadata?.episodeId ?? 0,
        posterPath: widget.tvMetadata?.posterPath ?? '',
        remaining: remaining,
        seriesName: widget.tvMetadata?.seriesName ?? '',
        episodeName: widget.tvMetadata?.episodeName ?? '',
        episodeNum: widget.tvMetadata?.episodeNumber ?? 0,
        seasonNum: widget.tvMetadata?.seasonNumber ?? 0,
        seriesId: widget.tvMetadata?.tvId ?? 0);

    double percentage = 0.0;
    if (duration > 0) {
      percentage = (elapsed / duration) * 100;
    }

    if (!isBookmarked) {
      await prv.addEpisode(rEpisode);
    } else {
      if (percentage <= 90) {
        await prv.updateEpisode(
            rEpisode,
            widget.tvMetadata!.episodeId!,
            widget.tvMetadata!.episodeNumber!,
            widget.tvMetadata!.seasonNumber!);
      } else {
        final completed = RecentEpisode(
            dateTime: dt,
            elapsed: duration,
            id: widget.tvMetadata!.episodeId!,
            posterPath: widget.tvMetadata!.posterPath!,
            remaining: 0,
            seriesName: widget.tvMetadata!.seriesName!,
            episodeName: widget.tvMetadata!.episodeName!,
            episodeNum: widget.tvMetadata!.episodeNumber!,
            seasonNum: widget.tvMetadata!.seasonNumber!,
            seriesId: widget.tvMetadata!.tvId!);
        await prv.updateEpisode(
            completed,
            widget.tvMetadata!.episodeId!,
            widget.tvMetadata!.episodeNumber!,
            widget.tvMetadata!.seasonNumber!);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final isInBackground = (state == AppLifecycleState.paused) ||
        (state == AppLifecycleState.inactive);
    final isResuming = state == AppLifecycleState.resumed;

    if (isInBackground) {
      if (_betterPlayerController.isVideoInitialized() == true) {
        widget.mediaType == MediaType.movie
            ? insertRecentMovieData()
            : insertRecentEpisodeData();
      }
    } else if (isResuming) {
      // If we are resuming and casting, check if the cast finished while away.
      // CastService is a ChangeNotifier, so it should trigger a build automatically
      // if it received a message while in the background (if proxy/socket stayed alive).
      // If not, it will update on next status message.
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Save progress before disposing
    if (_betterPlayerController.isVideoInitialized() == true) {
      final elapsed =
          _betterPlayerController.player.state.position.inMilliseconds;
      if (widget.mediaType == MediaType.movie) {
        insertRecentMovieData(manualElapsed: elapsed);
      } else {
        insertRecentEpisodeData(manualElapsed: elapsed);
      }
    }

    _durationTimer?.cancel();
    _resetTimer?.cancel();
    _periodicSaveTimer?.cancel();
    _betterPlayerController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    // Restore orientations and disable wakelock
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.disable();

    super.dispose();
  }

  String get _currentStreamUrl {
    final sources =
        _currentSources.isNotEmpty ? _currentSources : widget.sources;
    final keyToFind = widget.settings.defaultVideoResolution == 0
        ? 'auto'
        : widget.settings.defaultVideoResolution.toString();
    return sources.isNotEmpty
        ? (sources[keyToFind] ?? sources.values.first)
        : '';
  }

  String get _castTitle {
    if (widget.mediaType == MediaType.movie && widget.movieMetadata != null) {
      final year = widget.movieMetadata!.releaseYear;
      return '${widget.movieMetadata!.movieName ?? ''}${year != null ? ' ($year)' : ''}';
    }
    if (widget.tvMetadata != null) {
      return '${widget.tvMetadata!.seriesName ?? ''} – ${widget.tvMetadata!.episodeName ?? ''}';
    }
    return '';
  }

  bool _wasCasting = false;

  Future<void> _resumeFromCast(int positionSeconds) async {
    if (positionSeconds <= 0) {
      _betterPlayerController.play();
      return;
    }
    // Brief delay so the local player is visible and ready before seeking.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    final initialized = _betterPlayerController.isVideoInitialized();
    if (initialized) {
      await _betterPlayerController.seekTo(Duration(seconds: positionSeconds));
    }
    _betterPlayerController.play();
  }

  String? get _castPosterUrl {
    final posterPath = widget.mediaType == MediaType.movie
        ? widget.movieMetadata?.posterPath
        : widget.tvMetadata?.posterPath;
    if (posterPath == null || posterPath.isEmpty) return null;
    return '$tmdbBaseImageUrl/w500$posterPath';
  }

  Future<int> get _currentElapsedMilliseconds async {
    if (!(_betterPlayerController.isVideoInitialized() == true)) return 0;
    return _betterPlayerController.player.state.position.inMilliseconds;
  }

  void _openCastSheet() async {
    if (!mounted) return;
    if (_betterPlayerController.isPlaying()) {
      _betterPlayerController.pause();
    }
    final elapsed = await _currentElapsedMilliseconds;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CastBottomSheet(
        streamUrl: _currentStreamUrl,
        title: _castTitle,
        posterUrl: _castPosterUrl,
        elapsedSeconds: elapsed ~/ 1000,
        headers: widget.headers,
      ),
    );
  }

  Future<void> _openSubtitleSelectionSheet() async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        return SubtitleSelectionSheet(
          subtitles: _currentSubs,
          selectedSubtitle: _currentSubtitleSource,
          controller: _betterPlayerController,
          isLoading: _isSearchingSubtitles,
          onSubtitleSelected: (sub) {
            if (mounted) {
              setState(() {
                _currentSubtitleSource = sub;
              });
            }
            if (sub == null) {
              _betterPlayerController.player
                  .setSubtitleTrack(mk.SubtitleTrack.no());
            } else {
              _betterPlayerController.setSubtitleSource(sub);
            }
          },
          onSearchPressed: () async {
            final langCode = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LanguagePickerSheet(),
            );

            if (langCode != null) {
              if (mounted) {
                setSheetState(() {
                  _isSearchingSubtitles = true;
                });
              }
              try {
                await _searchMoreSubtitles(langCode);
              } finally {
                if (mounted) {
                  setSheetState(() {
                    _isSearchingSubtitles = false;
                  });
                }
              }
            }
          },
        );
      }),
    );
  }

  Future<void> _searchMoreSubtitles(String langCode) async {
    try {
      final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
      final searchUrl = widget.mediaType == MediaType.movie
          ? Endpoints.searchExternalMovieSubtitles(
              widget.movieMetadata!.movieId!, langCode)
          : Endpoints.searchExternalEpisodeSubtitles(
              widget.tvMetadata!.tvId!,
              widget.tvMetadata!.episodeNumber!,
              widget.tvMetadata!.seasonNumber!,
              langCode,
            );

      final subtitleDataList = await getExternalSubtitle(
        searchUrl,
        appDep.opensubtitlesKey,
      );

      if (subtitleDataList.isNotEmpty) {
        final List<CaffeinePlayerSubtitlesSource> newExternalSubs = [];

        for (var subData in subtitleDataList) {
          final fileId = subData.attr?.files?.first.fileId;
          if (fileId != null) {
            final download = await downloadExternalSubtitle(
              Endpoints.externalSubtitleDownload(),
              fileId,
              appDep.opensubtitlesKey,
            );

            if (download.link != null) {
              final langName = supportedLanguages
                  .firstWhere((l) => l.languageCode == langCode,
                      orElse: () => SubLanguages(
                          languageName: langCode,
                          languageCode: langCode,
                          englishName: langCode))
                  .languageName;

              newExternalSubs.add(
                CaffeinePlayerSubtitlesSource(
                  name: "$langName ($fileId)",
                  urls: [download.link!],
                ),
              );
            }
          }
        }

        if (newExternalSubs.isNotEmpty) {
          final List<CaffeinePlayerSubtitlesSource> updatedSubs = [
            ..._currentSubs,
            ...newExternalSubs,
          ];

          // Filter duplicates
          final Map<String, CaffeinePlayerSubtitlesSource> uniqueSubs = {};
          for (var sub in updatedSubs) {
            uniqueSubs[sub.name!] = sub;
          }

          if (mounted) {
            setState(() {
              _currentSubs = uniqueSubs.values.toList();
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Found ${newExternalSubs.length} new subtitles")),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("No subtitles found for this language")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No subtitles found for this language")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error searching subtitles: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error searching subtitles")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final castService = context.watch<CastService>();
    final isCasting = castService.isConnected;

    if (isCasting && !_wasCasting) {
      _wasCasting = true;
      if (_betterPlayerController.isPlaying()) {
        _betterPlayerController.pause();
      }
    } else if (!isCasting && _wasCasting) {
      _wasCasting = false;
      final resumePos = castService.lastCastPositionOnDisconnect ??
          castService.castPositionSeconds;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeFromCast(resumePos);
      });
    }

    if (isCasting && castService.isMediaFinishedOnCast) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        debugPrint('[Player] 🏁 Cast media finished. Marking complete and returning.');
        
        // Use the total duration of the media to mark as 100% complete
        final castDurationMs = castService.totalMediaDurationSeconds * 1000;
        final finalElapsed = castDurationMs > 0 ? castDurationMs : duration;

        final navigator = Navigator.of(context);
        
        if (widget.mediaType == MediaType.movie) {
          await insertRecentMovieData(manualElapsed: finalElapsed);
        } else {
          await insertRecentEpisodeData(manualElapsed: finalElapsed);
        }

        castService.clearFinishedStatus();
        
        if (navigator.canPop()) {
          navigator.pop();
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final navigator = Navigator.of(context);

        if (_betterPlayerController.isVideoInitialized() == true) {
          final elapsed =
              _betterPlayerController.player.state.position.inMilliseconds;

          if (widget.mediaType == MediaType.movie) {
            await insertRecentMovieData(manualElapsed: elapsed);
          } else {
            await insertRecentEpisodeData(manualElapsed: elapsed);
          }
        }

        if (navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: mkv.Video(
                controller: _betterPlayerController.videoController,
                controls: mkv.NoVideoControls,
              ),
            ),
            StreamBuilder<bool>(
              stream: _betterPlayerController.player.stream.buffering,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            GlassPlayerControls(
              controller: _betterPlayerController,
              title: widget.mediaType == MediaType.movie
                  ? widget.movieMetadata?.movieName ?? ''
                  : widget.tvMetadata?.seriesName ?? '',
              subtitle: widget.mediaType == MediaType.tvShow
                  ? 'Season ${widget.tvMetadata?.seasonNumber} Episode ${widget.tvMetadata?.episodeNumber}'
                  : null,
              onBack: () => Navigator.of(context).pop(),
              onSubtitlePressed: _openSubtitleSelectionSheet,
              onResolutionPressed: () {}, // Resolution sheet not implemented yet
              onCastPressed: _openCastSheet,
            ),
            if (isCasting) _CastingOverlay(castService: castService),
          ],
        ),
      ),
    );
  }
}

/// Overlay displayed on the player while a Chromecast session is active.
class _CastingOverlay extends StatelessWidget {
  const _CastingOverlay({required this.castService});
  final CastService castService;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cast_connected, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              'Playing on',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              castService.connectedDeviceName ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            if (castService.nowPlayingTitle != null)
              Text(
                castService.nowPlayingTitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white60),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => castService.disconnect(),
              icon: const Icon(Icons.cast, color: Colors.white),
              label: const Text('Stop casting',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
