import 'package:caffiene/models/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:caffiene/utils/config.dart';

ThemeData darkThemeData(
    bool isM3Enabled, ColorScheme? darkDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: const DialogTheme(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(),
    scaffoldBackgroundColor: const Color(0xFF161716),
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? maincolor
              : useUserColor
                  ? color.cs.primary
                  : maincolor,
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? maincolor
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    maincolor.withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : maincolor.withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? maincolor
                        : useUserColor
                            ? color.cs.primary
                            : maincolor,
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : useUserColor
              ? color.cs.onPrimary
              : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      selectionHandleColor: const Color(0xFFFFFFFF),
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
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor,
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? const Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : const Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? const Color(0xFF723600)
          : useUserColor
              ? color.cs.primaryContainer
              : const Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? const Color(0xFFe4bfa8)
          : useUserColor
              ? color.cs.secondary
              : const Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? const Color(0xFF5b4130)
          : useUserColor
              ? color.cs.secondaryContainer
              : const Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.surface
              : const Color(0xFF201a17),
      background: isM3Enabled
          ? darkDynamicColor?.background ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.background
              : const Color(0xFF201a17),
      error: isM3Enabled
          ? darkDynamicColor?.error ?? const Color(0xFFffb4ab)
          : useUserColor
              ? color.cs.error
              : const Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? const Color(0xFF502400)
          : useUserColor
              ? color.cs.onPrimary
              : const Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? const Color(0xFF422b1b)
          : useUserColor
              ? color.cs.onSecondary
              : const Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? const Color(0xFFece0da)
          : useUserColor
              ? color.cs.onSurface
              : const Color(0xFFece0da),
      onBackground: isM3Enabled
          ? darkDynamicColor?.onBackground ?? const Color(0xFFece0da)
          : useUserColor
              ? color.cs.onBackground
              : const Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? const Color(0xFF690005)
          : useUserColor
              ? color.cs.onError
              : const Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? const Color(0xFF93000a)
          : useUserColor
              ? color.cs.errorContainer
              : const Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? const Color(0xFFffdad6)
          : useUserColor
              ? color.cs.onErrorContainer
              : const Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : const Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : const Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? const Color(0xFFd7c3b7)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : const Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? const Color(0xFF31320a)
          : useUserColor
              ? color.cs.onTertiary
              : const Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? const Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : const Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? const Color(0xFF9f8d83)
          : useUserColor
              ? color.cs.outline
              : const Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? const Color(0xFFc9ca94)
          : useUserColor
              ? color.cs.tertiary
              : const Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? const Color(0xFF48491f)
          : useUserColor
              ? color.cs.tertiaryContainer
              : const Color(0xFF48491f),
      surfaceVariant: isM3Enabled
          ? darkDynamicColor?.surfaceVariant ?? const Color(0xFF52443c)
          : useUserColor
              ? color.cs.surfaceVariant
              : const Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        background: isM3Enabled
            ? darkDynamicColor?.background ?? Colors.black
            : useUserColor
                ? color.cs.background
                : Colors.black),
  );
}

