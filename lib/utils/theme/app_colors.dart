import 'package:flutter/material.dart';

/// App Colors ///
abstract class ColorValues {
  static const Color redColor = Color(0xFFE21221);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color shadowRedColor = Color(0x3fe21221);
  static const Color shadow2RedColor = Color(0xffe21221);
  static const Color grayColor = Color(0xff9e9e9e);
  static const Color lightGrayColor = Color(0xffEEEEEE);
  static const Color skipColor = Color(0xffFCE7E9);
  static const Color boxColor = Color(0xffEEEEEE);
  static const Color redBoxColor = Color(0xfffdeced);
  static const Color blackColor = Color(0xFF000000);
  static const Color commentBoxColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFFCE7E9);
  static const Color buttonColor = Color(0xFFC1232F);
  static const Color fontColor = Color(0xFF616161);
  static const Color darkmodefirst = Color(0xFF181A20);
  static const Color darkmodesecond = Color(0xFF1F222A);
  static const Color darkmodethird = Color(0xff35383F);
  static Color redShimmer = Colors.red.shade200;
  static Color grayShimmer = Colors.grey.shade100;

  // Greyscale Colors
  static const Color grey900 = Color(0xff121212);
  static const Color grey800 = Color(0xff424242);
  static const Color grey700 = Color(0xff616161);
  static const Color grey600 = Color(0xff757575);
  static const Color grey500 = Color(0xff9E9E9E);
  static const Color grey400 = Color(0xffBDBDBD);
  static const Color grey300 = Color(0xffE0E0E0);
  static const Color grey200 = Color(0xffEEEEEE);
  static const Color grey100 = Color(0xffF5F5F5);
  static const Color grey50 = Color(0xffFAFAFA);

  // Dark Colors
  static const Color dark1 = Color(0xff181A20);
  static const Color dark2 = Color(0xff1F222A);
  static const Color dark3 = Color(0xff35383F);
}

/// Semantic Color Architecture (IEC/IEEE 82079-1 & WCAG 2.1 AA Compliant)
/// 5-Step Shade Ramps: lightest (100), light (300), default (500), dark (700), darkest (900)
abstract class AppSemanticColors {
  // Info (neutral/instructional)
  static const Color infoLightest = Color(0xFFE0F2FE); // 100
  static const Color infoLight = Color(0xFF7DD3FC);    // 300
  static const Color infoDefault = Color(0xFF0EA5E9);  // 500
  static const Color infoDark = Color(0xFF0369A1);     // 700
  static const Color infoDarkest = Color(0xFF082F49);  // 900
  static const Color infoSurface = Color(0x1F0EA5E9);  // 12% alpha
  static const Color infoBorder = Color(0x470EA5E9);   // 28% alpha

  // Success (confirmation/positive action)
  static const Color successLightest = Color(0xFFDCFCE7); // 100
  static const Color successLight = Color(0xFF86EFAC);    // 300
  static const Color successDefault = Color(0xFF10B981);  // 500
  static const Color successDark = Color(0xFF047857);     // 700
  static const Color successDarkest = Color(0xFF064E3B);  // 900
  static const Color successSurface = Color(0x1F10B981);  // 12% alpha
  static const Color successBorder = Color(0x4710B981);   // 28% alpha

  // Warning (caution/attention required)
  static const Color warningLightest = Color(0xFFFEF3C7); // 100
  static const Color warningLight = Color(0xFFFCD34D);    // 300
  static const Color warningDefault = Color(0xFFF59E0B);  // 500
  static const Color warningDark = Color(0xFFB45309);     // 700
  static const Color warningDarkest = Color(0xFF78350F);  // 900
  static const Color warningSurface = Color(0x1FF59E0B);  // 12% alpha
  static const Color warningBorder = Color(0x47F59E0B);   // 28% alpha

  // Danger (destructive/error states)
  static const Color dangerLightest = Color(0xFFFEE2E2); // 100
  static const Color dangerLight = Color(0xFFFCA5A5);    // 300
  static const Color dangerDefault = Color(0xFFEF4444);  // 500
  static const Color dangerDark = Color(0xFFB91C1C);     // 700
  static const Color dangerDarkest = Color(0xFF7F1D1D);  // 900
  static const Color dangerSurface = Color(0x1FEF4444);  // 12% alpha
  static const Color dangerBorder = Color(0x47EF4444);   // 28% alpha
}
