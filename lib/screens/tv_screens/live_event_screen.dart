import 'package:reelriot/services/player/caffeine_player_controller.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reelriot/functions/video_utils.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/espn_scoreboard.dart';
import 'package:reelriot/models/live_tv.dart';
import 'package:reelriot/screens/tv_screens/live_tv_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// design.json tokens: cinematic, dark-first, primary red
abstract class _Design {
  static const Color bgCanvasDark = Color(0xFF030712); // gray-950
  static const Color bgSurfaceDark = Color(0xFF0B0F14); // gray-900
  static const Color primaryCta = Color(0xFFDC2626); // primary-600
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary =
      Color(0xB8FFFFFF); // rgba(255,255,255,0.72)
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const double radiusSm = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
}

class LiveEventScreen extends StatefulWidget {
  const LiveEventScreen({
    super.key,
    required this.event,
    this.espnGame,
    this.videoUrl,
    this.referrer = '',
    this.userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    this.sources,
  });

  final StreameastEvent event;
  final EspnScoreboardGame? espnGame;
  final String? videoUrl;
  final String referrer;
  final String userAgent;
  final List<dynamic>? sources;

  /// Match event title "Team A vs Team B" to an ESPN game by name overlap.
  static EspnScoreboardGame? findMatchingGame(
      String title, List<EspnScoreboardGame> games) {
    final vs = title.split(RegExp(r'\s+vs\s+', caseSensitive: false));
    if (vs.length != 2) return null;

    final stopWords = {
      'at',
      'the',
      'of',
      'vs',
      '@',
      'and',
      'a',
      'in',
      'on',
      'live',
      'ft'
    };


    final left = vs[0]
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toList();
    final right = vs[1]
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toList();

    if (left.isEmpty || right.isEmpty) return null;

    final gameNames = games.map((g) => g.name.toLowerCase()).toList();

    for (int i = 0; i < gameNames.length; i++) {
      final name = gameNames[i];
      final leftMatch = left.any((w) => name.contains(w));
      final rightMatch = right.any((w) => name.contains(w));

      if (leftMatch && rightMatch) return games[i];
    }
    return null;
  }

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen> {
  CaffeinePlayerController? _controller;
  final GlobalKey _playerKey = GlobalKey();
  EspnScoreboardGame? _scoreGame;
  String? _currentUrl;
  String? _currentReferrer;
  List<dynamic> _sources = [];

  bool get _hasStream =>
      (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty);

  String? get _effectiveVideoUrl => _currentUrl?.trim().isNotEmpty == true
      ? _currentUrl
      : null;

  String get _effectiveReferrer => _currentReferrer ?? '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.videoUrl;
    _currentReferrer = widget.referrer;
    _sources = widget.sources ?? [];
    if (_hasStream) _initPlayer();
    if (widget.event.sport?.toLowerCase() == 'nba') _loadNbaScore();
  }

  // Removed _checkSupabaseStream and HLS extraction fallbacks.

  Future<void> _loadNbaScore() async {
    final response = await fetchNbaScoreboard();
    if (!mounted) return;
    final parsed = parseLiveEventTitle(widget.event.title);
    final game = response != null
        ? LiveEventScreen.findMatchingGame(parsed.title, response.games)
        : null;
    setState(() => _scoreGame = game);
  }

  void _initPlayerWithUrl(String url) {
    _controller?.dispose();
    _controller = null;
    
    final c = CaffeinePlayerController();
    c.setDataSource(
      url,
      liveStream: true,
      headers: {
        'User-Agent': widget.userAgent,
        'Referer': _effectiveReferrer,
        'Origin': _getOrigin(_effectiveReferrer),
        'Accept': '*/*',
        'Connection': 'keep-alive',
      },
    );
    _controller = c;
  }
  
