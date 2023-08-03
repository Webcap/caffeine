import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/profile/profile_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'caffiene',
          style: TextStyle(fontFamily: 'PoppinsSB'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: Search(
                        mixpanel: mixpanel,
                        includeAdult: Provider.of<SettingsProvider>(context,
                                listen: false)
                            .isAdult));
              },
              icon: const Icon(Icons.search))
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
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
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
                    text: 'Movies',
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.tv,
                    text: ' TV Shows',
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.compass,
                    text: 'Discover',
                    iconColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  GButton(
                    icon: FontAwesomeIcons.user,
                    text: 'Profile',
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
      body: Container(
        child: IndexedStack(
          index: selectedIndex,
          children: const <Widget>[
            MainMoviesDisplay(),
            MainTVDisplay(),
            DiscoverPage(),
            ProfilePage()
          ],
        ),
      ),
    );
  }
}