ThemeData lightThemeData(
    bool isM3Enabled, ColorScheme? lightDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade400),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? lightDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? lightDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? lightDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: const DialogTheme(backgroundColor: Color(0xFFdedede)),
    primaryColor: isM3Enabled
        ? lightDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(),
    scaffoldBackgroundColor: const Color(0xFFf5f5f5),
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? lightDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.primary ?? maincolor
              : useUserColor
                  ? color.cs.primary
                  : maincolor,
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? lightDynamicColor?.onPrimary ?? maincolor
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.white,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? lightDynamicColor?.primary.withOpacity(0.1) ??
                    maincolor.withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : maincolor.withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? lightDynamicColor?.primary ?? maincolor
                        : useUserColor
                            ? color.cs.primary
                            : maincolor,
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? lightDynamicColor?.onPrimary ?? Colors.black
          : useUserColor
              ? color.cs.onPrimary
              : Colors.black,
      color: isM3Enabled
          ? lightDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? lightDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      selectionHandleColor: const Color(0xFF000000),
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
    indicatorColor: isM3Enabled
        ? lightDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor,
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? lightDynamicColor?.primaryContainer ?? const Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : const Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? lightDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      primaryContainer: isM3Enabled
          ? lightDynamicColor?.primaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.primaryContainer
              : const Color(0xFFffdcc6),
      secondary: isM3Enabled
          ? lightDynamicColor?.secondary ?? const Color(0xFF755846)
          : useUserColor
              ? color.cs.secondary
              : const Color(0xFF755846),
      secondaryContainer: isM3Enabled
          ? lightDynamicColor?.secondaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.secondaryContainer
              : const Color(0xFFffdcc6),
      surface: isM3Enabled
          ? lightDynamicColor?.surface ?? const Color(0xFFfffbff)
          : useUserColor
              ? color.cs.surface
              : const Color(0xFFfffbff),
      background: isM3Enabled
          ? lightDynamicColor?.background ?? const Color(0xFFfffbff)
          : useUserColor
              ? color.cs.background
              : const Color(0xFFfffbff),
      error: isM3Enabled
          ? lightDynamicColor?.error ?? const Color(0xFFba1a1a)
          : useUserColor
              ? color.cs.error
              : const Color(0xFFba1a1a),
      onPrimary: isM3Enabled
          ? lightDynamicColor?.onPrimary ?? const Color(0xFFFFC890)
          : useUserColor
              ? color.cs.onPrimary
              : const Color(0xFFFFC890),
      onSecondary: isM3Enabled
          ? lightDynamicColor?.onSecondary ?? const Color(0xFFffffff)
          : useUserColor
              ? color.cs.onSecondary
              : const Color(0xFFffffff),
      onSurface: isM3Enabled
          ? lightDynamicColor?.onSurface ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.onSurface
              : const Color(0xFF201a17),
      onBackground: isM3Enabled
          ? lightDynamicColor?.onBackground ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.onBackground
              : const Color(0xFF201a17),
      onError: isM3Enabled
          ? lightDynamicColor?.onError ?? const Color(0xFFffffff)
          : useUserColor
              ? color.cs.onError
              : const Color(0xFFffffff),
      errorContainer: isM3Enabled
          ? lightDynamicColor?.errorContainer ?? const Color(0xFFffdad6)
          : useUserColor
              ? color.cs.errorContainer
              : const Color(0xFFffdad6),
      onErrorContainer: isM3Enabled
          ? lightDynamicColor?.onErrorContainer ?? const Color(0xFF410002)
          : useUserColor
              ? color.cs.onErrorContainer
              : const Color(0xFF410002),
      onPrimaryContainer: isM3Enabled
          ? lightDynamicColor?.onPrimaryContainer ?? const Color(0xFF311400)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : const Color(0xFF311400),
      onSecondaryContainer: isM3Enabled
          ? lightDynamicColor?.onSecondaryContainer ?? const Color(0xFF2b1708)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : const Color(0xFF2b1708),
      onSurfaceVariant: isM3Enabled
          ? lightDynamicColor?.onSurfaceVariant ?? const Color(0xFF52443c)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : const Color(0xFF52443c),
      onTertiary: isM3Enabled
          ? lightDynamicColor?.onTertiary ?? const Color(0xFFffffff)
          : useUserColor
              ? color.cs.onTertiary
              : const Color(0xFFffffff),
      onTertiaryContainer: isM3Enabled
          ? lightDynamicColor?.onTertiaryContainer ?? const Color(0xFF1c1d00)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : const Color(0xFF1c1d00),
      outline: isM3Enabled
          ? lightDynamicColor?.outline ?? const Color(0xFF84746a)
          : useUserColor
              ? color.cs.outline
              : const Color(0xFF84746a),
      tertiary: isM3Enabled
          ? lightDynamicColor?.tertiary ?? const Color(0xFF5f6134)
          : useUserColor
              ? color.cs.tertiary
              : const Color(0xFF5f6134),
      tertiaryContainer: isM3Enabled
          ? lightDynamicColor?.tertiaryContainer ?? const Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.tertiaryContainer
              : const Color(0xFFe5e6ae),
      surfaceVariant: isM3Enabled
          ? lightDynamicColor?.surfaceVariant ?? const Color(0xFFf4ded3)
          : useUserColor
              ? color.cs.surfaceVariant
              : const Color(0xFFf4ded3),
      brightness: Brightness.light,
    ).copyWith(
        background: isM3Enabled
            ? lightDynamicColor?.background ?? Colors.white
            : useUserColor
                ? color.cs.background
                : Colors.white),
  );
}

