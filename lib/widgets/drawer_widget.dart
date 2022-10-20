import 'package:flutter/material.dart';
import 'package:login/provider/sign_in_provider.dart';
import 'package:login/screens/auth_screens/login_screen.dart';
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
    // final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    // final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    final sp = context.watch<SignInProvider>();
    return Drawer(
      child: Container(
        color: const Color(0xFFF7F7F7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                    ),
                    child: Image.asset('assets/images/grid_final.jpg'),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF57C00),
                  ),
                  title: const Text('About'),
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) {
                    //   return const AboutPage();
                    // }));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.update,
                    color: Color(0xFFF57C00),
                  ),
                  title: const Text('Check for an update'),
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: ((context) {
                    //   return const UpdateScreen();
                    // })));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: maincolor2,
                  ),
                  title: const Text('Settings'),
                  onTap: () {
                    nextScreen(context, Settings());
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.lock,
                    color: maincolor2,
                  ),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    sp.userSignOut();
                    nextScreenReplace(context, LoginScreen());
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
