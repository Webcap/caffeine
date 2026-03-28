// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/functions/network.dart';
import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/models/espn_scoreboard.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:caffiene/screens/tv_screens/live_event_screen.dart';
import 'package:caffiene/widgets/featured_match_card.dart';
import 'package:provider/provider.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/services/ad_service.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Removed _streamedFallbackUrl as we are Supabase-only now.

/// Prettifies scraped event titles: fix concatenation, extract status, add " vs " for match names.
String formatLiveEventTitle(String raw) {
  if (raw.trim().isEmpty) return raw;
  String s = raw.trim();
  // Ensure space after "Live Now!"
  s = s.replaceAllMapped(RegExp(r'Live Now!(\S)'), (m) => 'Live Now! ${m[1]}');
  // Ensure space after "Starts in: HH:MM:SS"
  s = s.replaceAllMapped(
      RegExp(r'(Starts in:\s*\d{2}:\d{2}(?::\d{2})?)([A-Za-z])'),
      (m) => '${m[1]} ${m[2]}');
  // Space between lowercase and uppercase (e.g. MammothChicago -> Mammoth Chicago)
  s = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  // Space between digit and Uppercase letter (e.g. 41Galatasaray -> 41 Galatasaray)
  // We avoid lower case to preserve names like "76ers" or "49ers"
  s = s.replaceAllMapped(RegExp(r'(\d)([A-Z])'), (m) => '${m[1]} ${m[2]}');
  // Space after status prefixes (e.g. FTManchester -> FT Manchester)
  s = s.replaceAllMapped(RegExp(r'^(FT|HT|LIVE|PST|CAN|TBD)([A-Z1-9])'), (m) => '${m[1]} ${m[2]}');

  // Normalize separators: replace "@" and " at " with " vs " early
  s = s.replaceAll(RegExp(r'\s+at\s+', caseSensitive: false), ' vs ');
  s = s.replaceAll(RegExp(r'\s+@\s+'), ' vs ');

  // Normalize multiple "vs" that might have been created
  s = s.replaceAll(RegExp(r'\s+vs\s+vs\s+', caseSensitive: false), ' vs ');

  // Normalize multiple spaces
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Add " vs " between two teams if missing (only in the event part, not inside status)
  String prefix = '';
  String body = s;
  if (s.startsWith('Live Now!')) {
    prefix = 'Live Now! ';
    body = s.substring(9).trim();
  } else {
    final startsMatch = RegExp(r'^(Starts in:\s*\S+)\s*(.*)$').firstMatch(s);
    if (startsMatch != null) {
      prefix = '${startsMatch.group(1)!} ';
      body = (startsMatch.group(2) ?? '').trim();
    }
  }

  // Final cleanup: if we have "vs at" or "at vs" from raw input, simplify to "vs"
  body = body.replaceAll(RegExp(r'\s+vs\s+at\s+', caseSensitive: false), ' vs ');
  body = body.replaceAll(RegExp(r'\s+at\s+vs\s+', caseSensitive: false), ' vs ');

  if (body.isNotEmpty && !body.toLowerCase().contains(' vs ')) {
    final words = body.split(RegExp(r'\s+'));
    if (words.length == 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      body = '${words[0]} vs ${words[1]}';
    } else if (words.length >= 4) {
      final mid = words.length ~/ 2;
      body = '${words.take(mid).join(' ')} vs ${words.skip(mid).join(' ')}';
    }
  }
  return (prefix + body).trim();
}

/// Parsed bits for display: optional status (Live Now! / Starts in: ...) and main title.
LiveEventTitleParsed parseLiveEventTitle(String raw) {
  final formatted = formatLiveEventTitle(raw);
  String? status;
  String title = formatted;
  if (formatted.startsWith('Live Now!')) {
    status = 'Live Now!';
    title = formatted.substring(9).trim();
    if (title.isEmpty) title = formatted;
  } else if (RegExp(r'^Starts in:\s*\d').hasMatch(formatted)) {
    final match = RegExp(r'^(Starts in:\s*\S+)\s*(.*)$').firstMatch(formatted);
    if (match != null) {
      status = match.group(1)!.trim();
      title = (match.group(2) ?? '').trim();
      if (title.isEmpty) title = formatted;
    }
  }
  return LiveEventTitleParsed(status: status, title: title);
}

class LiveEventTitleParsed {
  const LiveEventTitleParsed({this.status, required this.title});
  final String? status;
  final String title;
}

