// ignore_for_file: unused_field

import 'package:reelriot/models/choice_chip.dart';
import 'package:reelriot/models/dropdown_select.dart';
import 'package:reelriot/models/filter_chip.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/discover_screens/discover_movie_result.dart';
import 'package:reelriot/utils/constant.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ── Design tokens (design.json) ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);

  static const bgElevatedDark = Color(0x0DFFFFFF);
  static const bgElevatedLight = Color(0xFFF1F5F9);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);
}

class DiscoverMoviesTab extends StatefulWidget {
  const DiscoverMoviesTab({super.key});

  @override
  State<DiscoverMoviesTab> createState() => _DiscoverMoviesTabState();
}

class _DiscoverMoviesTabState extends State<DiscoverMoviesTab> {
  YearDropdownData yearDropdownData = YearDropdownData();
  int sortValue = 0;
  int adultValue = 1;
  String moviesSort = 'popularity.desc';
  bool includeAdult = false;
  String defaultMovieReleaseYear = '';
  double movieTotalRatingSlider = 1;
  bool enableOptionForSliderMovie = false;
  String joinedIds = '';
  String joinedProviderIds = '';
  final List<String> genreNames = <String>[];
  final List<String> genreIds = <String>[];
  final List<String> providersName = <String>[];
  final List<String> providersId = <String>[];

  void setSliderValue(newValue) =>
      setState(() => movieTotalRatingSlider = newValue);
  void joinGenreStrings() => setState(() => joinedIds = genreIds.join(','));
  void joinProviderStrings() =>
      setState(() => joinedProviderIds = providersId.join(','));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevated = isDark ? _C.bgElevatedDark : _C.bgElevatedLight;
    final border = isDark ? _C.borderDark : _C.borderLight;
    final textPrim = isDark ? _C.textPrimDark : _C.textPrimLight;
    final textSec = isDark ? _C.textSecDark : _C.textSecLight;

    final sortChoiceChip = <SortChoiceChipWidget>[
      SortChoiceChipWidget(
          name: tr('popularity_descending'),
          value: 'popularity.desc',
          index: 0),
      SortChoiceChipWidget(
          name: tr('popularity_ascending'), value: 'popularity.asc', index: 1),
      SortChoiceChipWidget(
          name: tr('average_vote_descending'),
          value: 'vote_average.desc',
          index: 2),
      SortChoiceChipWidget(
          name: tr('average_vote_ascending'),
          value: 'vote_average.asc',
          index: 3),
    ];

    final adultChoiceChip = <AdultChoiceChipWidget>[
      AdultChoiceChipWidget(name: tr('yes'), value: true, index: 0),
      AdultChoiceChipWidget(name: tr('no'), value: false, index: 1),
    ];

    final movieGenreFilterdata = <MovieGenreFilterChipWidget>[
      MovieGenreFilterChipWidget(genreName: tr('action'), genreValue: '28'),
      MovieGenreFilterChipWidget(genreName: tr('adventure'), genreValue: '12'),
      MovieGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
      MovieGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
      MovieGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
      MovieGenreFilterChipWidget(
          genreName: tr('documentary'), genreValue: '99'),
      MovieGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
      MovieGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
      MovieGenreFilterChipWidget(genreName: tr('fantasy'), genreValue: '14'),
      MovieGenreFilterChipWidget(genreName: tr('history'), genreValue: '36'),
      MovieGenreFilterChipWidget(genreName: tr('horror'), genreValue: '27'),
      MovieGenreFilterChipWidget(genreName: tr('music'), genreValue: '10402'),
      MovieGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
      MovieGenreFilterChipWidget(genreName: tr('romance'), genreValue: '10749'),
      MovieGenreFilterChipWidget(
          genreName: tr('science_fiction'), genreValue: '878'),
      MovieGenreFilterChipWidget(
          genreName: tr('tv_movie'), genreValue: '10770'),
      MovieGenreFilterChipWidget(genreName: tr('thriller'), genreValue: '53'),
      MovieGenreFilterChipWidget(genreName: tr('war'), genreValue: '10752'),
      MovieGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
    ];

