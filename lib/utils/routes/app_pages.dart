import 'package:caffiene/screens/common/landing_screen.dart';
import 'package:caffiene/screens/settings/settings.dart';
import 'package:caffiene/screens/user/edit_profile.dart';
import 'package:caffiene/screens/user/password_change.dart';
import 'package:get/get.dart';

part "app_routes.dart";

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: LandingScreen.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.profileEdit,
      page: ProfileEdit.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.settings,
      page: Settings.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.passwordChangeScreen,
      page: PasswordChangeScreen.new,
      transition: Transition.downToUp,
    ),
  ];
}
