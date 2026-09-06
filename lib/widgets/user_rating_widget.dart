import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/ratings_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:reelriot/widgets/bouncing_tappable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class _RatingDesign {
  static const ratingGold = Color(0xFFEAB308);
  static const bgDark = Color(0xFF0F172A);
  static const bgSurfaceDark = Color(0xFF1E293B);
  static const borderDark = Color(0xFF334155);
  static const borderLight = Color(0xFFE2E8F0);
  static const textSecDark = Color(0xFF94A3B8);
  static const textSecLight = Color(0xFF64748B);
  static const danger = Color(0xFFEF4444);
}

/// A compact, tactile interactive chip displaying the user's rating (1-10)
/// or a "+ Rate" trigger if unrated.
class UserRatingButton extends StatelessWidget {
  final String mediaType;
  final int mediaId;
  final String title;
  final int? seasonNum;
  final int? episodeNum;

  const UserRatingButton({
    super.key,
    required this.mediaType,
    required this.mediaId,
    required this.title,
    this.seasonNum,
    this.episodeNum,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark
        ? _RatingDesign.bgSurfaceDark
        : Colors.white;
    final border = isDark
        ? _RatingDesign.borderDark
        : _RatingDesign.borderLight;
    final textSec = isDark
        ? _RatingDesign.textSecDark
        : _RatingDesign.textSecLight;

    return Consumer<RatingsProvider>(
      builder: (context, ratingsProvider, _) {
        final currentRating = ratingsProvider.getRating(
          mediaType,
          mediaId,
          seasonNum: seasonNum,
          episodeNum: episodeNum,
        );
        final isRated = currentRating != null;

        return BouncingTappable(
          onTap: () {
            _showRatingSheet(context, currentRating);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isRated
                  ? _RatingDesign.ratingGold.withValues(alpha: 0.18)
                  : elevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isRated
                    ? _RatingDesign.ratingGold.withValues(alpha: 0.4)
                    : border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRated ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14,
                  color: isRated ? _RatingDesign.ratingGold : textSec,
                ),
                const SizedBox(width: 4),
                Text(
                  isRated ? 'You - $currentRating/10' : 'Rate',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isRated ? _RatingDesign.ratingGold : textSec,
                    fontFamily: 'PoppinsSB',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingSheet(BuildContext context, int? initialRating) {
    final auth = Supabase.instance.client.auth;
    if (auth.currentUser == null) {
      _showSignInPrompt(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _RatingModalSheet(
        mediaType: mediaType,
        mediaId: mediaId,
        title: title,
        seasonNum: seasonNum,
        episodeNum: episodeNum,
        initialRating: initialRating,
      ),
    );
  }

  void _showSignInPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Please sign in to rate movies and TV shows!',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        action: SnackBarAction(
          label: 'Sign In',
          textColor: Colors.amber,
          onPressed: () {
            Get.toNamed(Routes.login);
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _RatingModalSheet extends StatefulWidget {
  final String mediaType;
  final int mediaId;
  final String title;
  final int? seasonNum;
  final int? episodeNum;
  final int? initialRating;

  const _RatingModalSheet({
    required this.mediaType,
    required this.mediaId,
    required this.title,
    this.seasonNum,
    this.episodeNum,
    this.initialRating,
  });

  @override
  State<_RatingModalSheet> createState() => _RatingModalSheetState();
}

class _RatingModalSheetState extends State<_RatingModalSheet> {
  int? _selectedRating;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  static const _labels = [
    'Appalling',
    'Horrible',
    'Very Bad',
    'Bad',
    'Average',
    'Fine',
    'Good',
    'Very Good',
    'Great',
    'Masterpiece',
  ];

  Future<void> _submit(int rating) async {
    setState(() {
      _selectedRating = rating;
      _isSaving = true;
    });
    HapticFeedback.mediumImpact();

    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final ratingsProvider =
        Provider.of<RatingsProvider>(context, listen: false);

    final success = await ratingsProvider.setRating(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      rating: rating,
      seasonNum: widget.seasonNum,
      episodeNum: widget.episodeNum,
      caffeineBaseUrl: appDep.caffeineAPIURL,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rated $rating/10!'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save rating. Please try again.'),
            backgroundColor: _RatingDesign.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _remove() async {
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    final ratingsProvider =
        Provider.of<RatingsProvider>(context, listen: false);

    final success = await ratingsProvider.deleteRating(
      mediaType: widget.mediaType,
      mediaId: widget.mediaId,
      seasonNum: widget.seasonNum,
      episodeNum: widget.episodeNum,
      caffeineBaseUrl: appDep.caffeineAPIURL,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Rating removed.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove rating.'),
            backgroundColor: _RatingDesign.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _RatingDesign.bgDark : Colors.white;
    final surface = isDark
        ? _RatingDesign.bgSurfaceDark
        : const Color(0xFFF1F5F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark
        ? _RatingDesign.textSecDark
        : _RatingDesign.textSecLight;

    final descriptor = (_selectedRating != null &&
            _selectedRating! >= 1 &&
            _selectedRating! <= 10)
        ? _labels[_selectedRating! - 1]
        : 'Select your rating';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              fontFamily: 'PoppinsSB',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Rating score + descriptor preview
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 24,
                color: _selectedRating != null
                    ? _RatingDesign.ratingGold
                    : textSec,
              ),
              const SizedBox(width: 6),
              Text(
                _selectedRating != null
                    ? '$_selectedRating / 10 · $descriptor'
                    : descriptor,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _selectedRating != null
                      ? _RatingDesign.ratingGold
                      : textSec,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1-10 Pill Selector Grid (2 rows of 5)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(10, (index) {
                final value = index + 1;
                final isSelected = _selectedRating == value;

                return BouncingTappable(
                  onTap: _isSaving ? null : () => _submit(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _RatingDesign.ratingGold
                          : surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _RatingDesign.ratingGold
                            : (isDark
                                ? _RatingDesign.borderDark
                                : _RatingDesign.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _RatingDesign.ratingGold
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.black : textPrimary,
                        fontFamily: 'PoppinsSB',
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Remove Rating button (if previously rated)
          if (widget.initialRating != null)
            TextButton.icon(
              onPressed: _isSaving ? null : _remove,
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: _RatingDesign.danger),
              label: const Text(
                'Remove Rating',
                style: TextStyle(
                  color: _RatingDesign.danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
