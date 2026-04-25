import 'package:reelriot/functions/functions.dart';
import 'package:reelriot/widgets/cached_image.dart';
import 'package:reelriot/functions/network.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/models/dropdown_select.dart';
import 'package:reelriot/models/filter_chip.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/tv_detail_page.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:reelriot/utils/constant.dart';

class DiscoverTV extends StatefulWidget {
  final bool includeAdult;
  const DiscoverTV(
      {required this.includeAdult, required this.discoverType, super.key});

  final String discoverType;
  @override
  DiscoverTVState createState() => DiscoverTVState();
}

class DiscoverTVState extends State<DiscoverTV>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;
  List<TV>? tvList;
  YearDropdownData yearDropdownData = YearDropdownData();

  @override
  void initState() {
    super.initState();
    getData();
  }

  List<TVGenreFilterChipWidget> tvGenreList = <TVGenreFilterChipWidget>[
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

  void getData() {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    List<String> years = yearDropdownData.yearsList.getRange(1, 26).toList();
    List<TVGenreFilterChipWidget> genres = tvGenreList;
    years.shuffle();
    genres.shuffle();
    fetchTV('$tmdbApiBaseUrl/discover/tv?api_key=$tmdbApiKey&sort_by=popularity.desc&watch_region=US&first_air_date_year=${years.first}&with_genres=${genres.first.genreValue}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr("featured_tv_shows"),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 350,
          child: tvList == null
              ? discoverMoviesAndTVShimmer(themeMode)
              : tvList!.isEmpty
                  ? Center(
                      child: Text(
                        tr("wow_odd"),
                        style: kTextSmallBodyStyle,
                      ),
                    )
                  : CarouselSlider.builder(
                      options: CarouselOptions(
                        disableCenter: true,
                        viewportFraction: 0.6,
                        enlargeCenterPage: true,
                        autoPlay: true,
                      ),
                      itemBuilder:
                          (BuildContext context, int index, int pageViewIndex) {
                        final heroTag =
                            '${tvList![index].id}-${widget.discoverType}-$index-$pageViewIndex';
                        return Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TVDetailPage(
                                          tvSeries: tvList![index],
                                          heroId: heroTag)));
                            },
                            child: Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedPosterImage(
                                  cacheManager: cacheProp(),
                                  preset: CachePreset.posterLarge,
                                  imageUrl: tvList![index].posterPath == null
                                      ? ''
                                      : buildImageUrl(
                                              tmdbBaseImageUrl,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          tvList![index].posterPath!,
                                  themeMode: themeMode,
                                  placeholder: (context, url) =>
                                      discoverImageShimmer(themeMode),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: tvList!.length,
                    ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
