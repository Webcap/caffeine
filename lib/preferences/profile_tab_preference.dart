import 'package:caffiene/screens/common/about.dart';
import 'package:caffiene/screens/common/helpcenter.dart';
import 'package:caffiene/screens/common/server_status_screen.dart';
import 'package:caffiene/screens/settings/settings.dart';
import 'package:caffiene/screens/user/edit_profile.dart';
import 'package:caffiene/screens/watch_history/watch_history_v2.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/helpers/web_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileModal {
  String iconImage;
  String tital;
  String? subTital;
  Widget widget;
  void Function() onTap;

  ProfileModal({
    required this.widget,
    required this.iconImage,
    this.subTital,
    required this.tital,
    required this.onTap,
  });
}

List<ProfileModal> settingdata = [
  ProfileModal(
    onTap: () {
      Get.to(() => const ProfileEdit());
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.profile,
    tital: tr("edit_profile"),
  ),
  // ProfileModal(
  //   onTap: () {
  //     Get.to(
  //       () => const WatchHistoryV2(),
  //     );
  //   },
  //   widget: const Icon(
  //     Icons.arrow_forward_ios_rounded,
  //     size: 15,
  //   ),
  //   iconImage: MovixIcon.paper,
  //   tital: tr("watch_history"),
  // ),
  ProfileModal(
    onTap: () {
      Get.to(
        () => const Settings(),
      );
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.setting,
    tital: tr("settings"),
  ),

  ProfileModal(
    onTap: () {
      Get.to(
        () => const ServerStatusScreen(),
      );
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.server,
    tital: tr("check_server"),
  ),

  ProfileModal(
    onTap: () {
      Get.to(
        () => const AboutPage(),
      );
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.info,
    tital: tr("about"),
  ),

  // ProfileModal(
  //   onTap: () {
  //     Get.to(
  //           () => const DownloadTab(),
  //     );
  //   },
  //   widget: const Icon(
  //     Icons.arrow_forward_ios_rounded,
  //     size: 15,
  //   ),
  //   iconImage: MovixIcon.download,
  //   tital: StringValue.download,
  // ),

  // ProfileModal(
  //   widget: const Icon(
  //     Icons.arrow_forward_ios_rounded,
  //     size: 15,
  //   ),
  //   iconImage: MovixIcon.notification,
  //   tital: StringValue.notification,
  //   onTap: () {
  //     Get.to(
  //       () => const NotificationProfileScreen(),
  //     );
  //   },
  // ),
  // ProfileModal(
  //   widget: const Icon(
  //     Icons.arrow_forward_ios_rounded,
  //     size: 15,
  //   ),
  //   iconImage: MovixIcon.helpCenter,
  //   tital: tr("help_center"),
  //   onTap: () {
  //     Get.to(
  //       () => const HelpCenterProfileScreen(),
  //     );
  //   },
  // ),
  ProfileModal(
    onTap: () {
      Get.to(
        () => UrlWebPage(
          url: "https://webcap.github.io/privacy.html",
        ),
      );
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.shield_fail,
    tital: tr("privacy_policy"),
  ),
];