// Design tokens from design.json (cinematic, dark-first, primary red CTA)
abstract class _LiveTvDesign {
  static const Color bgCanvasDark = Color(0xFF030712);
  static const Color bgSurfaceDark = Color(0xFF0B0F14);
  static const Color primaryCta = Color(0xFFDC2626);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB8FFFFFF);
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const double radiusCard = 20.0;
  static const double radiusSm = 12.0;
  static const double radiusPill = 9999.0;
  static const double ctaHeight = 52.0;
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x38000000), blurRadius: 30, offset: Offset(0, 10)),
  ];
}

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<ChannelList> createState() => ChannelListState();
}

class ChannelListState extends State<ChannelList> {
  List<EspnListEvent>? _todayEvents;
  Set<String> _activeStreamIds = {};
  bool _loadFailed = false;
  String _searchQuery = '';
  String? _sportFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadTodayEvents());
  }

  Future<void> loadTodayEvents() async {
    if (!mounted) return;
    setState(() => _loadFailed = false);
    // Use device local date/time so "today" and live games match the user's timezone.
    final date = DateTime.now();
    debugPrint(
        '[LiveTV] Loading ESPN events for ${date.year}-${date.month}-${date.day} (local)');
    try {
      final todayList = await fetchEspnEventsForDayMultiLeague(date);

      // If it's early morning (before 6am), also fetch yesterday to catch late-night live games
      List<EspnListEvent> yesterdayLive = [];
      if (date.hour < 6) {
        final yesterday = date.subtract(const Duration(days: 1));
        final yesterdayList = await fetchEspnEventsForDayMultiLeague(yesterday);
        // Only keep games that are actually live or very recently ended
        yesterdayLive = yesterdayList.where((e) => e.game.isActuallyLive).toList();
      }

      final combined = [...yesterdayLive, ...todayList];
      // deduplicate by id
      final seen = <String>{};
      final list = combined.where((e) => seen.add(e.game.id)).toList();

      final activeStreams = await Supabase.instance.client
          .from('live_streams')
          .select('id, is_ended')
          .not('video_url', 'is', null)
          .eq('is_hidden', false);

      final Map<String, bool> endedInfo = {
        for (var s in (activeStreams as List))
          s['id'].toString(): s['is_ended'] == true
      };

      final activeStreamIds = endedInfo.keys.toSet();

      final updatedList = list.map((e) {
        if (endedInfo.containsKey(e.game.id)) {
          return e.copyWith(
            game: e.game.copyWith(isManualEnded: endedInfo[e.game.id]),
          );
        }
        return e;
      }).toList();

      if (!mounted) return;

      setState(() {
        _activeStreamIds = activeStreamIds;
        _todayEvents = updatedList;
      });
      debugPrint('[LiveTV] Loaded ${list.length} events');
    } catch (e, st) {
      debugPrint('[LiveTV] ESPN load failed: $e');
      debugPrint('[LiveTV] $st');
      if (!mounted) return;
      setState(() {
        _todayEvents = [];
        _loadFailed = true;
      });
    }
  }

  /// Unique sports from ESPN events, sorted.
  List<String> get _sportFilters {
    if (_todayEvents == null) return [];
    final set = <String>{};
    for (final e in _todayEvents!) {
      final s = e.sport.trim();
      if (s.isNotEmpty) set.add(s.toUpperCase());
    }
    final list = set.toList()..sort();
    return list;
  }

  List<EspnListEvent> get _filteredEvents {
    if (_todayEvents == null) return [];
    var list = _todayEvents!;
    if (_sportFilter != null && _sportFilter!.isNotEmpty) {
      final sportLower = _sportFilter!.toLowerCase();
      list = list.where((e) => e.sport.toLowerCase() == sportLower).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) {
        final title = e.game.name.toLowerCase();
        final sport = e.sport.toLowerCase();
        final league = e.league.toLowerCase();
        return title.contains(q) || sport.contains(q) || league.contains(q);
      }).toList();
    }

    // Filter out upcoming games that are further than 30 minutes away
    final now = DateTime.now();
    list = list.where((e) {
      if (!e.game.isActuallyLive && !e.game.isEffectivelyCompleted) {
        if (e.game.startTimeUtc == null) return false;
        final diff = e.game.startTimeUtc!.difference(now).inMinutes;
        return diff <= 30;
      }
      return true; // Keep Live and Completed
    }).toList();

    // Sort events
    list = list.toList()
      ..sort((a, b) {
        final now = DateTime.now();
        final timeA = a.game.startTimeUtc;
        final timeB = b.game.startTimeUtc;

        // Group 1: Upcoming soon (within 30 mins of starting)
        final isAStartingSoon = !a.game.isActuallyLive && !a.game.isEffectivelyCompleted &&
                                timeA != null && timeA.isAfter(now) &&
                                timeA.difference(now).inMinutes <= 30;
        final isBStartingSoon = !b.game.isActuallyLive && !b.game.isEffectivelyCompleted &&
                                timeB != null && timeB.isAfter(now) &&
                                timeB.difference(now).inMinutes <= 30;

        if (isAStartingSoon != isBStartingSoon) {
          return isAStartingSoon ? -1 : 1;
        }

        // Group 2: Actually Live games
        if (a.game.isActuallyLive != b.game.isActuallyLive) {
          return a.game.isActuallyLive ? -1 : 1;
        }

        // Group 3: Other scheduled games (not starting soon, not live, not completed)
        final aSched = !a.game.isActuallyLive && !a.game.isEffectivelyCompleted;
        final bSched = !b.game.isActuallyLive && !b.game.isEffectivelyCompleted;
        if (aSched != bSched) {
          return aSched ? -1 : 1;
        }

        // Sorting within groups by time (Sooner first)
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;

        return timeA.compareTo(timeB);
      });
    return list;
  }

  Map<String, List<EspnListEvent>> get _categorizedEvents {
    final list = _filteredEvents;
    return {
      'live': list
          .where((e) => e.game.isActuallyLive && !e.game.isEffectivelyCompleted)
          .toList(),
      'upcoming': list
          .where((e) => !e.game.isActuallyLive && !e.game.isEffectivelyCompleted)
          .toList(),
      'completed': list.where((e) => e.game.isEffectivelyCompleted).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _LiveTvDesign.bgCanvasDark : null,
      appBar: AppBar(
        title: Text(
          tr("channels"),
          style: TextStyle(
            color: isDark ? _LiveTvDesign.textPrimary : null,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? _LiveTvDesign.bgCanvasDark : null,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme:
            IconThemeData(color: isDark ? _LiveTvDesign.textPrimary : null),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loadFailed) {
      return _buildErrorCard(isDark);
    }
    if (_todayEvents == null) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _LiveTvDesign.primaryCta,
          ),
        ),
      );
    }
    final cats = _categorizedEvents;
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final featuredEvent =
        Provider.of<AppDependencyProvider>(context).featuredEvent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer2<AdService, AppDependencyProvider>(
          builder: (context, ads, app, _) {
            final bannerAd = ads.bannerAd;
            final adsEnabled = app.enableADS;
            if (bannerAd == null || !adsEnabled) return const SizedBox.shrink();
            return _BannerWrapper(ad: bannerAd);
          },
        ),
        if (featuredEvent != null) FeaturedMatchCard(event: featuredEvent),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Text(
            dateStr,
            style: TextStyle(
              color: isDark
                  ? _LiveTvDesign.textSecondary
                  : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        _buildSearchCard(isDark),
        const SizedBox(height: 12),
        _buildChannelFilters(isDark),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            color: _LiveTvDesign.primaryCta,
            onRefresh: loadTodayEvents,
            child: _todayEvents!.isEmpty
                ? _buildEmptyState(isDark, "No events today")
                : (cats['live']!.isEmpty &&
                        cats['upcoming']!.isEmpty &&
                        cats['completed']!.isEmpty)
                    ? _buildEmptyState(isDark, "No events match your search")
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (cats['live']!.isNotEmpty) ...[
                            _buildSectionHeader(isDark, "LIVE NOW",
                                color: _LiveTvDesign.primaryCta),
                            ...cats['live']!.map((event) => _buildEventTile(event, isDark)),
                            const SizedBox(height: 16),
                          ],
                          if (cats['upcoming']!.isNotEmpty) ...[
                            _buildSectionHeader(isDark, "UPCOMING"),
                            ...cats['upcoming']!.map((event) => _buildEventTile(event, isDark)),
                            const SizedBox(height: 16),
                          ],
                          if (cats['completed']!.isNotEmpty) ...[
                            _buildSectionHeader(isDark, "COMPLETED"),
                            ...cats['completed']!.map((event) => _buildEventTile(event, isDark)),
                          ],
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 500,
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? _LiveTvDesign.textSecondary : null,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          if (color != null) ...[
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: color ?? (isDark ? _LiveTvDesign.textSecondary : Colors.black54),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(EspnListEvent event, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _EspnEventTile(
        event: event,
        isDark: isDark,
        hasStream: _activeStreamIds.contains(event.game.id),
        onTap: () => _openEvent(event),
      ),
    );
  }

  Future<void> _openEvent(EspnListEvent ev) async {
    debugPrint('[LiveTV] Event tapped: "${ev.game.name}" (${ev.sport})');
    WakelockPlus.enable();
    final cancelRequested = Completer<void>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 16),
                const Text('Checking database...'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (!cancelRequested.isCompleted)
                      cancelRequested.complete();
                    if (dialogContext.mounted)
                      Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    StreameastEvent? matchedEvent;
    String? videoUrl;
    String referrer = '';
    String userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

    try {
      if (!cancelRequested.isCompleted) {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('live_streams')
            .select()
            .eq('id', ev.game.id)
            .maybeSingle();

        if (response != null &&
            response['video_url'] != null &&
            response['video_url'].toString().isNotEmpty) {
          videoUrl = response['video_url'];
          String? ref = response['referrer']?.toString();
          if (ref == null || ref.isEmpty) {
            final src = response['sources'];
            if (src is List && src.isNotEmpty) {
              ref = src.first['referrer']?.toString();
            }
          }
          referrer = ref ?? '';
          matchedEvent = StreameastEvent(
            id: ev.game.id,
            title: ev.game.name,
            url: '',
            sport: ev.sport,
            logoUrl: ev.game.thumbnailUrl,
            sources: response['sources'] as List<dynamic>?,
          );
          debugPrint('[LiveTV] Found Supabase stream for ${ev.game.name}');
        }
      }
    } catch (e, st) {
      debugPrint('[LiveTV] Supabase lookup error: $e');
      debugPrint('[LiveTV] $st');
    } finally {
      WakelockPlus.disable();
    }

    if (!mounted) return;
    if (cancelRequested.isCompleted) return;
    Navigator.of(context).pop();

    final eventToShow = matchedEvent ??
        StreameastEvent(
          id: ev.game.id,
          title: ev.game.name,
          url: '',
          sport: ev.sport,
          logoUrl: ev.game.thumbnailUrl,
        );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveEventScreen(
          event: eventToShow,
          espnGame: ev.game,
          videoUrl: videoUrl,
          referrer: referrer,
          userAgent: userAgent,
          sources: eventToShow.sources,
        ),
      ),
    );
  }

  // Removed legacy title normalization and matching methods as we use ID matching now.

  Widget _buildSearchCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? _LiveTvDesign.bgSurfaceDark : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(_LiveTvDesign.radiusSm),
        border: Border.all(
            color: isDark ? _LiveTvDesign.borderSubtle : Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(
          color: isDark ? _LiveTvDesign.textPrimary : null,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search events',
          hintStyle: TextStyle(
              color: isDark ? _LiveTvDesign.textSecondary : Colors.grey),
          prefixIcon: Icon(Icons.search_rounded,
              color: isDark ? _LiveTvDesign.textSecondary : null),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildChannelFilters(bool isDark) {
    final filters = _sportFilters;
    if (filters.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: tr('all') == 'all' ? 'All' : tr('all'),
            selected: _sportFilter == null,
            isDark: isDark,
            onTap: () => setState(() => _sportFilter = null),
          ),
          const SizedBox(width: 8),
          ...filters.map((sport) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: sport,
                  selected: _sportFilter?.toUpperCase() == sport,
                  isDark: isDark,
                  onTap: () => setState(() => _sportFilter =
                      (_sportFilter?.toUpperCase() == sport) ? null : sport),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? _LiveTvDesign.bgSurfaceDark
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(_LiveTvDesign.radiusCard),
          border: Border.all(
              color:
                  isDark ? _LiveTvDesign.borderSubtle : Colors.grey.shade300),
          boxShadow: isDark ? _LiveTvDesign.shadowCard : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded,
                size: 48,
                color: isDark ? _LiveTvDesign.textSecondary : Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Could not load events',
              style: TextStyle(
                color: isDark ? _LiveTvDesign.textPrimary : null,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: _LiveTvDesign.ctaHeight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _LiveTvDesign.primaryCta,
                  foregroundColor: _LiveTvDesign.textPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(_LiveTvDesign.radiusPill)),
                  elevation: 0,
                ),
                onPressed: loadTodayEvents,
                child: Text(tr("retry"),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-based tile for one ESPN event; shows Away vs Home with scores.
class _EspnEventTile extends StatelessWidget {
  const _EspnEventTile({
    required this.event,
    required this.isDark,
    required this.hasStream,
    required this.onTap,
  });

  final EspnListEvent event;
  final bool isDark;
  final bool hasStream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = event.game;
    final accentColor = _LiveTvDesign.primaryCta;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_LiveTvDesign.radiusSm),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? _LiveTvDesign.bgSurfaceDark
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(_LiveTvDesign.radiusSm),
            border: Border.all(
                color: isDark
                    ? _LiveTvDesign.borderSubtle
                    : Colors.grey.shade200),
            boxShadow: isDark ? _LiveTvDesign.shadowCard : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (g.isActuallyLive) ...[
                        _LiveBadgeSmall(),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _getStatusText(g),
                        style: TextStyle(
                          color: g.isActuallyLive
                              ? accentColor
                              : (isDark
                                  ? _LiveTvDesign.textSecondary
                                  : Colors.grey.shade600),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (event.sport.toUpperCase() == 'MMA' ||
                  event.league.toUpperCase() == 'UFC') ...[
                Text(
                  (g.name.contains(':')
                          ? g.name.split(':').last.trim()
                          : g.name)
                      .toUpperCase(),
                  style: TextStyle(
                    color: isDark
                        ? _LiveTvDesign.primaryCta
                        : _LiveTvDesign.primaryCta,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              // Away Team Row
              _TeamRow(
                name: g.away?.displayName ?? 'Away',
                logoUrl: g.away?.logoUrl,
                score: (!(event.sport.toUpperCase() == 'MMA' || event.league.toUpperCase() == 'UFC') && (g.isLive || g.isEffectivelyCompleted))
                    ? g.away?.score
                    : null,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              // Home Team Row
              _TeamRow(
                name: g.home?.displayName ?? 'Home',
                logoUrl: g.home?.logoUrl,
                score: (!(event.sport.toUpperCase() == 'MMA' || event.league.toUpperCase() == 'UFC') && (g.isLive || g.isEffectivelyCompleted))
                    ? g.home?.score
                    : null,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              // League / Sport footer
              Text(
                '${event.league} · ${event.sport}${g.competitionType != null ? " · ${g.competitionType}" : ""}'
                    .toUpperCase(),
                style: TextStyle(
                  color: isDark
                      ? _LiveTvDesign.textSecondary.withOpacity(0.5)
                      : Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(EspnScoreboardGame g) {
    if (g.isActuallyLive) return g.timeOrStatus ?? 'LIVE';
    if (g.isEffectivelyCompleted) return 'FINAL';
    return g.startTimeLocal ?? 'SCHEDULED';
  }
}

class _LiveBadgeSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: _LiveTvDesign.primaryCta,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.name,
    this.logoUrl,
    this.score,
    required this.isDark,
  });

  final String name;
  final String? logoUrl;
  final String? score;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TeamLogo(logoUrl: logoUrl, isDark: isDark),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isDark ? _LiveTvDesign.textPrimary : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            score!,
            style: TextStyle(
              color: isDark ? _LiveTvDesign.textPrimary : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({this.logoUrl, required this.isDark});
  final String? logoUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: logoUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              ),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.sports_rounded,
      size: 18,
      color: isDark ? _LiveTvDesign.textSecondary : Colors.grey,
    );
  }
}

/// Chip for channel filter (All, NBA, NFL, ...).
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_LiveTvDesign.radiusPill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
                color: selected
                    ? _LiveTvDesign.primaryCta
                    : (isDark ? _LiveTvDesign.bgSurfaceDark : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(_LiveTvDesign.radiusPill),
            border: Border.all(
              color: selected
                  ? _LiveTvDesign.primaryCta
                  : (isDark
                      ? _LiveTvDesign.borderSubtle
                      : Colors.grey.shade400),
              width: selected ? 0 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? _LiveTvDesign.textPrimary
                    : (isDark
                        ? _LiveTvDesign.textPrimary
                        : Colors.grey.shade800),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerWrapper extends StatefulWidget {
  final StartAppBannerAd ad;
  const _BannerWrapper({required this.ad});

  @override
  State<_BannerWrapper> createState() => _BannerWrapperState();
}

class _BannerWrapperState extends State<_BannerWrapper> {
  late Widget _bannerWidget;

  @override
  void initState() {
    super.initState();
    _bannerWidget = StartAppBanner(widget.ad);
  }

  @override
  void didUpdateWidget(_BannerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ad != widget.ad) {
      _bannerWidget = StartAppBanner(widget.ad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 50,
        child: Center(
          child: _bannerWidget,
        ),
      ),
    );
  }
}
