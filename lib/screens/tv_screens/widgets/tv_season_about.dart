import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/episode_list_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_season_images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class TVSeasonAbout extends StatefulWidget {
  const TVSeasonAbout({
    Key? key,
    required this.season,
    required this.tvDetails,
    required this.seriesName,
  }) : super(key: key);

  final Seasons season;
  final TVDetails tvDetails;
  final String? seriesName;

  @override
  State<TVSeasonAbout> createState() => _TVSeasonAboutState();
}

class _TVSeasonAboutState extends State<TVSeasonAbout> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    tr("overview"),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadMoreText(
                widget.season.overview!.isEmpty
                    ? tr("no_season_overview")
                    : widget.season.overview!,
                trimLines: 4,
                style: const TextStyle(fontFamily: 'Poppins'),
                colorClickableText: Theme.of(context).colorScheme.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: tr("read_more"),
                trimExpandedText: tr("read_less"),
                lessStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                moreStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    widget.season.airDate == null
                        ? tr("no_first_episode_air_date")
                        : tr("first_episode_air_date", namedArgs: {
                            "day": DateTime.parse(widget.season.airDate!)
                                .day
                                .toString(),
                            "date": DateFormat("MMMM")
                                .format(DateTime.parse(widget.season.airDate!)),
                            "year": DateTime.parse(widget.season.airDate!)
                                .year
                                .toString()
                          }),
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            ScrollingTVArtists(
              id: widget.tvDetails.id!,
              seasonNumber: widget.season.seasonNumber,
              passedFrom: 'seasons_detail',
              api: Endpoints.getTVSeasonCreditsUrl(
                  widget.tvDetails.id!, widget.season.seasonNumber!, lang),
              title: 'Cast',
            ),
            EpisodeListWidget(
              seriesName: widget.seriesName,
              tvId: widget.tvDetails.id,
              api: Endpoints.getSeasonDetails(
                  widget.tvDetails.id!, widget.season.seasonNumber!, lang),
              posterPath: widget.season.posterPath,
            ),
            TVSeasonImagesDisplay(
              title: tr("images"),
              name: '${widget.seriesName}_season_${widget.season.seasonNumber}',
              api: Endpoints.getTVSeasonImagesUrl(
                  widget.tvDetails.id!, widget.season.seasonNumber!),
            ),
            // TVVideosDisplay(
            //   api: Endpoints.getTVSeasonVideosUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            //   title: 'Videos',
            // ),

            // TVCastTab(
            //   api: Endpoints.getFullTVSeasonCreditsUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
            // TVCrewTab(
            //   api: Endpoints.getFullTVSeasonCreditsUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
          ],
        ),
      ),
    );
  }
}
