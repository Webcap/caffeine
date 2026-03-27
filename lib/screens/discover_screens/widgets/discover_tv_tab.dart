import 'package:caffiene/models/choice_chip.dart';
import 'package:caffiene/models/dropdown_select.dart';
import 'package:caffiene/models/filter_chip.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/discover_screens/discover_tv_result.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/widgets/common_widgets.dart';
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

class DiscoverTVTab extends StatefulWidget {
  const DiscoverTVTab({super.key});

  @override
  State<DiscoverTVTab> createState() => _DiscoverTVTabState();
}

class _DiscoverTVTabState extends State<DiscoverTVTab> {
  YearDropdownData yearDropdownData = YearDropdownData();
  int sortValue = 0;
  int tvStatusValue = 0;
  String tvSort = 'popularity.desc';
  String tvSeriesStatusValue = '';
  bool includeAdult = false;
  String defaultMovieReleaseYear = '';
  double tvTotalRatingSlider = 1;
  bool enableOptionForSliderMovie = false;
  String joinedIds = '';
  String joinedProviderIds = '';
  final List<String> genreNames = <String>[];
  final List<String> genreIds = <String>[];
  final List<String> providersName = <String>[];
  final List<String> providersId = <String>[];

  void setSliderValue(newValue) =>
      setState(() => tvTotalRatingSlider = newValue);
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

    final tvSeriesStatusList = <TVSeriesStatus>[
      TVSeriesStatus(statusId: '', statusName: tr('any'), index: 0),
      TVSeriesStatus(
          statusId: '0', statusName: tr('returning_series'), index: 1),
      TVSeriesStatus(statusId: '1', statusName: tr('planned'), index: 2),
      TVSeriesStatus(statusId: '2', statusName: tr('in_production'), index: 3),
      TVSeriesStatus(statusId: '3', statusName: tr('ended'), index: 4),
      TVSeriesStatus(statusId: '4', statusName: tr('cancelled'), index: 5),
      TVSeriesStatus(statusId: '5', statusName: tr('pilot'), index: 6),
    ];

    final tvGenreList = <TVGenreFilterChipWidget>[
      TVGenreFilterChipWidget(
          genreName: tr('action_and_adventure'), genreValue: '10759'),
      TVGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
      TVGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
      TVGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
      TVGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
      TVGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
      TVGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
      TVGenreFilterChipWidget(genreName: tr('kids'), genreValue: '10762'),
      TVGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
      TVGenreFilterChipWidget(genreName: tr('news'), genreValue: '10763'),
      TVGenreFilterChipWidget(genreName: tr('reality'), genreValue: '10764'),
      TVGenreFilterChipWidget(
          genreName: tr('scifi_and_fantasy'), genreValue: '10765'),
      TVGenreFilterChipWidget(genreName: tr('soap'), genreValue: '10766'),
      TVGenreFilterChipWidget(genreName: tr('talk'), genreValue: '10767'),
      TVGenreFilterChipWidget(
          genreName: tr('war_and_politics'), genreValue: '10768'),
      TVGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
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
                          tvSort = c.value;
                        }),
                      ))
                  .toList(),
            ),
          ),
          _FilterSection(
            title: tr("tv_series_status"),
            elevated: elevated,
            border: border,
            textPrim: textPrim,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tvSeriesStatusList
                  .map((c) => _Chip(
                        label: c.statusName,
                        selected: tvStatusValue == c.index,
                        elevated: elevated,
                        border: border,
                        textPrim: textPrim,
                        textSec: textSec,
                        onSelected: () => setState(() {
                          tvStatusValue = c.index;
                          tvSeriesStatusValue = c.statusId;
                        }),
                      ))
                  .toList(),
            ),
          ),
          _FilterSection(
            title: 'First air year',
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
                              "r": tvTotalRatingSlider.toInt().toString()
                            }),
                            style: TextStyle(color: textSec, fontSize: 13))),
                    Checkbox(
                      activeColor: _C.primary,
                      value: enableOptionForSliderMovie,
                      onChanged: (v) => setState(() {
                        enableOptionForSliderMovie = v ?? false;
                        tvTotalRatingSlider = 0;
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
                    value: tvTotalRatingSlider,
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
              children: tvGenreList
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
                        builder: (context) => DiscoverTVResult(
                              api:
                                  '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY&language=$lang&sort_by=$tvSort&watch_region=$region&include_adult=$includeAdult&with_status=$tvSeriesStatusValue&first_air_date_year=$defaultMovieReleaseYear&vote_count.gte=${tvTotalRatingSlider.toInt()}&with_genres=$joinedIds&with_watch_providers=$joinedProviderIds',
                              page: 1,
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
