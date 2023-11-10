import 'package:caffiene/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/api/movies_api.dart';
import 'package:caffiene/models/genres.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/tv_screens/tv_genre_screen.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class TVGenreListGrid extends StatefulWidget {
  final String api;
  const TVGenreListGrid({Key? key, required this.api}) : super(key: key);

  @override
  TVGenreListGridState createState() => TVGenreListGridState();
}

class TVGenreListGridState extends State<TVGenreListGrid>
    with AutomaticKeepAliveClientMixin<TVGenreListGrid> {
  List<Genres>? genreList;

  @override
  void initState() {
    super.initState();
    moviesApi().fetchGenre(widget.api).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr("genres"),
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
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: genreList == null
                  ? genreListGridShimmer1(themeMode)
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: genreList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return TVGenre(genres: genreList![index]);
                                    }));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 125,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        genreList![index].genreName ?? "Null",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
            )),
      ],
    );
  }
}

class TVGenreDisplay extends StatefulWidget {
  final String? api;
  const TVGenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  TVGenreDisplayState createState() => TVGenreDisplayState();
}

class TVGenreDisplayState extends State<TVGenreDisplay>
    with AutomaticKeepAliveClientMixin<TVGenreDisplay> {
  List<Genres>? genres;
  @override
  void initState() {
    super.initState();
    moviesApi().fetchGenre(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          genres = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Container(
        child: genres == null
            ? SizedBox(
                height: 80,
                child: detailGenreShimmer1(themeMode),
              )
            : genres!.isEmpty
                ? Container()
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: genres!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TVGenre(
                                            genres: genres![index],
                                          )));
                            },
                            child: Chip(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 2,
                                  style: BorderStyle.solid,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              label: Text(
                                genres![index].genreName!,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                // style: widget.themeData.textTheme.bodyText1,
                              ),
                              backgroundColor:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? const Color(0xFF2b2c30)
                                      : const Color(0xFFDFDEDE),
                            ),
                          ),
                        );
                      },
                    ),
                  ));
  }

  @override
  bool get wantKeepAlive => true;
}