    final providerFilterData = <WatchProvidersFilterChipWidget>[
      WatchProvidersFilterChipWidget(networkName: 'Netflix', networkId: '8'),
      WatchProvidersFilterChipWidget(
          networkName: 'Amazon Prime', networkId: '9'),
      WatchProvidersFilterChipWidget(
          networkName: 'Disney Plus', networkId: '337'),
      WatchProvidersFilterChipWidget(networkName: 'hulu', networkId: '15'),
      WatchProvidersFilterChipWidget(networkName: 'HBO Max', networkId: '384'),
      WatchProvidersFilterChipWidget(
          networkName: 'Apple TV plus', networkId: '350'),
      WatchProvidersFilterChipWidget(networkName: 'Peacock', networkId: '387'),
      WatchProvidersFilterChipWidget(networkName: 'iTunes', networkId: '2'),
      WatchProvidersFilterChipWidget(
          networkName: 'YouTube Premium', networkId: '188'),
      WatchProvidersFilterChipWidget(
          networkName: 'Paramount Plus', networkId: '531'),
      WatchProvidersFilterChipWidget(
          networkName: 'Netflix Kids', networkId: '175'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterSection(
            title: tr("sort_by"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortChoiceChip
                  .map((c) => _Chip(
                        label: c.name,
                        selected: sortValue == c.index,
                        elevated: elevated,
                        border: border,
                        textPrim: textPrim,
                        textSec: textSec,
                        onSelected: () => setState(() {
                          sortValue = c.index;
                          moviesSort = c.value;
                        }),
                      ))
                  .toList(),
            ),
          ),
          _FilterSection(
            title: tr("include_adult"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: adultChoiceChip
                  .map((c) => _Chip(
                        label: c.name,
                        selected: adultValue == c.index,
                        elevated: elevated,
                        border: border,
                        textPrim: textPrim,
                        textSec: textSec,
                        onSelected: () => setState(() {
                          adultValue = c.index;
                          includeAdult = c.value;
                        }),
                      ))
                  .toList(),
            ),
          ),
          _FilterSection(
            title: tr("release_year"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: elevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: defaultMovieReleaseYear,
                  items: yearDropdownData.yearsList
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text(y.isEmpty ? tr('any') : y,
                                style:
                                    TextStyle(color: textPrim, fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => defaultMovieReleaseYear = v ?? ''),
                  dropdownColor: isDark
                      ? const Color(0xFF0B0F14)
                      : const Color(0xFFF1F5F9),
                ),
              ),
            ),
          ),
          _FilterSection(
            title: tr("total_ratings"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                            tr("ratings_count", namedArgs: {
                              "r": movieTotalRatingSlider.toInt().toString()
                            }),
                            style: TextStyle(color: textSec, fontSize: 13))),
                    Checkbox(
                      activeColor: _C.primary,
                      value: enableOptionForSliderMovie,
                      onChanged: (v) => setState(() {
                        enableOptionForSliderMovie = v ?? false;
                        movieTotalRatingSlider = 0;
                      }),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _C.primary,
                    inactiveTrackColor: border,
                    thumbColor: _C.primary,
                  ),
                  child: Slider(
                    value: movieTotalRatingSlider,
                    onChanged:
                        enableOptionForSliderMovie ? setSliderValue : null,
                    min: 0,
                    max: 30000,
                  ),
                ),
              ],
            ),
          ),
          _FilterSection(
            title: tr("with_genres"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movieGenreFilterdata
                  .map((c) => _Chip(
                        label: c.genreName,
                        selected: genreNames.contains(c.genreName),
                        elevated: elevated,
                        border: border,
                        textPrim: textPrim,
                        textSec: textSec,
                        onSelected: () {
                          setState(() {
                            if (genreNames.contains(c.genreName)) {
                              genreNames.remove(c.genreName);
                              genreIds.remove(c.genreValue);
                            } else {
                              genreNames.add(c.genreName);
                              genreIds.add(c.genreValue);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          _FilterSection(
            title: tr("with_streaming_services"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: providerFilterData
                  .map((c) => _Chip(
                        label: c.networkName,
                        selected: providersName.contains(c.networkName),
                        elevated: elevated,
                        border: border,
                        textPrim: textPrim,
                        textSec: textSec,
                        onSelected: () {
                          setState(() {
                            if (providersName.contains(c.networkName)) {
                              providersName.remove(c.networkName);
                              providersId.remove(c.networkId);
                            } else {
                              providersName.add(c.networkName);
                              providersId.add(c.networkId);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                joinGenreStrings();
                joinProviderStrings();
                final lang =
                    Provider.of<SettingsProvider>(context, listen: false)
                        .appLanguage;
                final region =
                    Provider.of<SettingsProvider>(context, listen: false)
                        .defaultCountry;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DiscoverMovieResult(
                              api:
                                  '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&language=$lang&sort_by=$moviesSort&watch_region=$region&include_adult=$includeAdult&primary_release_year=$defaultMovieReleaseYear&vote_count.gte=${movieTotalRatingSlider.toInt()}&with_genres=$joinedIds&with_watch_providers=$joinedProviderIds',
                              page: 1,
                              includeAdult: includeAdult,
                            )));
              },
              style: FilledButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 18),
                  const SizedBox(width: 10),
                  Text(tr("discover"),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PoppinsSB')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.child,
    required this.elevated,
    required this.border,
    required this.textPrim,
  });

  final String title;
  final Widget child;
  final Color elevated;
  final Color border;
  final Color textPrim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textPrim,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.elevated,
    required this.border,
    required this.textPrim,
    required this.textSec,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Color elevated;
  final Color border;
  final Color textPrim;
  final Color textSec;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withValues(alpha: 0.2) : elevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? _C.primary : border, width: selected ? 1.2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _C.primary : textSec,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
