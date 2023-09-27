import 'package:caffiene/screens/tv_screens/live_tv_screen.dart';
import 'package:caffiene/screens/watch_history/watch_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/about.dart';
import 'package:caffiene/screens/bookmarks/bookmark_screen.dart';
import 'package:caffiene/screens/common/update_screen.dart';
import 'package:caffiene/screens/settings/settings.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Drawer(
      child: Container(
        color: isDark ? Colors.black : Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black),
                      child: Image.asset(appConfig.app_icon),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.tv,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Live TV (beta)'),
                    onTap: () {
                      nextScreen(context, const LiveTV());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.book,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Watch History'),
                    onTap: () {
                      nextScreen(context, const WatchHistory());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.bookmark,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Bookmark'),
                    onTap: () {
                      nextScreen(context, const BookmarkScreen());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('About'),
                    onTap: () {
                      nextScreen(context, const AboutPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.update,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Check for an update'),
                    onTap: () {
                      nextScreen(context, const UpdateScreen());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Settings'),
                    onTap: () {
                      nextScreen(context, const Settings());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Share the app'),
                    onTap: () async {
                      mixpanel.track('Share button data', properties: {
                        'Share button click': 'Share',
                      });
                      await Share.share(
                          'Download the caffiene app for free and watch your favorite movies and TV shows for free! Download the app from the link below.\nhttps://caffiene.rf.gd/');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
