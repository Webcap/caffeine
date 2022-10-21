import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:login/provider/adultmode_provider.dart';
import 'package:login/provider/default_home_provider.dart';
import 'package:login/provider/imagequality_provider.dart';
import 'package:login/provider/internet_provider.dart';
import 'package:login/provider/mixpanel_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/api/movies_api.dart';
import 'package:login/screens/discover_screens/discovery_screen.dart';
import 'package:login/screens/movie_screens/movie_screen.dart';
import 'package:login/screens/search/search_view.dart';
import 'package:login/screens/tv_screens/tv_screen.dart';
import 'package:login/utils/config.dart';
import 'package:login/widgets/custom_navbar.dart';
import 'package:login/widgets/customgridview.dart';
import 'package:login/widgets/drawer_widget.dart';
import 'package:login/widgets/listviewmoviedata.dart';
import 'package:login/widgets/namebar.dart';
import 'package:login/widgets/new_movie_widgets.dart';
import 'package:login/widgets/upcoming_widget.dart';
import 'package:provider/provider.dart';

// class dash_screen extends StatefulWidget {
//   dash_screen({Key? key}) : super(key: key);

//   @override
//   State<dash_screen> createState() => _dash_screenState();
// }

// class _dash_screenState extends State<dash_screen> {
//   Future getData() async {
//     final sp = context.read<SignInProvider>();

//     sp.getDataFromSharedPreferences();
//   }

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sp = context.watch<SignInProvider>();
//     return Scaffold(
//       backgroundColor: Color(0xFF0F111D),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   vertical: 18,
//                   horizontal: 10,
//                 ),
//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Hello ${sp.name}",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.w500)),
//                             Text("What are we watching?",
//                                 style: TextStyle(
//                                   color: Colors.white54,
//                                 ))
//                           ]),
//                       CircleAvatar(
//                         backgroundImage: NetworkImage("${sp.imageUrl}"),
//                         radius: 30,
//                       ),
//                     ]),
//               ),
//               Container(
//                 height: 60,
//                 padding: EdgeInsets.all(10),
//                 margin: EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF292837),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.search,
//                       color: Colors.white54,
//                       size: 30,
//                     ),
//                     Container(
//                       width: 300,
//                       margin: EdgeInsets.only(left: 5),
//                       child: TextFormField(
//                         style: TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           hintText: "Search",
//                           hintStyle: TextStyle(color: Colors.white54),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               //UpcomingWidget(),
//               // Namebar(
//               //   namebar: 'Trending Movies',
//               //   navigate: GridViewDatamovie(
//               //     futre: moviesApi().getTrendingAll(),
//               //   ),
//               // ),
//               ListViewDatamovie(
//                 futre: moviesApi().getTrendingAll(),
//               ),
//               SizedBox(
//                 height: 40,
//               ),
//               // NewMoviesWidget(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: CustomNavBar(),
//     );
//   }
// }

class caffieneHomePage extends StatefulWidget {
  const caffieneHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<caffieneHomePage> createState() => _caffieneHomePageState();
}

class _caffieneHomePageState extends State<caffieneHomePage>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }


  @override
  void initState() {
    
    super.initState();
    defHome();
    getData();
  }

  void defHome() {
    final defaultHome =
        Provider.of<DefaultHomeProvider>(context, listen: false).defaultValue;
    setState(() {
      _selectedIndex = defaultHome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    //final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;

    return Provider.of<SignInProvider?>(context) == null ||
            Provider.of<ImagequalityProvider?>(context) == null ||
          //  Provider.of<MixpanelProvider?>(context)?.mixpanel == null ||
            Provider.of<InternetProvider?>(context) == null ||
            Provider.of<DefaultHomeProvider?>(context)?.defaultValue == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            drawer: const DrawerWidget(),
            appBar: AppBar(
              backgroundColor: maincolor,
              title: const Text(
                'Caffiene',
                style: TextStyle(
                  fontFamily: 'PoppinsSB',
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: Search(
                              // mixpanel: mixpanel,
                              includeAdult: Provider.of<AdultmodeProvider>(
                                      context,
                                      listen: false)
                                  .isAdult));
                    },
                    icon: const Icon(Icons.search)),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: maincolor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: const [
                      GButton(
                        icon: FontAwesomeIcons.clapperboard,
                        text: 'Movies',
                      ),
                      GButton(
                        icon: FontAwesomeIcons.tv,
                        text: ' TV Shows',
                      ),
                      GButton(
                        icon: FontAwesomeIcons.compass,
                        text: 'Discover',
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
            body: Container(
              color: const Color(0xFFF7F7F7),
              child: IndexedStack(
                index: _selectedIndex,
                children: const <Widget>[
                  MainMoviesDisplay(),
                  MainTVDisplay(),
                  DiscoverPage(),
                ],
              ),
            ));
  }
}
