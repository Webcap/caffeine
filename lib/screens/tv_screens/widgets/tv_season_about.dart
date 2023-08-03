import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:caffiene/utils/config.dart';
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
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            const Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Overview',
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadMoreText(
                widget.season.overview!.isEmpty
                    ? 'This season doesn\'t have an overview'
                    : widget.season.overview!,
                trimLines: 4,
                style: const TextStyle(fontFamily: 'Poppins'),
                colorClickableText: Theme.of(context).colorScheme.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'read more',
                trimExpandedText: 'read less',
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
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                    widget.season.airDate == null
                        ? 'First episode air date: N/A'
                        : 'First episode air date:  ${DateTime.parse(widget.season.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.season.airDate!))}, ${DateTime.parse(widget.season.airDate!).year}',
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
                  widget.tvDetails.id!, widget.season.seasonNumber!),
              title: 'Cast',
            ),
            // EpisodeListWidget(
            //   seriesName: widget.seriesName,
            //   tvId: widget.tvDetails.id,
            //   api: Endpoints.getSeasonDetails(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
            // TVSeasonImagesDisplay(
            //   title: 'Images',
            //   name: '${widget.seriesName}_season_${widget.season.seasonNumber}',
            //   api: Endpoints.getTVSeasonImagesUrl(
            //       widget.tvDetails.id!, widget.season.seasonNumber!),
            // ),
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
