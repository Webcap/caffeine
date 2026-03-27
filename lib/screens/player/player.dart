import 'dart:async';
import 'package:caffiene/controller/recently_watched_database_controller.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/functions/video_utils.dart';
import 'package:caffiene/models/movie_stream_metadata.dart';
import 'package:caffiene/models/provider_video_source.dart';
import 'package:caffiene/models/recently_watched.dart';
import 'package:caffiene/models/tv_stream_metadata.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/player/widgets/cast_bottom_sheet.dart';
import 'package:caffiene/services/analytics_service.dart';
import 'package:caffiene/services/cast_service.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/utils/globlal_methods.dart';
import 'package:caffiene/video_providers/provider_loader.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/screens/player/widgets/language_picker_sheet.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/api/endpoints.dart';

class Player extends StatefulWidget {
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final List<Color> colors;
  final SettingsProvider settings;
  final MovieStreamMetadata? movieMetadata;
  final TVStreamMetadata? tvMetadata;
  final MediaType? mediaType;
  final String? subtitleStyle;
  final List<VideoProvider>? availableProviders;
  final String? currentProviderCode;
  final Map<String, String>? headers;
  final String? imdbId;

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
      this.imdbId,
      super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();
  late int duration;

  final GlobalKey _betterPlayerKey = GlobalKey();

  int totalMinutesWatched = 0;
  bool isVideoPaused = false;

  int playbackDurationInSeconds = 0;
  Timer? _durationTimer;
  // ignore: unused_field
  Timer? _resetTimer;

  late SettingsProvider settings;

  Map<String, String> _currentSources = {};
  List<BetterPlayerSubtitlesSource> _currentSubs = [];
  int _retryProviderIndex = 0;
  bool _isRetrying = false;

