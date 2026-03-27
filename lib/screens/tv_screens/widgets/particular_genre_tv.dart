import 'package:caffiene/functions/network.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/models/tv.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_grid_view.dart';
import 'package:caffiene/screens/tv_screens/widgets/tv_list_view.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class ParticularGenreTV extends StatefulWidget {
  final String api;
  final int genreId;
  final bool? includeAdult;
  const ParticularGenreTV(
      {super.key,
      required this.api,
      required this.genreId,
      required this.includeAdult});
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

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : tvList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                isLoading: isLoading,
                scrollController: _scrollController)
            : tvList!.isEmpty
                ? Center(
                    child: _EmptyGenreTVCard(message: tr("no_genre_tv")),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: viewType == 'grid'
                              ? TVGridView(
                                  tvList: tvList,
                                  imageQuality: imageQuality,
                                  themeMode: themeMode,
                                  scrollController: _scrollController,
                                )
                              : TVListView(
                                  scrollController: _scrollController,
                                  tvList: tvList,
                                  themeMode: themeMode,
                                  imageQuality: imageQuality,
                                ),
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(child: LinearProgressIndicator()),
                        ),
                      ),
                    ],
                  );
  }
}

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _EmptyGenreTVCard extends StatelessWidget {
  final String message;

  const _EmptyGenreTVCard({required this.message});

  static const _surfaceDark = Color(0xFF0B0F14);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _textSecDark = Color(0xB8FFFFFF);
  static const _textSecLight = Color(0xFF64748B);
  static const _borderDark = Color(0x14FFFFFF);
  static const _borderLight = Color(0x140F172A);
  static const _radiusMd = 16.0;
  static const _shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final textSec = isDark ? _textSecDark : _textSecLight;
    final border = isDark ? _borderDark : _borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(_radiusMd),
          border: Border.all(color: border),
          boxShadow: const [_shadowCard],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 15),
        ),
      ),
    );
  }
}
