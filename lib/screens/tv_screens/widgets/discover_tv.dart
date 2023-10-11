import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/dropdown_select.dart';
import 'package:caffiene/models/filter_chip.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_detail_page.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class DiscoverTV extends StatefulWidget {
  final bool includeAdult;
  const DiscoverTV({required this.includeAdult, Key? key}) : super(key: key);
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
    List<String> years = yearDropdownData.yearsList.getRange(1, 25).toList();
    List<TVGenreFilterChipWidget> genres = tvGenreList;
    years.shuffle();
    genres.shuffle();
    tvApi().fetchTV('$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&first_air_date_year=${years.first}&with_genres=${genres.first.genreValue}')
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
              ? discoverMoviesAndTVShimmer1(isDark)
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
                          (BuildContext context, int index, pageViewIndex) {
                        return Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TVDetailPage(
                                          tvSeries: tvList![index],
                                          heroId: '${tvList![index].id}')));
                            },
                            child: Hero(
                              tag: '${tvList![index].id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: tvList![index].posterPath == null
                                      ? ''
                                      : TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          tvList![index].posterPath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      discoverImageShimmer1(isDark),
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
