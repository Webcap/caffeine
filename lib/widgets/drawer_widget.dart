import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/screens/common/server_status_screen.dart';
import 'package:caffiene/screens/common/subscribe_to_premium.dart';
import 'package:caffiene/screens/wip/chromecast_test.dart';
import 'package:caffiene/screens/tv_screens/live_tv_screen.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    AppDependencyProvider appDependencyProvider = AppDependencyProvider();
    return Drawer(
      child: Container(
        color: themeMode == "dark" || themeMode == "amoled"
            ? Colors.black
            : Colors.white,
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
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? Colors.white
                              : Colors.black),
                      child: Image.asset(appConfig.app_icon),
                    ),
                  ),
                  appDependencyProvider.displayOTTDrawer
                      ? ListTile(
                          leading: Icon(
                            FontAwesomeIcons.tv,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(tr("live_tv")),
                          onTap: () {
                            nextScreen(context, const LiveTV());
                          },
                        )
                      : Container(),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.userPlus,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text("Testing Zone"),
                    onTap: () {
                      nextScreen(context, const ChromecastHome());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.bookmark,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("bookmarks")),
                    onTap: () {
                      nextScreen(context, const BookmarkScreen());
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(
                  //     FontAwesomeIcons.clockRotateLeft,
                  //     color: Theme.of(context).colorScheme.primary,
                  //   ),
                  //   title: Text(tr("watch_history")),
                  //   onTap: () {
                  //     nextScreen(context, const WatchHistory());
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("about")),
                    onTap: () {
                      nextScreen(context, const AboutPage());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.update,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("check_for_update")),
                    onTap: () {
                      nextScreen(context, const UpdateScreen());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.server,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("check_server")),
                    onTap: () {
                      nextScreen(context, const ServerStatusScreen());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("settings")),
                    onTap: () {
                      nextScreen(context, const Settings());
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr("shared_the_app")),
                    onTap: () async {
                      mixpanel.track('Share button data', properties: {
                        'Share button click': 'Share',
                      });
                      await Share.share(tr("share_text"));
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
