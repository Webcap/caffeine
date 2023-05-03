import 'package:flutter/material.dart';
import 'package:login/api/tv_api.dart';
import 'package:login/models/tv.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/screens/tv_screens/widgets/tv_grid_view.dart';
import 'package:login/screens/tv_screens/widgets/tv_list_view.dart';
import 'package:login/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class ParticularGenreTV extends StatefulWidget {
  final String api;
  final int genreId;
  final bool? includeAdult;
  const ParticularGenreTV(
      {Key? key,
      required this.api,
      required this.genreId,
      required this.includeAdult})
      : super(key: key);
  @override
  ParticularGenreTVState createState() => ParticularGenreTVState();
}

class ParticularGenreTVState extends State<ParticularGenreTV> {
  List<TV>? tvList;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : tvList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer1(
                    isDark: isDark,
                    isLoading: isLoading,
                    scrollController: _scrollController))
            : tvList!.isEmpty
                ? Container(
                    child: const Center(
                      child: Text(
                          'Oops! TV series for this genre doesn\'t exist :('),
                    ),
                  )
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: viewType == 'grid'
                                    ? TVGridView(
                                        tvList: tvList,
                                        imageQuality: imageQuality,
                                        isDark: isDark,
                                        scrollController: _scrollController,
                                      )
                                    : TVListView(
                                        scrollController: _scrollController,
                                        tvList: tvList,
                                        isDark: isDark,
                                        imageQuality: imageQuality),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isLoading,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: LinearProgressIndicator()),
                          )),
                    ],
                  ));
  }
}
