import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_fade/image_fade.dart';
import 'package:login/models/genres.dart';
import 'package:login/models/poster.dart';
import 'package:login/models/slide.dart';
import 'package:login/key_code.dart';
import 'package:login/ui/home/home_loading_widget.dart';
import 'package:login/ui/home/tv_mode_main.dart';
import 'package:login/ui/movie/movies_widget.dart';
import 'package:login/widgets/navigation_widget.dart';
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class tvHomeScreen extends StatefulWidget {
  const tvHomeScreen({super.key});

  @override
  State<tvHomeScreen> createState() => _tvHomeScreenState();
}

class _tvHomeScreenState extends ResumableState<tvHomeScreen> {
  List<Genre> genres = [];
  List<Slide> slides = [];

  int postx = 1;
  int posty = -2;
  int side_current = 0;

  CarouselController _carouselController = CarouselController();
  ItemScrollController _scrollController = ItemScrollController();
  List<ItemScrollController> _scrollControllers = [];
  List<int> _position_x_line_saver = [];
  List<int> _counts_x_line_saver = [];
  FocusNode home_focus_node = FocusNode();
  late Poster selected_poster;

  List<Poster> postersList = [];

  bool _visibile_loading = false;
  bool _visibile_error = false;
  bool _visibile_success = false;
  Image image = Image.asset("assets/images/profile.jpg");