ThemeData amoledThemeData(
    bool isM3Enabled, ColorScheme? darkDynamicColor, AppColor color) {
  bool useUserColor = color.index != -1;
  return ThemeData(
    useMaterial3: false,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.grey.shade900),
    appBarTheme: AppBarTheme(
      backgroundColor: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? darkDynamicColor?.onPrimary ?? Colors.black
            : useUserColor
                ? color.cs.onPrimary
                : Colors.black,
      ),
      titleTextStyle: TextStyle(
          color: isM3Enabled
              ? darkDynamicColor?.onPrimary ?? Colors.black
              : useUserColor
                  ? color.cs.onPrimary
                  : Colors.black,
          fontFamily: 'PoppinsSB',
          fontSize: 21),
    ),
    dialogTheme: const DialogTheme(backgroundColor: Color(0xFF171717)),
    primaryColor: isM3Enabled
        ? darkDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    iconTheme: IconThemeData(
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    bannerTheme: const MaterialBannerThemeData(),
    chipTheme: const ChipThemeData(),
    snackBarTheme: const SnackBarThemeData(),
    scaffoldBackgroundColor: Colors.black,
    radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(isM3Enabled
            ? darkDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.primary ?? maincolor
              : useUserColor
                  ? color.cs.primary
                  : maincolor,
        ),
        foregroundColor: MaterialStatePropertyAll(
          isM3Enabled
              ? darkDynamicColor?.onPrimary ?? maincolor
              : useUserColor
                  ? color.cs.onPrimary
                  : maincolor,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isM3Enabled
                ? darkDynamicColor?.primary.withOpacity(0.1) ??
                    maincolor.withOpacity(0.1)
                : useUserColor
                    ? color.cs.primary.withOpacity(0.1)
                    : maincolor.withOpacity(0.1),
          ),
          maximumSize: MaterialStateProperty.all(const Size(200, 60)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: isM3Enabled
                        ? darkDynamicColor?.primary ?? maincolor
                        : useUserColor
                            ? color.cs.primary
                            : maincolor,
                  )))),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      refreshBackgroundColor: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? Colors.black
          : Colors.black,
      color: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      selectionHandleColor: const Color(0xFFFFFFFF),
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
    indicatorColor: isM3Enabled
        ? darkDynamicColor?.primary ?? maincolor
        : useUserColor
            ? color.cs.primary
            : maincolor,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primary ?? maincolor
            : useUserColor
                ? color.cs.primary
                : maincolor,
      ),
      trackColor: MaterialStatePropertyAll(
        isM3Enabled
            ? darkDynamicColor?.primaryContainer ?? const Color(0xFF994d02)
            : useUserColor
                ? color.cs.primaryContainer
                : const Color(0xFF994d02),
      ),
    ),
    colorScheme: ColorScheme(
      primary: isM3Enabled
          ? darkDynamicColor?.primary ?? maincolor
          : useUserColor
              ? color.cs.primary
              : maincolor,
      primaryContainer: isM3Enabled
          ? darkDynamicColor?.primaryContainer ?? const Color(0xFF723600)
          : useUserColor
              ? color.cs.primaryContainer
              : const Color(0xFF723600),
      secondary: isM3Enabled
          ? darkDynamicColor?.secondary ?? const Color(0xFFe4bfa8)
          : useUserColor
              ? color.cs.secondary
              : const Color(0xFFe4bfa8),
      secondaryContainer: isM3Enabled
          ? darkDynamicColor?.secondaryContainer ?? const Color(0xFF5b4130)
          : useUserColor
              ? color.cs.secondaryContainer
              : const Color(0xFF5b4130),
      surface: isM3Enabled
          ? darkDynamicColor?.surface ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.surface
              : Colors.black,
      background: isM3Enabled
          ? darkDynamicColor?.background ?? const Color(0xFF201a17)
          : useUserColor
              ? color.cs.background
              : Colors.black,
      error: isM3Enabled
          ? darkDynamicColor?.error ?? const Color(0xFFffb4ab)
          : useUserColor
              ? color.cs.error
              : const Color(0xFFffb4ab),
      onPrimary: isM3Enabled
          ? darkDynamicColor?.onPrimary ?? const Color(0xFF502400)
          : useUserColor
              ? color.cs.onPrimary
              : const Color(0xFF502400),
      onSecondary: isM3Enabled
          ? darkDynamicColor?.onSecondary ?? const Color(0xFF422b1b)
          : useUserColor
              ? color.cs.onSecondary
              : const Color(0xFF502400),
      onSurface: isM3Enabled
          ? darkDynamicColor?.onSurface ?? const Color(0xFFece0da)
          : useUserColor
              ? color.cs.onSurface
              : const Color(0xFFece0da),
      onBackground: isM3Enabled
          ? darkDynamicColor?.onBackground ?? const Color(0xFFece0da)
          : useUserColor
              ? color.cs.onBackground
              : const Color(0xFFece0da),
      onError: isM3Enabled
          ? darkDynamicColor?.onError ?? const Color(0xFF690005)
          : useUserColor
              ? color.cs.onError
              : const Color(0xFF690005),
      errorContainer: isM3Enabled
          ? darkDynamicColor?.errorContainer ?? const Color(0xFF93000a)
          : useUserColor
              ? color.cs.errorContainer
              : const Color(0xFF93000a),
      onErrorContainer: isM3Enabled
          ? darkDynamicColor?.onErrorContainer ?? const Color(0xFFffdad6)
          : useUserColor
              ? color.cs.onErrorContainer
              : const Color(0xFFffdad6),
      onPrimaryContainer: isM3Enabled
          ? darkDynamicColor?.onPrimaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onPrimaryContainer
              : const Color(0xFFffdcc6),
      onSecondaryContainer: isM3Enabled
          ? darkDynamicColor?.onSecondaryContainer ?? const Color(0xFFffdcc6)
          : useUserColor
              ? color.cs.onSecondaryContainer
              : const Color(0xFFffdcc6),
      onSurfaceVariant: isM3Enabled
          ? darkDynamicColor?.onSurfaceVariant ?? const Color(0xFFd7c3b7)
          : useUserColor
              ? color.cs.onSurfaceVariant
              : const Color(0xFFd7c3b7),
      onTertiary: isM3Enabled
          ? darkDynamicColor?.onTertiary ?? const Color(0xFF31320a)
          : useUserColor
              ? color.cs.onTertiary
              : const Color(0xFF31320a),
      onTertiaryContainer: isM3Enabled
          ? darkDynamicColor?.onTertiaryContainer ?? const Color(0xFFe5e6ae)
          : useUserColor
              ? color.cs.onTertiaryContainer
              : const Color(0xFFe5e6ae),
      outline: isM3Enabled
          ? darkDynamicColor?.outline ?? const Color(0xFF9f8d83)
          : useUserColor
              ? color.cs.outline
              : const Color(0xFF9f8d83),
      tertiary: isM3Enabled
          ? darkDynamicColor?.tertiary ?? const Color(0xFFc9ca94)
          : useUserColor
              ? color.cs.tertiary
              : const Color(0xFFc9ca94),
      tertiaryContainer: isM3Enabled
          ? darkDynamicColor?.tertiaryContainer ?? const Color(0xFF48491f)
          : useUserColor
              ? color.cs.tertiaryContainer
              : const Color(0xFF48491f),
      surfaceVariant: isM3Enabled
          ? darkDynamicColor?.surfaceVariant ?? const Color(0xFF52443c)
          : useUserColor
              ? color.cs.surfaceVariant
              : const Color(0xFF52443c),
      brightness: Brightness.dark,
    ).copyWith(
        background: isM3Enabled
            ? darkDynamicColor?.background ?? Colors.black
            : useUserColor
                ? color.cs.background
                : Colors.black),
  );
}

class Styles {
  static ThemeData themeData(
      {required String appThemeMode,
      required bool isM3Enabled,
      required ColorScheme? lightDynamicColor,
      required ColorScheme? darkDynamicColor,
      required BuildContext context,
      required AppColor appColor}) {
    return appThemeMode == "dark"
        ? darkThemeData(isM3Enabled, darkDynamicColor, appColor)
        : appThemeMode == "light"
            ? lightThemeData(isM3Enabled, lightDynamicColor, appColor)
            : appThemeMode == "amoled"
                ? amoledThemeData(isM3Enabled, darkDynamicColor, appColor)
                : darkThemeData(isM3Enabled, darkDynamicColor, appColor);
  }
}
