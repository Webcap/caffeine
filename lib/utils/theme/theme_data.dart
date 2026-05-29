import 'package:flutter/material.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/globals.dart';

ThemeData darkThemeData() {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: const AppBarTheme(
      backgroundColor: maincolor,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'PoppinsSB',
        fontSize: 21,
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF171717)),
    primaryColor: maincolor,
    iconTheme: const IconThemeData(color: maincolor),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFFece0da),
      contentTextStyle: TextStyle(color: Color(0xFF201a17)),
    ),
    scaffoldBackgroundColor: const Color(0xFF161716),
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(maincolor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(maincolor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(maincolor.withValues(alpha: 0.1)),
        maximumSize: WidgetStateProperty.all(const Size(200, 60)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: maincolor),
          ),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      refreshBackgroundColor: Colors.black,
      color: maincolor,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: maincolor,
      selectionHandleColor: Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(maincolor),
      trackColor: WidgetStatePropertyAll(Color(0xFF994d02)),
    ),
    colorScheme: const ColorScheme(
      primary: maincolor,
      primaryContainer: Color(0xFF723600),
      secondary: Color(0xFFe4bfa8),
      secondaryContainer: Color(0xFF5b4130),
      surface: Color(0xFF201a17),
      error: Color(0xFFffb4ab),
      onPrimary: Color(0xFF502400),
      onSecondary: Color(0xFF502400),
      onSurface: Color(0xFFece0da),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000a),
      onErrorContainer: Color(0xFFffdad6),
      onPrimaryContainer: Color(0xFFffdcc6),
      onSecondaryContainer: Color(0xFFffdcc6),
      onSurfaceVariant: Color(0xFFd7c3b7),
      outline: Color(0xFF31320a),
      tertiary: Color(0xFFe5e6ae),
      onTertiary: Color(0xFF9f8d83),
      tertiaryContainer: Color(0xFFc9ca94),
      onTertiaryContainer: Color(0xFF48491f),
      outlineVariant: Color(0xFF52443c),
      brightness: Brightness.dark,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: maincolor,
    ),
  );
}

ThemeData lightThemeData() {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade400),
    appBarTheme: const AppBarTheme(
      backgroundColor: maincolor,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'PoppinsSB',
        fontSize: 21,
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFFdedede)),
    primaryColor: maincolor,
    iconTheme: const IconThemeData(color: maincolor),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF201a17),
      contentTextStyle: TextStyle(color: Color(0xFFfffbff)),
    ),
    scaffoldBackgroundColor: const Color(0xFFf5f5f5),
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(maincolor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(maincolor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(maincolor.withValues(alpha: 0.1)),
        maximumSize: WidgetStateProperty.all(const Size(200, 60)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: maincolor),
          ),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      refreshBackgroundColor: Colors.black,
      color: maincolor,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: maincolor,
      selectionHandleColor: Color(0xFF000000),
      selectionColor: Colors.black12,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.black26, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(maincolor),
      trackColor: WidgetStatePropertyAll(Color(0xFF994d02)),
    ),
    colorScheme: const ColorScheme(
      primary: maincolor,
      primaryContainer: Color(0xFFffdcc6),
      secondary: Color(0xFF755846),
      secondaryContainer: Color(0xFFffdcc6),
      surface: Color(0xFFfffbff),
      error: Color(0xFFba1a1a),
      onPrimary: Color(0xFFFFC890),
      onSecondary: Color(0xFFffffff),
      onSurface: Color(0xFF201a17),
      onError: Color(0xFFffffff),
      errorContainer: Color(0xFFffdad6),
      onErrorContainer: Color(0xFF410002),
      onPrimaryContainer: Color(0xFF311400),
      onSecondaryContainer: Color(0xFF2b1708),
      onSurfaceVariant: Color(0xFF52443c),
      outline: Color(0xFF84746a),
      tertiary: Color(0xFF5f6134),
      onTertiary: Color(0xFFffffff),
      tertiaryContainer: Color(0xFFe5e6ae),
      onTertiaryContainer: Color(0xFF1c1d00),
      brightness: Brightness.light,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: maincolor,
    ),
  );
}

ThemeData lightsOutThemeData() {
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: const AppBarTheme(
      backgroundColor: maincolor,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'PoppinsSB',
        fontSize: 21,
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF171717)),
    primaryColor: maincolor,
    iconTheme: const IconThemeData(color: maincolor),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFFece0da),
      contentTextStyle: TextStyle(color: Color(0xFF201a17)),
    ),
    scaffoldBackgroundColor: Colors.black,
    radioTheme: const RadioThemeData(
      fillColor: WidgetStatePropertyAll(maincolor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(maincolor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(maincolor.withValues(alpha: 0.1)),
        maximumSize: WidgetStateProperty.all(const Size(200, 60)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: maincolor),
          ),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      refreshBackgroundColor: Colors.black,
      color: maincolor,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: maincolor,
      selectionHandleColor: Color(0xFFFFFFFF),
      selectionColor: Colors.white12,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white24, fontFamily: 'Poppins'),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(maincolor),
      trackColor: WidgetStatePropertyAll(Color(0xFF994d02)),
    ),
    colorScheme: const ColorScheme(
      primary: maincolor,
      primaryContainer: Color(0xFF723600),
      secondary: Color(0xFFe4bfa8),
      secondaryContainer: Color(0xFF5b4130),
      surface: Colors.black,
      error: Color(0xFFffb4ab),
      onPrimary: Color(0xFF502400),
      onSecondary: Color(0xFF502400),
      onSurface: Color(0xFFece0da),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000a),
      onErrorContainer: Color(0xFFffdad6),
      onPrimaryContainer: Color(0xFFffdcc6),
      onSecondaryContainer: Color(0xFFffdcc6),
      onSurfaceVariant: Color(0xFFd7c3b7),
      outline: Color(0xFF31320a),
      tertiary: Color(0xFFe5e6ae),
      onTertiary: Color(0xFF9f8d83),
      tertiaryContainer: Color(0xFFc9ca94),
      onTertiaryContainer: Color(0xFF48491f),
      outlineVariant: Color(0xFF52443c),
      brightness: Brightness.dark,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: maincolor,
    ),
  );
}

class Styles {
  static ThemeData themeData({required String appThemeMode, required BuildContext context}) {
    switch (appThemeMode) {
      case "dark":
        return darkThemeData();
      case "light":
        return lightThemeData();
      case "amoled":
        return lightsOutThemeData();
      default:
        return darkThemeData();
    }
  }
}
