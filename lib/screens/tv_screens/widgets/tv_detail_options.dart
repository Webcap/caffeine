import 'package:flutter/material.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const ratingGold = Color(0xFFEAB308);

  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF475569);
}

class TVDetailOptions extends StatefulWidget {
  const TVDetailOptions({super.key, required this.tvSeries});

  final TV tvSeries;

  @override
  State<TVDetailOptions> createState() => _TVDetailOptionsState();
}

class _TVDetailOptionsState extends State<TVDetailOptions> {
  bool? isBookmarked;
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
    });
  }

  Future<void> _fetchDetails() async {
    final lang = Provider.of<SettingsProvider>(context, listen: false).appLanguage;
    final isProxyEnabled = Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    final api = Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang);
    
    final details = await fetchTVDetails(api, isProxyEnabled, proxyUrl);
    if (mounted) {
      setState(() => tvDetails = details);
    }
  }

  Future<void> _checkBookmark() async {
    final provider = Provider.of<BookmarksProvider>(context, listen: false);
    final b = await provider.containsTV(widget.tvSeries.id!);
    if (mounted) setState(() => isBookmarked = b);
    if (mounted && b) await provider.updateTV(widget.tvSeries);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;

    final avg = widget.tvSeries.voteAverage;
    final ratingStr = avg != null && avg > 0
        ? (avg == avg.truncateToDouble()
            ? avg.toStringAsFixed(0)
            : avg.toStringAsFixed(1))
        : null;


    return Consumer<BookmarksProvider>(
      builder: (context, provider, _) {
        // ── Format Genres ───────────────────────────────────────────────
        final genres = tvDetails?.genres?.map((g) => g.genreName).where((n) => n != null && n.isNotEmpty).take(3).join('  •  ');
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Genres Row ────────────────────────────────────────────
              if (genres != null && genres.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    genres,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSec,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
              // ── Meta Row + Heart ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Meta items
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (tvDetails?.numberOfSeasons != null && tvDetails!.numberOfSeasons! > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.layers_rounded, size: 14, color: textSec),
                              const SizedBox(width: 4),
                              Text(
                                '${tvDetails!.numberOfSeasons} ${tvDetails!.numberOfSeasons == 1 ? tr("season") : tr("seasons")}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textSec,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          
                        // Hardcoded for UI showcase as per screenshot
                        _Badge(text: 'TV-14', textSec: textSec, border: border, elevated: elevated),
                        _Badge(text: 'FHD', textSec: textSec, border: border, elevated: Colors.red.withValues(alpha: 0.2), textColor: _C.primary),
                        
                        if (ratingStr != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _C.ratingGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'IMDb - $ratingStr/10',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _C.ratingGold,
                                fontFamily: 'PoppinsSB',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Bookmark button
                  GestureDetector(
                    onTap: () async {
                      if (isBookmarked == false) {
                        try {
                          await provider.addTV(widget.tvSeries);
                          if (mounted) setState(() => isBookmarked = true);
                        } catch (_) {
                          if (mounted && provider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage!)),
                            );
                            provider.clearError();
                          }
                        }
                      } else if (isBookmarked == true) {
                        try {
                          await provider.removeTV(widget.tvSeries.id!);
                          if (mounted) setState(() => isBookmarked = false);
                        } catch (_) {
                          if (mounted && provider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage!)),
                            );
                            provider.clearError();
                          }
                        }
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: elevated,
                        border: Border.all(color: border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: (isBookmarked == true
                                    ? _C.primary
                                    : Colors.transparent)
                                .withValues(alpha: 0.2),
                            blurRadius: isBookmarked == true ? 10 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        isBookmarked == true
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isBookmarked == true ? _C.primary : textSec,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color textSec;
  final Color border;
  final Color elevated;
  final Color? textColor;

  const _Badge({
    required this.text,
    required this.textSec,
    required this.border,
    required this.elevated,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor ?? textSec,
          fontFamily: 'PoppinsSB',
        ),
      ),
    );
  }
}
