import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/models/credits.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/person/guest_star_details.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TVEpisodeGuestStarsTab extends StatefulWidget {
  final String? api;
  const TVEpisodeGuestStarsTab({Key? key, this.api}) : super(key: key);

  @override
  TVEpisodeGuestStarsTabState createState() => TVEpisodeGuestStarsTabState();
}

class TVEpisodeGuestStarsTabState extends State<TVEpisodeGuestStarsTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeGuestStarsTab> {
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
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(
            padding: const EdgeInsets.all(8),
            child: searchedPersonShimmer(isDark))
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'There is no data available for this TV episode Guest stars',
                      style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.episodeGuestStars!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return GuestStarDetailPage(
                                  cast: credits!.episodeGuestStars![index],
                                  heroId:
                                      '${credits!.episodeGuestStars![index].creditId}');
                            }));
                          },
                          child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 5.0,
                                  left: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20.0, left: 10),
                                          child: SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Hero(
                                              tag:
                                                  '${credits!.episodeGuestStars![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: credits!
                                                            .episodeGuestStars![
                                                                index]
                                                            .profilePath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_rect.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
                                                        fadeOutDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        fadeOutCurve:
                                                            Curves.easeOut,
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    700),
                                                        fadeInCurve:
                                                            Curves.easeIn,
                                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .episodeGuestStars![
                                                                    index]
                                                                .profilePath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer1(
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                credits!
                                                    .episodeGuestStars![index]
                                                    .name!,
                                                style: const TextStyle(
                                                    fontFamily: 'PoppinsSB',
                                                    fontSize: 20),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: !isDark
                                          ? Colors.black54
                                          : Colors.white54,
                                      thickness: 1,
                                      endIndent: 20,
                                      indent: 10,
                                    ),
                                  ],
                                ),
                              )));
                    }));
  }

  Widget searchedPersonShimmer(isDark) => ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 3.0,
            bottom: 3.0,
            left: 15,
          ),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor:
                    isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                direction: ShimmerDirection.ltr,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 140,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                color: !isDark ? Colors.black54 : Colors.white54,
                thickness: 1,
                endIndent: 20,
                indent: 10,
              ),
            ],
          ),
        );
      });

  @override
  bool get wantKeepAlive => true;
}
