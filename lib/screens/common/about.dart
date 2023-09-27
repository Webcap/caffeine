import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:caffiene/utils/config.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("about")),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40.0),
                        child: Image.asset(
                          appConfig.app_icon,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  tr("app_version", namedArgs: {
                    "version": currentAppVersion
                  }),
                  style: const TextStyle(
                    fontSize: 27.0,
                  ),
                ),
                const Text(
                  'this app does not host any content on its server', // Translate "This App does not host any content on its server"
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 20.0, overflow: TextOverflow.visible),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  tr("endorsment"), // Translate "This product uses the TMDB API but is not endorsed or certified by TMDB."
                  maxLines: 5,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20.0, overflow: TextOverflow.visible),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                        Uri.parse(
                          'https://themoviedb.org',
                        ),
                        mode: LaunchMode.externalApplication);
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset('assets/images/tmdb_logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Text(
                      tr("bug_notice"), // Translate "Noticed any bugs? Inform me on Telegram, click here"
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                    onTap: () {
                      // launchUrl(Uri.parse('https://t.me/'),
                      //     mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                Column(
                  children: [
                    Text(
                      tr("follow_caffiene"),
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: kTextSmallHeaderStyle,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.twitter,
                            uri: '',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.instagram,
                            uri: '',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.telegram,
                            uri: '',
                          ),
                          SocialIconContainer(
                              platformIcon: FontAwesomeIcons.tiktok,
                              uri: ''),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.facebook,
                            uri:
                                '',
                          ),
                          SocialIconContainer(
                            platformIcon: FontAwesomeIcons.github,
                            uri: 'https://github.com/Webcap/caffiene',
                          ),
                          SocialIconContainer(
                              platformIcon: Icons.mail,
                              uri: ''),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 7.0,
                    right: 7.0,
                  ),
                  child: Text(
                    tr("made_with"),
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tr("made_in")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tr("year_range", namedArgs: {
                    "startYear": "2016",
                    "endYear": "2023"
                  })), // Translate "2015 EC, 2023 GC"
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialIconContainer extends StatelessWidget {
  const SocialIconContainer({
    required this.platformIcon,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final IconData platformIcon;
  final String uri;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: PlatformIcon(platformIcon: platformIcon, uri: uri),
    );
  }
}

class PlatformIcon extends StatelessWidget {
  const PlatformIcon({
    required this.platformIcon,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final IconData platformIcon;
  final String uri;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
      },
      child: Icon(
        platformIcon,
      ),
    );
  }
}
