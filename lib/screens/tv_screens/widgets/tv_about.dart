import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/similar_tv_tab.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_recc_tab.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_seasons_list.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_social_links.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/endpoints.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:caffiene/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class TVAbout extends StatefulWidget {
  const TVAbout({Key? key, required this.tvSeries}) : super(key: key);

  final TV tvSeries;

  @override
  State<TVAbout> createState() => _TVAboutState();
}

class _TVAboutState extends State<TVAbout> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      //  physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            TVGenreDisplay(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const LeadingDot(),
                        Expanded(
                          child: Text(
                            tr("overview"),
                            style: kTextHeaderStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.tvSeries.overview!.isEmpty ||
                      widget.tvSeries.overview == null
                  ? Text(tr("no_overview_tv"))
                  : ReadMoreText(
                      widget.tvSeries.overview!,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 4.0, right: 8.0),
                    child: Text(
                      widget.tvSeries.firstAirDate == null ||
                              widget.tvSeries.firstAirDate!.isEmpty
                          ? tr("first_episode_air_empty")
                          : '${tr("first_episode_air")} ${DateTime.parse(widget.tvSeries.firstAirDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.tvSeries.firstAirDate!))}, ${DateTime.parse(widget.tvSeries.firstAirDate!).year}',
                      style: const TextStyle(
                        fontFamily: 'PoppinsSB',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            ScrollingTVArtists(
              passedFrom: 'tv_detail',
              api: Endpoints.getTVCreditsUrl(widget.tvSeries.id!, lang),
              title: tr("cast"),
              id: widget.tvSeries.id!,
            ),
            ScrollingTVCreators(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
              title: tr("created_by"),
            ),
            SeasonsList(
              tvId: widget.tvSeries.id!,
              seriesName: widget.tvSeries.name!,
              title: tr("seasons"),
              api: Endpoints.getTVSeasons(widget.tvSeries.id!, lang),
            ),
            TVImagesDisplay(
              title: tr("images"),
              api: Endpoints.getTVImages(widget.tvSeries.id!),
              name: widget.tvSeries.originalName,
            ),
            TVVideosDisplay(
              api: Endpoints.getTVVideos(widget.tvSeries.id!),
              api2: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
              title: tr("videos"),
            ),
            TVSocialLinks(
              api: Endpoints.getExternalLinksForTV(widget.tvSeries.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            TVInfoTable(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            TVRecommendationsTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                api: Endpoints.getTVRecommendations(
                    widget.tvSeries.id!, 1, lang)),
            SimilarTVTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                tvName: widget.tvSeries.name!,
                api: Endpoints.getSimilarTV(widget.tvSeries.id!, 1, lang)),
            // DidYouKnow(
            //   api: Endpoints.getExternalLinksForTV(
            //     widget.tvSeries.id!,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
