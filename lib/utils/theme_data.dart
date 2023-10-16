import 'package:flutter/material.dart';
import 'package:caffiene/utils/config.dart';

class Styles {
  static ThemeData themeData(
      {required bool isDarkTheme,
      required bool isM3Enabled,
      required ColorScheme? lightDynamicColor,
      required ColorScheme? darkDynamicColor,
      required BuildContext context}) {
    return ThemeData(
      useMaterial3: false,
      textTheme: isDarkTheme
          ? ThemeData.dark().textTheme.apply(
                fontFamily: 'Poppins',
              )
          : ThemeData.light().textTheme.apply(
                fontFamily: 'Poppins',
              ),
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor:
              isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade400),
      appBarTheme: AppBarTheme(
        backgroundColor: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? maincolor
                : lightDynamicColor?.primary ?? maincolor
            : maincolor,
        iconTheme: IconThemeData(
          color: isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.onPrimary ?? Colors.black
                  : lightDynamicColor?.onPrimary ?? Colors.black
              : Colors.black,
        ),
        titleTextStyle: TextStyle(
            color: isM3Enabled
                ? isDarkTheme
                    ? darkDynamicColor?.onPrimary ?? Colors.black
                    : lightDynamicColor?.onPrimary ?? Colors.black
                : Colors.black,
            fontFamily: 'PoppinsSB',
            fontSize: 21),
      ),
      dialogTheme: DialogTheme(
          backgroundColor:
              isDarkTheme ? const Color(0xFF171717) : const Color(0xFFdedede)),
      primaryColor: isM3Enabled
          ? isDarkTheme
              ? darkDynamicColor?.primary ?? maincolor
              : lightDynamicColor?.primary ?? maincolor
          : maincolor,
      iconTheme: IconThemeData(
        color: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? maincolor
                : lightDynamicColor?.primary ?? maincolor
            : maincolor,
      ),
      bannerTheme: const MaterialBannerThemeData(),
      chipTheme: const ChipThemeData(),
      snackBarTheme: const SnackBarThemeData(),
      scaffoldBackgroundColor:
          isDarkTheme ? const Color(0xFF161716) : const Color(0xFFf5f5f5),
      radioTheme: RadioThemeData(
          fillColor: MaterialStatePropertyAll(isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.primary ?? maincolor
                  : lightDynamicColor?.primary ?? maincolor
              : maincolor)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            isM3Enabled
                ? isDarkTheme
                    ? darkDynamicColor?.primary ?? maincolor
                    : lightDynamicColor?.primary ?? maincolor
                : maincolor,
          ),
          foregroundColor: MaterialStatePropertyAll(
            isM3Enabled
                ? isDarkTheme
                    ? darkDynamicColor?.onPrimary ?? maincolor
                    : lightDynamicColor?.onPrimary ?? maincolor
                : Colors.white,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              isM3Enabled
                  ? isDarkTheme
                      ? darkDynamicColor?.primary.withOpacity(0.1) ??
                          maincolor.withOpacity(0.1)
                      : lightDynamicColor?.primary.withOpacity(0.1) ??
                          maincolor.withOpacity(0.1)
                  : maincolor.withOpacity(0.1),
            ),
            maximumSize: MaterialStateProperty.all(const Size(200, 60)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: isM3Enabled
                          ? isDarkTheme
                              ? darkDynamicColor?.primary ?? maincolor
                              : lightDynamicColor?.primary ?? maincolor
                          : maincolor,
                    )))),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        refreshBackgroundColor: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onPrimary ?? Colors.black
                : lightDynamicColor?.onPrimary ?? Colors.black
            : Colors.black,
        color: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? maincolor
                : lightDynamicColor?.primary ?? maincolor
            : maincolor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? maincolor
                : lightDynamicColor?.primary ?? maincolor
            : maincolor,
        selectionHandleColor:
            isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
        selectionColor: isDarkTheme ? Colors.white12 : Colors.black12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
            color: isDarkTheme ? Colors.white24 : Colors.black26,
            fontFamily: 'Poppins'),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      indicatorColor: isM3Enabled
          ? isDarkTheme
              ? darkDynamicColor?.primary ?? maincolor
              : lightDynamicColor?.primary ?? maincolor
          : maincolor,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStatePropertyAll(
          isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.primary ?? maincolor
                  : lightDynamicColor?.primary ?? maincolor
              : maincolor,
        ),
        trackColor: MaterialStatePropertyAll(
          isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.primaryContainer ??
                      const Color(0xFF994d02)
                  : lightDynamicColor?.primaryContainer ??
                      const Color(0xFF994d02)
              : const Color(0xFF994d02),
        ),
      ),
      colorScheme: ColorScheme(
        primary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primary ?? maincolor
                : lightDynamicColor?.primary ?? maincolor
            : maincolor,
        primaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.primaryContainer ?? const Color(0xFF723600)
                : lightDynamicColor?.primaryContainer ?? const Color(0xFFffdcc6)
            : isDarkTheme
                ? const Color(0xFF723600)
                : const Color(0xFFffdcc6),
        secondary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.secondary ?? const Color(0xFFe4bfa8)
                : lightDynamicColor?.secondary ?? const Color(0xFF755846)
            : isDarkTheme
                ? const Color(0xFFe4bfa8)
                : const Color(0xFF755846),
        secondaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.secondaryContainer ??
                    const Color(0xFF5b4130)
                : lightDynamicColor?.secondaryContainer ??
                    const Color(0xFFffdcc6)
            : isDarkTheme
                ? const Color(0xFF5b4130)
                : const Color(0xFFffdcc6),
        surface: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.surface ?? const Color(0xFF201a17)
                : lightDynamicColor?.surface ?? const Color(0xFFfffbff)
            : isDarkTheme
                ? const Color(0xFF201a17)
                : const Color(0xFFfffbff),
        background: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.background ?? const Color(0xFF201a17)
                : lightDynamicColor?.background ?? const Color(0xFFfffbff)
            : isDarkTheme
                ? const Color(0xFF201a17)
                : const Color(0xFFfffbff),
        error: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.error ?? const Color(0xFFffb4ab)
                : lightDynamicColor?.error ?? const Color(0xFFba1a1a)
            : isDarkTheme
                ? const Color(0xFFffb4ab)
                : const Color(0xFFba1a1a),
        onPrimary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onPrimary ?? const Color(0xFF502400)
                : lightDynamicColor?.error ?? const Color(0xFFffffff)
            : isDarkTheme
                ? const Color(0xFF502400)
                : const Color(0xFFffffff),
        onSecondary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSecondary ?? const Color(0xFF422b1b)
                : lightDynamicColor?.onSecondary ?? const Color(0xFFffffff)
            : isDarkTheme
                ? const Color(0xFF502400)
                : const Color(0xFFffffff),
        onSurface: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSurface ?? const Color(0xFFece0da)
                : lightDynamicColor?.onSurface ?? const Color(0xFF201a17)
            : isDarkTheme
                ? const Color(0xFFece0da)
                : const Color(0xFF201a17),
        onBackground: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onBackground ?? const Color(0xFFece0da)
                : lightDynamicColor?.onBackground ?? const Color(0xFF201a17)
            : isDarkTheme
                ? const Color(0xFFece0da)
                : const Color(0xFF201a17),
        onError: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onError ?? const Color(0xFF690005)
                : lightDynamicColor?.onError ?? const Color(0xFFffffff)
            : isDarkTheme
                ? const Color(0xFF690005)
                : const Color(0xFFffffff),
        errorContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.errorContainer ?? const Color(0xFF93000a)
                : lightDynamicColor?.errorContainer ?? const Color(0xFFffdad6)
            : isDarkTheme
                ? const Color(0xFF93000a)
                : const Color(0xFFffdad6),
        onErrorContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onErrorContainer ?? const Color(0xFFffdad6)
                : lightDynamicColor?.onErrorContainer ?? const Color(0xFF410002)
            : isDarkTheme
                ? const Color(0xFFffdad6)
                : const Color(0xFF410002),
        onPrimaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onPrimaryContainer ??
                    const Color(0xFFffdcc6)
                : lightDynamicColor?.onPrimaryContainer ??
                    const Color(0xFF311400)
            : isDarkTheme
                ? const Color(0xFFffdcc6)
                : const Color(0xFF311400),
        onSecondaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSecondaryContainer ??
                    const Color(0xFFffdcc6)
                : lightDynamicColor?.onSecondaryContainer ??
                    const Color(0xFF2b1708)
            : isDarkTheme
                ? const Color(0xFFffdcc6)
                : const Color(0xFF2b1708),
        onSurfaceVariant: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onSurfaceVariant ?? const Color(0xFFd7c3b7)
                : lightDynamicColor?.onSurfaceVariant ?? const Color(0xFF52443c)
            : isDarkTheme
                ? const Color(0xFFd7c3b7)
                : const Color(0xFF52443c),
        onTertiary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onTertiary ?? const Color(0xFF31320a)
                : lightDynamicColor?.onTertiary ?? const Color(0xFFffffff)
            : isDarkTheme
                ? const Color(0xFF31320a)
                : const Color(0xFFffffff),
        onTertiaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.onTertiaryContainer ??
                    const Color(0xFFe5e6ae)
                : lightDynamicColor?.onTertiaryContainer ??
                    const Color(0xFF1c1d00)
            : isDarkTheme
                ? const Color(0xFFe5e6ae)
                : const Color(0xFF1c1d00),
        outline: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.outline ?? const Color(0xFF9f8d83)
                : lightDynamicColor?.outline ?? const Color(0xFF84746a)
            : isDarkTheme
                ? const Color(0xFF9f8d83)
                : const Color(0xFF84746a),
        tertiary: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiary ?? const Color(0xFFc9ca94)
                : lightDynamicColor?.tertiary ?? const Color(0xFF5f6134)
            : isDarkTheme
                ? const Color(0xFFc9ca94)
                : const Color(0xFF5f6134),
        tertiaryContainer: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiaryContainer ?? const Color(0xFF48491f)
                : lightDynamicColor?.tertiaryContainer ??
                    const Color(0xFFe5e6ae)
            : isDarkTheme
                ? const Color(0xFF48491f)
                : const Color(0xFFe5e6ae),
        surfaceVariant: isM3Enabled
            ? isDarkTheme
                ? darkDynamicColor?.tertiaryContainer ?? const Color(0xFF52443c)
                : lightDynamicColor?.tertiaryContainer ??
                    const Color(0xFFf4ded3)
            : isDarkTheme
                ? const Color(0xFF52443c)
                : const Color(0xFFf4ded3),
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ).copyWith(
          background: isM3Enabled
              ? isDarkTheme
                  ? darkDynamicColor?.background ?? Colors.black
                  : lightDynamicColor?.background ?? Colors.white
              : isDarkTheme
                  ? Colors.black
                  : Colors.white),
    );
  }
}
