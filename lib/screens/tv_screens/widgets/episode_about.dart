import 'package:caffiene/screens/tv_screens/widgets/tv_epi_image.dart';
import 'package:caffiene/screens/tv_screens/widgets/watch_now_tv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_video_loader.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class EpisodeAbout extends StatefulWidget {
  const EpisodeAbout({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    required this.posterPath,
    this.seriesName,
  }) : super(key: key);
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  @override
  State<EpisodeAbout> createState() => _EpisodeAboutState();
}

class _EpisodeAboutState extends State<EpisodeAbout> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                widget.episodeList.overview!.isEmpty
                    ? ''
                    : widget.episodeList.overview!,
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
                    widget.episodeList.airDate == null ||
                            widget.episodeList.airDate!.isEmpty
                        ? tr("episode_air_empty")
                        : '${tr("episode_air")}  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            WatchNowButtonTV(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName!,
              tvId: widget.tvId!,
              posterPath: widget.posterPath!,
            ),
            const SizedBox(height: 15),
            ScrollingTVEpisodeCasts(
              passedFrom: 'episode_detail',
              seasonNumber: widget.episodeList.seasonNumber!,
              episodeNumber: widget.episodeList.episodeNumber!,
              id: widget.tvId,
              api: Endpoints.getEpisodeCredits(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!,
                  lang),
            ),
            TVEpisodeImagesDisplay(
              title: tr("images"),
              name: '${widget.seriesName}_${widget.episodeList.name}',
              api: Endpoints.getTVEpisodeImagesUrl(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
            ),
            // TVVideosDisplay(
            //   api: Endpoints.getTVEpisodeVideosUrl(
            //       widget.tvId!,
            //       widget.episodeList.seasonNumber!,
            //       widget.episodeList.episodeNumber!),
            //   title: 'Videos',
            // ),
          ],
        ),
      ),
    );
  }
}
