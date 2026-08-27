import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/similar_tv_tab.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_recc_tab.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_seasons_list.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_social_links.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_widgets.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reelriot/api/endpoints.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/screens/tv_screens/widgets/scrolling_tv_widget.dart';
import 'package:reelriot/screens/tv_screens/widgets/tv_genre_widgets.dart';
import 'package:reelriot/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class TVAbout extends StatefulWidget {
  const TVAbout({super.key, required this.tvSeries, this.videosKey});

  final TV tvSeries;
  final GlobalKey? videosKey;

  @override
  State<TVAbout> createState() => _TVAboutState();
}

class _TVAboutState extends State<TVAbout> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 16.0,
                  vertical: 8.0,
                ),
                child: widget.tvSeries.overview!.isEmpty ||
                        widget.tvSeries.overview == null
                  ? Text(tr("no_overview_tv"))
                  : ReadMoreText(
                      widget.tvSeries.overview!,
                      trimLines: 3,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xB8FFFFFF)
                            : const Color(0xFF475569),
                      ),
                      colorClickableText: const Color(0xFFDC2626),
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' See More',
                      trimExpandedText: ' See Less',
                      lessStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.bold),
                      moreStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 15),
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
            Builder(
              key: widget.videosKey,
              builder: (_) => TVVideosDisplay(
                api: Endpoints.getTVVideos(widget.tvSeries.id!),
                api2: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
                title: tr("videos"),
              ),
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
    ),
  );
}
}
