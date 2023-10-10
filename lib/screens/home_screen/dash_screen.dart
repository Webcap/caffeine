import 'package:caffiene/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/user/profile_page.dart';
import 'package:caffiene/screens/discover_screens/discovery_screen.dart';
import 'package:caffiene/screens/movie_screens/main_movie_display.dart';
import 'package:caffiene/screens/search/search_view.dart';
import 'package:caffiene/screens/tv_screens/tv_screen.dart';
import 'package:caffiene/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

//MAIN HOMESCREEN

class caffieneHomePage extends StatefulWidget {
  const caffieneHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<caffieneHomePage> createState() => _caffieneHomePageState();
}

class _caffieneHomePageState extends State<caffieneHomePage>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    defHome();
  }

  void defHome() {
    final defaultHome =
        Provider.of<SettingsProvider>(context, listen: false).defaultValue;
    setState(() {
      selectedIndex = defaultHome;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(child: DrawerWidget()),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.barsStaggered,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          appConfig.app_name,
          style: TextStyle(fontFamily: 'PoppinsSB', color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: Search(
                        mixpanel: mixpanel,
                        includeAdult: Provider.of<SettingsProvider>(context,
                                listen: false)
                            .isAdult, lang: lang));
              },
              icon: const Icon(FontAwesomeIcons.magnifyingGlass)),
          // IconButton(
          //     color: Theme.of(context).primaryColor,
          //     onPressed: () {
          //       nextScreen(context, const VideoDownloadScreen());
          //     },
          //     icon: const Icon(Icons.download))
        ],
      ),
      bottomNavigationBar: Container(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
              ]),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 7.5),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.black,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: [
                  GButton(
                    icon: FontAwesomeIcons.clapperboard,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.tv,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.compass,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.user,
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
          index: selectedIndex,
          children: const <Widget>[
            MainMoviesDisplay(),
            MainTVDisplay(),
            DiscoverPage(),
            ProfilePage()
          ],
        ));
  }
}
