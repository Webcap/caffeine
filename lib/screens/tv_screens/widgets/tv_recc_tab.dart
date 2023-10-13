import 'package:caffiene/api/tv_api.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/horizontal_scrolling_tv_list.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/common_widgets.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TVRecommendationsTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  const TVRecommendationsTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult})
      : super(key: key);

  @override
  TVRecommendationsTabState createState() => TVRecommendationsTabState();
}

class TVRecommendationsTabState extends State<TVRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  @override
  void initState() {
    super.initState();
    tvApi().fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
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

        tvApi().fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
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
                          tr("tv_recommendations"),
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
            height: 250,
            child: tvList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer1(isDark)
                : tvList!.isEmpty
                    ? Text(
                        tr("no_recommendations_tv"),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingTVList(
                                scrollController: _scrollController,
                                tvList: tvList,
                                imageQuality: imageQuality,
                                isDark: isDark),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer1(isDark),
                            ),
                          ),
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
  }

  @override
  bool get wantKeepAlive => true;
}