  @override
  void initState() {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    super.initState();
    String backgroundColorString = widget.settings.subtitleBackgroundColor;
    String foregroundColorString = widget.settings.subtitleForegroundColor;
    String hexColorBackground =
        backgroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");
    String hexColorForeground =
        foregroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");

    Color backgroundColor = Color(int.parse("0x$hexColorBackground"));
    Color foregroundColor = Color(int.parse("0x$hexColorForeground"));

    WidgetsBinding.instance.addObserver(this);
    betterPlayerBufferingConfiguration = BetterPlayerBufferingConfiguration(
      maxBufferMs: widget.settings.defaultMaxBufferDuration,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
        onFullScreenChange: () {
          widget.mediaType == MediaType.movie
              ? insertRecentMovieData()
              : insertRecentEpisodeData();
        },
        enableFullscreen: true,
        name: widget.mediaType == MediaType.movie
            ? "${widget.movieMetadata?.movieName ?? ''} (${widget.movieMetadata?.releaseYear ?? ''})"
            : "${widget.tvMetadata?.seriesName ?? ''} - ${widget.tvMetadata?.episodeName ?? ''} | ${episodeSeasonFormatter(widget.tvMetadata?.episodeNumber ?? 0, widget.tvMetadata?.seasonNumber ?? 0)}",
        backgroundColor: Colors.black,
        progressBarBackgroundColor: Colors.white,
        controlBarColor: Colors.black.withOpacity(0.3),
        muteIcon: Icons.volume_off_rounded,
        unMuteIcon: Icons.volume_up_rounded,
        pauseIcon: Icons.pause_rounded,
        pipMenuIcon: Icons.picture_in_picture_rounded,
        playIcon: Icons.play_arrow_rounded,
        showControlsOnInitialize: false,
        loadingColor: widget.colors.first,
        iconsColor: widget.colors.first,
        backwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        forwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        progressBarPlayedColor: widget.colors.first,
        progressBarBufferedColor: Colors.black45,
        skipForwardIcon: FontAwesomeIcons.rotateRight,
        skipBackIcon: FontAwesomeIcons.rotateLeft,
        fullscreenEnableIcon: Icons.fullscreen_rounded,
        fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
        overflowMenuIcon: Icons.menu_rounded,
        overflowMenuIconsColor: widget.colors.first,
        overflowModalTextColor: widget.colors.first,
        overflowModalColor: widget.colors.last,
        subtitlesIcon: Icons.closed_caption_rounded,
        qualitiesIcon: Icons.hd_rounded,
        enableAudioTracks: true,
        controlBarHeight: 50,
        watchingText: tr("watching_text"),
        playerTimeMode: settings.playerTimeDisplay,
        overflowMenuCustomItems: [
          BetterPlayerOverflowMenuItem(
            Icons.language,
            tr("search_more_subtitles"),
            () async {
              // Close overflow menu first
              Navigator.of(_betterPlayerKey.currentContext!).pop();

              if (!mounted) return;
              final langCode = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LanguagePickerSheet(),
              );

              if (langCode != null) {
                _searchMoreSubtitles(langCode);
              }
            },
          ),
        ]);
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: widget.settings.defaultViewMode,
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            allowedScreenSleep: false,
            autoDetectFullscreenAspectRatio: true,
            subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
                backgroundColor: backgroundColor,
                fontFamily: widget.subtitleStyle == 'regular'
                    ? 'Poppins'
                    : widget.subtitleStyle == 'bold'
                        ? 'PoppinsSB'
                        : 'PoppinsLight',
                fontColor: foregroundColor,
                outlineEnabled: false,
                fontSize: widget.settings.subtitleFontSize.toDouble()));


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

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, link ?? '',
        resolutions: widget.sources,
        subtitles: widget.subs,
        headers: widget.headers,
        videoFormat: (link != null && VideoUtils.looksLikeHls(link))
            ? BetterPlayerVideoFormat.hls
            : null,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 471859200 * 471859200,
          maxCacheSize: 1073741824 * 1073741824,
          maxCacheFileSize: 471859200 * 471859200,

          ///Android only option to use cached video between app sessions
          key: generateCacheKey(),
        ),
        bufferingConfiguration: betterPlayerBufferingConfiguration,
        preferredAudioLanguage: settings.defaultAudioLanguage);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((value) {
      if (!mounted) return;
      _betterPlayerController.videoPlayerController!.seekTo(Duration(
          milliseconds: widget.mediaType == MediaType.movie
              ? (widget.movieMetadata?.elapsed ?? 0)
              : (widget.tvMetadata?.elapsed ?? 0)));
      duration = _betterPlayerController
              .videoPlayerController?.value.duration?.inMilliseconds ??
          0;

      // Try multiple times as tracks might load late in HLS manifest
      _selectPreferredAudioTrack();
      Future.delayed(const Duration(milliseconds: 500),
          () => _selectPreferredAudioTrack());
      Future.delayed(const Duration(milliseconds: 1500),
          () => _selectPreferredAudioTrack());
      Future.delayed(const Duration(milliseconds: 3000),
          () => _selectPreferredAudioTrack());
      Future.delayed(const Duration(milliseconds: 5000),
          () => _selectPreferredAudioTrack());
    });
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _betterPlayerController.addEventsListener((BetterPlayerEvent event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        if (widget.availableProviders != null &&
            widget.currentProviderCode != null &&
            !_isRetrying) {
          final providers = widget.availableProviders!;
          final currentIndex = providers
              .indexWhere((p) => p.codeName == widget.currentProviderCode);
          final hasNext =
              currentIndex >= 0 && currentIndex < providers.length - 1;
          if (mounted) {
            GlobalMethods.showCustomScaffoldMessage(
              SnackBar(
                content: Text(tr(hasNext
                    ? 'stream_source_failed'
                    : 'stream_source_failed_retry')),
                duration: const Duration(seconds: 4),
              ),
              context,
            );
          }
          _tryNextProvider();
        } else if (mounted) {
          GlobalMethods.showCustomScaffoldMessage(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('stream_source_failed_retry')),
                  const SizedBox(height: 6),
                  Text(
                    tr('stream_source_failed_dns_tip'),
                    style: Theme.of(context)
                            .snackBarTheme
                            .contentTextStyle
                            ?.copyWith(
                                fontSize: 12, fontStyle: FontStyle.italic) ??
                        Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              duration: const Duration(seconds: 8),
            ),
            context,
          );
        }
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.finished) {
        // Save as completed when playback ends naturally
        if (widget.mediaType == MediaType.movie) {
          insertRecentMovieData(manualElapsed: duration);
        } else {
          insertRecentEpisodeData(manualElapsed: duration);
        }
        AnalyticsService.instance.trackEvent('Playback Finished', {
          'type': widget.mediaType == MediaType.movie ? 'movie' : 'tv_show',
          'id': widget.mediaType == MediaType.movie
              ? widget.movieMetadata?.movieId
              : widget.tvMetadata?.tvId,
          'name': widget.mediaType == MediaType.movie
              ? widget.movieMetadata?.movieName
              : widget.tvMetadata?.seriesName,
        });
      }
    });

    // });

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
    if (_isRetrying ||
        widget.availableProviders == null ||
        widget.currentProviderCode == null) return;

    final providers = widget.availableProviders!;
    final currentIndex =
        providers.indexWhere((p) => p.codeName == widget.currentProviderCode);
    if (currentIndex < 0 || currentIndex >= providers.length - 1) return;

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
              .map((s) => BetterPlayerSubtitlesSource(
                    name: s.language ?? 'Unknown',
                    urls: [s.url ?? ''],
                    type: BetterPlayerSubtitlesSourceType.network,
                  ))
              .toList();
        }

        final keyToFind = widget.settings.defaultVideoResolution == 0
            ? 'auto'
            : widget.settings.defaultVideoResolution.toString();
        String? link = newSources[keyToFind] ?? newSources.values.first;

        final dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          link,
          resolutions: newSources,
          subtitles: _currentSubs,
          videoFormat: VideoUtils.looksLikeHls(link)
              ? BetterPlayerVideoFormat.hls
              : null,
          cacheConfiguration: BetterPlayerCacheConfiguration(
            useCache: true,
            preCacheSize: 471859200 * 471859200,
            maxCacheSize: 1073741824 * 1073741824,
            maxCacheFileSize: 471859200 * 471859200,
            key: generateCacheKey(),
          ),
          bufferingConfiguration: betterPlayerBufferingConfiguration,
          preferredAudioLanguage: settings.defaultAudioLanguage,
        );
        await _betterPlayerController.setupDataSource(dataSource);
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
    final tracks = _betterPlayerController.betterPlayerAsmsAudioTracks;
    if (tracks == null || tracks.isEmpty) {
      debugPrint('[Player] 🎧 No audio tracks available yet.');
      return;
    }

    final preferred = settings.defaultAudioLanguage.toLowerCase();
    debugPrint('[Player] 🎧 Attempting to select audio track: $preferred');

    for (final track in tracks) {
      final lang = track.language?.toLowerCase() ?? '';
      final label = track.label?.toLowerCase() ?? '';
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
        final label = track.label?.toLowerCase() ?? '';

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
    if (_betterPlayerController.videoPlayerController == null) return;

    int elapsed = manualElapsed ??
        await _betterPlayerController.videoPlayerController!.position
            .then((value) => value!.inMilliseconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedMoviesController
        .contain(widget.movieMetadata!.movieId!);

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
    if (_betterPlayerController.videoPlayerController == null) return;

    int elapsed = manualElapsed ??
        await _betterPlayerController.videoPlayerController!.position
            .then((value) => value!.inMilliseconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedEpisodeController
        .contain(widget.tvMetadata!.episodeId!);

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
    if (isInBackground) {
      if (_betterPlayerController.isVideoInitialized() == true) {
        widget.mediaType == MediaType.movie
            ? insertRecentMovieData()
            : insertRecentEpisodeData();
      }
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _resetTimer?.cancel();
    _betterPlayerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
    final initialized = _betterPlayerController.isVideoInitialized() ?? false;
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
    return '$TMDB_BASE_IMAGE_URL/w500$posterPath';
  }

  Future<int> get _currentElapsedMilliseconds async {
    if (!(_betterPlayerController.isVideoInitialized() ?? false)) return 0;
    final pos = await _betterPlayerController.videoPlayerController!.position;
    return pos?.inMilliseconds ?? 0;
  }

  void _openCastSheet() async {
    if (!mounted) return;
    if (_betterPlayerController.isPlaying() ?? false) {
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
      ),
    );
  }

  Future<void> _searchMoreSubtitles(String langCode) async {
    if (widget.imdbId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cannot search subtitles without IMDB ID")),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Searching for $langCode subtitles...")),
      );
    }

    try {
      final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
      final searchUrl = widget.mediaType == MediaType.movie
          ? Endpoints.searchExternalMovieSubtitles(widget.imdbId!, langCode)
          : Endpoints.searchExternalEpisodeSubtitles(
              widget.imdbId!,
              widget.tvMetadata!.episodeNumber!,
              widget.tvMetadata!.seasonNumber!,
              langCode,
            );

      final subtitleDataList = await getExternalSubtitle(
        searchUrl,
        appDep.opensubtitlesKey,
      );

      if (subtitleDataList.isNotEmpty) {
        final List<BetterPlayerSubtitlesSource> newExternalSubs = [];

        for (var subData in subtitleDataList) {
          final fileId = subData.attr?.files?.first.fileId;
          if (fileId != null) {
            final download = await downloadExternalSubtitle(
              Endpoints.externalSubtitleDownload(),
              fileId,
              appDep.opensubtitlesKey,
            );

            if (download.link != null) {
              newExternalSubs.add(
                BetterPlayerSubtitlesSource(
                  name: "${subData.attr?.language ?? langCode} ($fileId)",
                  urls: [download.link!],
                  type: BetterPlayerSubtitlesSourceType.network,
                ),
              );
            }
          }
        }

        if (newExternalSubs.isNotEmpty) {
          final List<BetterPlayerSubtitlesSource> updatedSubs = [
            ..._currentSubs,
            ...newExternalSubs,
          ];

          // Filter duplicates
          final Map<String, BetterPlayerSubtitlesSource> uniqueSubs = {};
          for (var sub in updatedSubs) {
            uniqueSubs[sub.name!] = sub;
          }

          if (mounted) {
            setState(() {
              _currentSubs = uniqueSubs.values.toList();
            });
          }

          // Re-setup data source to include new subtitles
          final currentPosition =
              _betterPlayerController.videoPlayerController?.value.position ??
                  Duration.zero;
          final currentUrl = _currentSources.isNotEmpty
              ? _currentSources.values.first
              : widget.sources.values.first;

          await _betterPlayerController.setupDataSource(
            BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              currentUrl,
              resolutions:
                  _currentSources.isNotEmpty ? _currentSources : widget.sources,
              subtitles: _currentSubs,
              useAsmsSubtitles: true,
              useAsmsAudioTracks: true,
              useAsmsTracks: true,
              headers: widget.headers,
              videoFormat: VideoUtils.looksLikeHls(currentUrl)
                  ? BetterPlayerVideoFormat.hls
                  : null,
              cacheConfiguration: BetterPlayerCacheConfiguration(
                useCache: true,
                preCacheSize: 471859200 * 471859200,
                maxCacheSize: 1073741824 * 1073741824,
                maxCacheFileSize: 471859200 * 471859200,
                key: generateCacheKey(),
              ),
              bufferingConfiguration: betterPlayerBufferingConfiguration,
              preferredAudioLanguage: settings.defaultAudioLanguage,
            ),
          );

          _betterPlayerController.seekTo(currentPosition);
          _betterPlayerController.play();

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
      if (_betterPlayerController.isPlaying() ?? false) {
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

    return WillPopScope(
      onWillPop: () async {
        if (_betterPlayerController.isVideoInitialized() == true) {
          final elapsed = await _betterPlayerController
              .videoPlayerController!.position
              .then((v) => v!.inMilliseconds);

          if (widget.mediaType == MediaType.movie) {
            await insertRecentMovieData(manualElapsed: elapsed);
          } else {
            await insertRecentEpisodeData(manualElapsed: elapsed);
          }
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                  key: _betterPlayerKey,
                ),
              ),
            ),
            if (isCasting) _CastingOverlay(castService: castService),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'castFab',
              onPressed: _openCastSheet,
              backgroundColor:
                  isCasting ? Theme.of(context).colorScheme.primary : null,
              child: Icon(
                isCasting ? Icons.cast_connected : Icons.cast,
                color: isCasting ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'externalFab',
              onPressed: () {
                if (mounted) {
                  showModalBottomSheet(
                      builder: (context) {
                        return ExternalPlay(
                          videoSources: _currentSources.isNotEmpty
                              ? _currentSources
                              : widget.sources,
                          subtitleSources: _currentSubs.isNotEmpty
                              ? _currentSubs
                              : widget.subs,
                        );
                      },
                      context: context);
                }
              },
              child: const Icon(FontAwesomeIcons.arrowUpRightFromSquare),
            ),
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
