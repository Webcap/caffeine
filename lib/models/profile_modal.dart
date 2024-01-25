import 'package:caffiene/screens/settings/settings.dart';
import 'package:caffiene/screens/user/edit_profile.dart';
import 'package:caffiene/screens/user/password_change.dart';
import 'package:caffiene/utils/app_images.dart';
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
    tital: "Edit Profile",
  ),
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
    tital: "App Settings",
  ),

  ProfileModal(
    onTap: () {
      Get.to(
        () => const PasswordChangeScreen(),
      );
    },
    widget: const Icon(
      Icons.arrow_forward_ios_rounded,
      size: 15,
    ),
    iconImage: MovixIcon.security,
    tital: "Change Password",
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
  //   tital: StringValue.helpCenter,
  //   onTap: () {
  //     Get.to(
  //       () => const HelpCenterProfileScreen(),
  //     );
  //   },
  // ),
  // ProfileModal(
  //   onTap: () {
  //     Get.to(
  //       UrlWebPage(
  //         url: privacyPolicy!,
  //       ),
  //     );
  //   },
  //   widget: const Icon(
  //     Icons.arrow_forward_ios_rounded,
  //     size: 15,
  //   ),
  //   iconImage: MovixIcon.helpCenter,
  //   tital: StringValue.privacyPolicy,
  // ),
];
