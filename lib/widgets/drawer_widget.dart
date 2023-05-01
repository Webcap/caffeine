import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:login/provider/settings_provider.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/auth_screens/login_screen.dart';
import 'package:login/screens/common/about.dart';
import 'package:login/screens/common/bookmark_screen.dart';
import 'package:login/screens/settings/settings.dart';
import 'package:login/utils/config.dart';
import 'package:login/utils/next_screen.dart';
import 'package:provider/provider.dart';

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
    // final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    // final sp = context.watch<SignInProvider>();
    return Drawer(
      child: Container(
        color: isDark ? Colors.black : Colors.white,
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
                    child: Image.asset(Config.app_icon),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.bookmark,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Bookmark'),
                  onTap: () {
                    nextScreen(context, BookmarkScreen());
                  },
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.newspaper,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('News'),
                  onTap: () {
                    //nextScreen(context, NewsPage());
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('About'),
                  onTap: () {
                    nextScreen(context, AboutPage());
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.update,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Check for an update'),
                  onTap: () {
                    //nextScreen(context, UpdateScreen());
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Settings'),
                  onTap: () {
                    nextScreen(context, Settings());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
