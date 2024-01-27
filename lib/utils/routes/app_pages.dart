import 'package:caffiene/screens/auth_screens/login_screen1.dart';
import 'package:caffiene/screens/auth_screens/splash_screen.dart';
import 'package:caffiene/screens/auth_screens/user_state.dart';
import 'package:caffiene/screens/common/landing_screen.dart';
import 'package:caffiene/screens/settings/settings.dart';
import 'package:caffiene/screens/user/edit_profile.dart';
import 'package:caffiene/screens/user/password_change.dart';
import 'package:caffiene/screens/home_screen/dash_screen.dart';
import 'package:caffiene/utils/helpers/no_connection_screen.dart';
import 'package:get/get.dart';

part "app_routes.dart";

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: SplashScreen.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.landingScreen,
      page: LandingScreen.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.login,
      page: LoginScreen1.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.welcome,
      page: UserState.new,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.dash,
      page: caffieneHomePage.new,
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
    GetPage(
      name: Routes.noConnection,
      page: NetworkErrorItem.new,
      transition: Transition.upToDown,
    ),
  ];
}
