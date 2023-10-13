import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/movie_screens/cast_details.dart';
import 'package:caffiene/screens/movie_screens/movie_cast_crew_details.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class ScrollingArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  ScrollingArtistsState createState() => ScrollingArtistsState();
}

class ScrollingArtistsState extends State<ScrollingArtists> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        credits == null
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(
                              tr("cast"),
                              style: kTextHeaderStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : credits!.cast!.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const LeadingDot(),
                            Expanded(
                              child: Text(
                                tr("cast"),
                                style: kTextHeaderStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                          child: Text(tr("no_cast_movie"),
                              textAlign: TextAlign.center)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr("cast"),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (credits != null) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MovieCastAndCrew(credits: credits!);
                            }));
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          maximumSize:
                              MaterialStateProperty.all(const Size(200, 60)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: Text(tr("see_all_cast_crew")),
                      )
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? detailCastShimmer1(isDark)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.cast!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                              cast: credits!.cast![index],
                              heroId: '${credits!.cast![index].id}'
                                  '${credits!.cast![index].creditId}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Hero(
                                  tag: '${credits!.cast![index].id}',
                                  child: SizedBox(
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!
                                                  .cast![index].profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_rect.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              cacheManager: cacheProp(),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!.cast![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  detailCastImageShimmer1(
                                                      isDark),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.cast![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
