import 'package:reelriot/models/movie_models.dart';
import 'package:reelriot/models/recently_watched.dart';
import 'package:reelriot/provider/bookmarks_provider.dart';
import 'package:reelriot/provider/recently_watched_provider.dart';
import 'package:flutter/material.dart';
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

class MovieDetailOptions extends StatefulWidget {
  const MovieDetailOptions({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailOptions> createState() => _MovieDetailOptionsState();
}

class _MovieDetailOptionsState extends State<MovieDetailOptions> {
  bool? isBookmarked;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final provider = Provider.of<BookmarksProvider>(context, listen: false);
    final b = await provider.containsMovie(widget.movie.id!);
    if (mounted) setState(() => isBookmarked = b);
    if (mounted && b) await provider.updateMovie(widget.movie);
  }

  Future<void> _toggleWatched(bool isWatched) async {
    final recentProvider = Provider.of<RecentProvider>(context, listen: false);
    if (isWatched) {
      await recentProvider.deleteMovie(widget.movie.id!);
    } else {
      final year = widget.movie.releaseDate != null &&
              widget.movie.releaseDate!.isNotEmpty
          ? DateTime.tryParse(widget.movie.releaseDate!)?.year
          : null;
      await recentProvider.addMovie(RecentMovie(
        id: widget.movie.id,
        title: widget.movie.title,
        posterPath: widget.movie.posterPath,
        backdropPath: widget.movie.backdropPath,
        releaseYear: year,
        elapsed: 1,
        remaining: 0,
        dateTime: DateTime.now().toIso8601String(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;

    final avg = widget.movie.voteAverage;
    final ratingStr = avg != null && avg > 0
        ? (avg == avg.truncateToDouble()
            ? avg.toStringAsFixed(0)
            : avg.toStringAsFixed(1))
        : null;
    final voteCount = widget.movie.voteCount ?? 0;

    return Consumer<RecentProvider>(
      builder: (context, recentProvider, child) {
        final matches =
            recentProvider.movies.where((m) => m.id == widget.movie.id);
        final recentMovie = matches.isEmpty ? null : matches.first;
        bool isWatched = false;
        if (recentMovie != null) {
          final elapsed = recentMovie.elapsed ?? 0;
          final remaining = recentMovie.remaining ?? 0;
          final total = elapsed + remaining;
          isWatched = total > 0 && (elapsed / total) >= 0.9;
        }

        return Consumer<BookmarksProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // ── Rating badges (compact capsules) ─────────────────────────
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (ratingStr != null)
                          _RatingChip(
                            icon: Icons.star_rounded,
                            value: '$ratingStr/10',
                            accentColor: _C.ratingGold,
                            elevated: elevated,
                            border: border,
                            textSec: textSec,
                          ),
                        _RatingChip(
                          icon: Icons.people_outline_rounded,
                          value: voteCount.toString(),
                          accentColor: _C.primary.withValues(alpha: 0.9),
                          elevated: elevated,
                          border: border,
                          textSec: textSec,
                        ),
                      ],
                    ),
                  ),

                  // ── Favorite heart (design.json: favoriteAction) ─────────────
                  GestureDetector(
                    onTap: () async {
                      if (widget.movie.id != null) {
                        if (isBookmarked == false) {
                          try {
                            await provider.addMovie(widget.movie);
                            if (mounted) setState(() => isBookmarked = true);
                          } catch (_) {}
                        } else if (isBookmarked == true) {
                          try {
                            await provider.removeMovie(widget.movie.id!);
                            if (mounted) setState(() => isBookmarked = false);
                          } catch (_) {}
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
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isBookmarked == true ? _C.primary : textSec,
                      ),
                    ),
                  ),

                  // ── Watched toggle ───────────────────────────────────────────
                  GestureDetector(
                    onTap: () => _toggleWatched(isWatched),
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: elevated,
                        border: Border.all(color: border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: (isWatched ? Colors.green : Colors.transparent)
                                .withValues(alpha: 0.2),
                            blurRadius: isWatched ? 10 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWatched
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                        color: isWatched ? Colors.green : textSec,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RatingChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color accentColor;
  final Color elevated;
  final Color border;
  final Color textSec;

  const _RatingChip({
    required this.icon,
    required this.value,
    required this.accentColor,
    required this.elevated,
    required this.border,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSec,
            ),
          ),
        ],
      ),
    );
  }
}