  late bool logged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(home_focus_node);
    });
  }

  @override
  void onResume() {
    // TODO: implement onResume
    super.onResume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: RawKeyboardListener(
        focusNode: home_focus_node,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid? rawKeyEventDataAndroid =
                rawKeyDownEvent.data as RawKeyEventDataAndroid?;
            switch (rawKeyEventDataAndroid!.keyCode) {
              case KEY_CENTER:
                // _goToSearch();
                // _openSlide();
                // _goToMovies();
                // _goToSeries();
                // _goToChannels();
                // _goToMyList();
                // _goToSettings();
                // _goToProfile();
                // _tryAgain();
                // _goToMovieDetail();
                // _goToChannelDetail();
                break;
              case KEY_UP:
                if (_visibile_loading) {
                  print("playing sound ");
                  break;
                }
                if (_visibile_error) {
                  if (posty == -2) {
                    print("playing sound ");
                  } else if (posty == -1) {
                    posty--;
                    postx = 0;
                  }
                  break;
                }
                if (posty == -2) {
                  print("playing sound ");
                } else if (posty == -1) {
                  posty--;
                  postx = 1;
                } else if (posty == 0) {
                  posty--;
                  postx = 0;
                } else {
                  posty--;
                  postx = _position_x_line_saver[posty];
                  _scrollToIndexXY(postx, posty);
                }
                break;
              case KEY_DOWN:
                if (_visibile_error) {
                  if (posty < -1)
                    posty++;
                  else
                    print("playing sound ");
                  break;
                }
                if (_visibile_loading) {
                  print("playing sound ");
                  break;
                }
                if (genres.length - 1 == posty) {
                  print("playing sound ");
                } else {
                  posty++;
                  if (posty >= 0) {
                    postx = _position_x_line_saver[posty];
                    _scrollToIndexXY(postx, posty);
                  }
                }
                break;
              case KEY_LEFT:
                if (_visibile_error) {
                  if (posty < -1)
                    posty++;
                  else
                    print("playing sound ");
                  break;
                }
                if (posty == -2) {
                  if (postx == 0) {
                    print("playing sound ");
                  } else {
                    postx--;
                  }
                } else if (posty == -1) {
                  _carouselController.previousPage();
                } else {
                  if (postx == 0) {
                    print("playing sound ");
                  } else {
                    postx--;
                    _position_x_line_saver[posty] = postx;
                    _scrollToIndexXY(postx, posty);
                  }
                }
                break;
              case KEY_RIGHT:
                switch (posty) {
                  case -1:
                    if (_visibile_loading || _visibile_error) {
                      print("playing sound ");
                      break;
                    }
                    _carouselController.nextPage();
                    break;
                  case -2:
                    if (postx == 7)
                      print("playing sound ");
                    else
                      postx++;
                    break;
                  default:
                    if (_counts_x_line_saver[posty] - 1 == postx) {
                      print("playing sound ");
                    } else {
                      postx++;
                      _position_x_line_saver[posty] = postx;
                      _scrollToIndexXY(postx, posty);
                    }
                    break;
                }

                break;
              default:
                break;
            }
          }
        },
        child: Stack(
          children: [
            Positioned(
                right: 0,
                top: 0,
                left: MediaQuery.of(context).size.width / 4,
                bottom: MediaQuery.of(context).size.height / 4,
                child: getBackgroundImage()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black54,
                      Colors.black54,
                      Colors.black54,
                    ])),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).size.height / 3),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                      Colors.transparent,
                    ])),
              ),
            ),
            Positioned(
              top: 10,
              left: 50,
              right: 50,
              child: AnimatedOpacity(
                opacity: (posty < 0) ? 0 : 1,
                duration: Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      posty = -1;
                    });
                  },
                  child: Container(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            // if (_visibile_success)
            //   SlideWidget(
            //       poster: selected_poster,
            //       channel: selected_channel,
            //       posty: posty,
            //       postx: postx,
            //       carouselController: _carouselController,
            //       side_current: side_current,
            //       slides: slides,
            //       move: (value) {
            //         setState(() {
            //           side_current = value;
            //         });
            //       }),
            if (_visibile_loading) HomeLoadingWidget(),
            if (_visibile_error) _tryAgainWidget(),
            if (_visibile_success)
              AnimatedPositioned(
                bottom: 0,
                left: 0,
                right: 0,
                duration: Duration(milliseconds: 200),
                height: (posty < 0)
                    ? (MediaQuery.of(context).size.height / 2) - 70
                    : (MediaQuery.of(context).size.height / 2),
                child: Container(
                  height: (posty < 0)
                      ? (MediaQuery.of(context).size.height / 2) - 70
                      : (MediaQuery.of(context).size.height / 2),
                  child: ScrollConfiguration(
                    behavior:
                        MyBehavior(), // From this behaviour you can change the behaviour
                    child: ScrollablePositionedList.builder(
                      itemCount: genres.length,
                      scrollDirection: Axis.vertical,
                      itemScrollController: _scrollController,
                      itemBuilder: (context, jndex) {
                        if (genres[jndex] == null) {
                          return ChannelsWidget(
                              jndex: jndex,
                              postx: postx,
                              posty: posty,
                              scrollController: _scrollControllers[jndex],
                              size: 15,
                              title: "TV Channels",
                              channels: channels);
                        } else {
                          return MoviesWidget(
                              jndex: jndex,
                              posty: posty,
                              postx: postx,
                              scrollController: _scrollControllers[jndex],
                              title: genres[jndex].title,
                              posters: genres[jndex].posters, size: 50,);
                        }
                      },
                    ),
                  ),
                ),
              ),
            NavigationWidget(
                postx: postx,
                posty: posty,
                selectedItem: 1,
                image: image,
                ),
          ],
        ),
      ),
    );
  }

  Widget getBackgroundImage() {
    if (posty < 0 && slides.length > 0)
      return ImageFade(
          image: NetworkImage(slides[side_current].image), fit: BoxFit.cover);
    // if (posty == 0 && channels.length > 0)
    //   return ImageFade(
    //       image: NetworkImage(channels[postx].image), fit: BoxFit.cover);
    if (posty > 0 && genres.length > 0)
      return ImageFade(
          image: NetworkImage(genres[posty].posters![postx].cover),
          fit: BoxFit.cover);
    return Container(
      color: Colors.black,
    );
  }

  Future _scrollToIndexXY(int x, int y) async {
    _scrollControllers[y].scrollTo(
        index: x,
        duration: Duration(milliseconds: 500),
        alignment: 0.04,
        curve: Curves.fastOutSlowIn);
    _scrollController.scrollTo(
        index: y,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart);
  }

    void _showLoading() {
    setState(() {
      _visibile_loading = true;
      _visibile_error = false;
      _visibile_success = false;
    });
  }

  void _showTryAgain() {
    setState(() {
      _visibile_loading = false;
      _visibile_error = true;
      _visibile_success = false;
    });
  }

  void _showData() {
    setState(() {
      _visibile_loading = false;
      _visibile_error = false;
      _visibile_success = true;
    });
  }

  void _goToSearch() {
    if (posty == -2 && postx == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => tvModeMain(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  Widget _tryAgainWidget() {
    return Positioned(
      bottom: 0,
      left: 45,
      right: 45,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  "Something wrong !",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Please check your internet connexion and try again  !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  posty = -1;
                  Future.delayed(Duration(milliseconds: 100), () {
                    // _tryAgain();
                    posty = -2;
                  });
                });
              },
              child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 1),
                    color: (_visibile_error && posty == -1)
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: (_visibile_error && posty == -1)
                                ? Colors.black
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: (_visibile_error && posty == -1)
                                ? Colors.white
                                : Colors.black,
                          )),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: (_visibile_error && posty == -1)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
  
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
