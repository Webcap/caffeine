import 'package:reelriot/functions/network.dart';
import 'package:reelriot/models/tv.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/tv_screens/widgets/horizontal_scrolling_tv_list.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/widgets/common_widgets.dart';
import 'package:reelriot/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimilarTVTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  final String tvName;
  const SimilarTVTab(
      {super.key,
      required this.api,
      required this.tvId,
      required this.includeAdult,
      required this.tvName});

  @override
  SimilarTVTabState createState() => SimilarTVTabState();
}

class SimilarTVTabState extends State<SimilarTVTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        final isProxyEnabled =
            Provider.of<SettingsProvider>(context, listen: false).enableProxy;
        final proxyUrl =
            Provider.of<AppDependencyProvider>(context, listen: false)
                .tmdbProxy;
        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}',
                isProxyEnabled, proxyUrl)
            .then((value) {
          if (mounted) {
            setState(() {
              final existingIds = tvList!.map((t) => t.id).toSet();
              final newShows =
                  value.where((t) => !existingIds.contains(t.id)).toList();
              tvList!.addAll(newShows);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final cardWidth = isTablet ? 140.0 : 115.0;
    final posterHeight = cardWidth * 1.5;
    final rowHeight = posterHeight + (isTablet ? 56.0 : 48.0);
    return Column(
      children: <Widget>[
        Row(
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
                          tr("tv_similar_with",
                              namedArgs: {"show": widget.tvName}),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            height: rowHeight,
            child: tvList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(themeMode)
                : tvList!.isEmpty
                    ? Text(
                        tr("no_similars_tv"),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingTVList(
                                scrollController: _scrollController,
                                tvList: tvList,
                                imageQuality: imageQuality,
                                themeMode: themeMode,
                                heroPrefix: 'tv_similar'),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer(themeMode),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      );
  }

  @override
  bool get wantKeepAlive => true;
}
