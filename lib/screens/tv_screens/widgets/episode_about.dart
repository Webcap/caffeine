import 'package:flutter/material.dart';
import 'package:login/api/endpoints.dart';
import 'package:login/api/tv_api.dart';
import 'package:login/models/tv.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/tv_screens/tv_video_loader.dart';
import 'package:login/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:login/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class EpisodeAbout extends StatefulWidget {
  const EpisodeAbout({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
  }) : super(key: key);
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;

  @override
  State<EpisodeAbout> createState() => _EpisodeAboutState();
}

class _EpisodeAboutState extends State<EpisodeAbout> {
  bool? isVisible = false;
  double? buttonWidth = 180;
  TVDetails? tvDetails;

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: const <Widget>[
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
                widget.episodeList.overview!.isEmpty
                    ? 'This episode doesn\'t have an overview'
                    : widget.episodeList.overview!,
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
                    widget.episodeList.airDate == null ||
                            widget.episodeList.airDate!.isEmpty
                        ? 'Episode air date: N/A'
                        : 'Episode air date:  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: TextButton(
                style: ButtonStyle(
                    maximumSize:
                        MaterialStateProperty.all(Size(buttonWidth!, 50)),
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    )),
                onPressed: () async {
                  mixpanel.track('Most viewed TV series', properties: {
                    'TV series name': '${widget.seriesName}',
                    'TV series id': '${widget.tvId}',
                    'TV series episode name': '${widget.episodeList.name}',
                    'TV series season number':
                        '${widget.episodeList.seasonNumber}',
                    'TV series episode number':
                        '${widget.episodeList.episodeNumber}'
                  });
                  setState(() {
                    isVisible = true;
                  });
                  tvApi().fetchTVDetails(Endpoints.tvDetailsUrl(widget.tvId!))
                      .then((value) {
                    if (mounted) {
                      setState(() {
                        isVisible = false;
                        tvDetails = value;
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TVVideoLoader(
                            videoTitle: widget.seriesName!,
                            thumbnail: value.backdropPath,
                            seasons: value.numberOfSeasons!,
                            episodeNumber: widget.episodeList.episodeNumber!,
                            seasonNumber: widget.episodeList.seasonNumber!,
                          );
                        }));
                      });
                    }
                  });
                },
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.play_circle,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'WATCH NOW',
                      style: TextStyle(color: Colors.white),
                    ),
                    Visibility(
                      visible: isVisible!,
                      child: const Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ScrollingTVEpisodeCasts(
              passedFrom: 'episode_detail',
              seasonNumber: widget.episodeList.seasonNumber!,
              episodeNumber: widget.episodeList.episodeNumber!,
              id: widget.tvId,
              api: Endpoints.getEpisodeCredits(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
            ),
            // TVEpisodeImagesDisplay(
            //   title: 'Images',
            //   name: '${widget.seriesName}_${widget.episodeList.name}',
            //   api: Endpoints.getTVEpisodeImagesUrl(
            //       widget.tvId!,
            //       widget.episodeList.seasonNumber!,
            //       widget.episodeList.episodeNumber!),
            // ),
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