  String _getOrigin(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme.isEmpty || uri.host.isEmpty) return url.replaceAll(RegExp(r'/$'), '');
      return '${uri.scheme}://${uri.host}';
    } catch (_) {
      return url.replaceAll(RegExp(r'/$'), '');
    }
  }

  void _initPlayer() {
    final url = _effectiveVideoUrl;
    if (url != null && url.isNotEmpty) _initPlayerWithUrl(url);
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseLiveEventTitle(widget.event.title);
    return Scaffold(
      backgroundColor: _Design.bgCanvasDark,
      appBar: AppBar(
        backgroundColor: _Design.bgSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space4),
          child: Material(
            color: _Design.borderSubtle,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_rounded,
                    size: 22, color: _Design.textPrimary),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Caffeine Live',
          style: TextStyle(
            color: _Design.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: _Design.textPrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: _hasStream && _controller != null
                ? Container(
                    color: Colors.black,
                    child: mkv.Video(
                      controller: _controller!.videoController,
                      controls: mkv.MaterialVideoControls,
                    ),
                  )
                : _NoStreamPlaceholder(eventPageUrl: widget.event.url),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: _Design.space5, vertical: _Design.space6),
            decoration: const BoxDecoration(
              color: _Design.bgSurfaceDark,
              border: Border(
                  top: BorderSide(color: _Design.borderSubtle, width: 1)),
            ),
            child: _EventInfoSection(
              event: widget.event,
              espnGame: widget.espnGame,
              parsed: parsed,
              scoreGame: _scoreGame,
              sources: _sources,
              currentUrl: _currentUrl,
              onSourceChanged: (source) {
                final url = source['url']?.toString();
                final ref = source['referrer']?.toString() ?? '';
                if (url == null || url == _currentUrl) return;
                setState(() {
                  _currentUrl = url;
                  _currentReferrer = ref;
                });
                _initPlayer();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStreamPlaceholder extends StatelessWidget {
  const _NoStreamPlaceholder({this.eventPageUrl});

  final String? eventPageUrl;

  @override
  Widget build(BuildContext context) {
    final hasEventPage =
        eventPageUrl != null && eventPageUrl!.trim().isNotEmpty;
    return Container(
      color: _Design.bgSurfaceDark,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: _Design.space6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.live_tv_rounded, size: 64, color: _Design.textSecondary),
            const SizedBox(height: _Design.space4),
            Text(
              'No stream available',
              style: TextStyle(
                color: _Design.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasEventPage
                  ? 'Open the event page to watch in browser or in-app.'
                  : 'Try again later or choose another event',
              style: TextStyle(
                color: _Design.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasEventPage) ...[
              const SizedBox(height: _Design.space5),
              OutlinedButton.icon(
                onPressed: () => _openInBrowser(context, eventPageUrl!),
                icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                label: const Text('Open in browser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Design.primaryCta,
                  side: const BorderSide(color: _Design.primaryCta),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _openInBrowser(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
class _EventInfoSection extends StatelessWidget {
  final StreameastEvent event;
  final EspnScoreboardGame? espnGame;
  final LiveEventTitleParsed parsed;
  final EspnScoreboardGame? scoreGame;
  final List<dynamic>? sources;
  final String? currentUrl;
  final Function(Map<String, dynamic>) onSourceChanged;

  const _EventInfoSection({
    required this.event,
    this.espnGame,
    required this.parsed,
    this.scoreGame,
    this.sources,
    this.currentUrl,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayGame = scoreGame ?? espnGame;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayGame != null &&
            (displayGame.isLive || displayGame.isEffectivelyCompleted)) ...[
          _ScoreRow(game: displayGame),
          const SizedBox(height: _Design.space4),
        ],
        if (parsed.status != null && parsed.status!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              parsed.status!,
              style: const TextStyle(
                color: _Design.primaryCta,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogo(),
            const SizedBox(width: _Design.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.title,
                    style: const TextStyle(
                      color: _Design.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.sport != null && event.sport!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.sport!.toUpperCase(),
                      style: const TextStyle(
                        color: _Design.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (sources != null && sources!.isNotEmpty) ...[
          const SizedBox(height: _Design.space6),
          const Text(
            'AVAILABLE MIRRORS',
            style: TextStyle(
              color: _Design.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sources!.length,
              itemBuilder: (context, index) {
                final source = sources![index];
                final name = source['name'] ?? 'Source ${index + 1}';
                final url = source['url'] ?? '';
                final isSelected = url == currentUrl;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onSourceChanged(source);
                    },
                    backgroundColor: _Design.bgCanvasDark,
                    selectedColor: _Design.primaryCta,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_Design.radiusSm),
                      side: BorderSide(
                        color: isSelected
                            ? _Design.primaryCta
                            : _Design.borderSubtle,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : _Design.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogo() {
    final url = espnGame?.thumbnailUrl ?? event.logoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_Design.radiusSm),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (_, __) => _logoPlaceholder(),
          errorWidget: (_, __, ___) => _logoPlaceholder(),
        ),
      );
    }
    return _logoPlaceholder();
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _Design.primaryCta.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(_Design.radiusSm),
      ),
      child: const Icon(Icons.live_tv_rounded,
          color: _Design.primaryCta, size: 28),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.game});

  final EspnScoreboardGame game;

  @override
  Widget build(BuildContext context) {
    final away = game.away;
    final home = game.home;
    final status = game.status;
    if (away == null && home == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _Design.bgCanvasDark,
        borderRadius: BorderRadius.circular(_Design.radiusSm),
        border: Border.all(color: _Design.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TeamScore(
              name: away?.displayName ?? '',
              score: away?.score ?? '0',
              logoUrl: away?.logoUrl,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '@',
                style: TextStyle(
                  color: _Design.textSecondary.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (status != null && status.shortDetail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    status.shortDetail,
                    style: const TextStyle(
                      color: _Design.primaryCta,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          Expanded(
            child: _TeamScore(
              name: home?.displayName ?? '',
              score: home?.score ?? '0',
              logoUrl: home?.logoUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({
    required this.name,
    required this.score,
    this.logoUrl,
  });

  final String name;
  final String score;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoUrl != null && logoUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: logoUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              placeholder: (_, __) => _smallLogoPlaceholder(),
              errorWidget: (_, __, ___) => _smallLogoPlaceholder(),
            ),
          )
        else
          _smallLogoPlaceholder(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _Design.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                score,
                style: const TextStyle(
                  color: _Design.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallLogoPlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _Design.borderSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.sports_basketball_rounded,
          color: _Design.textSecondary, size: 18),
    );
  }
}
