import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle get congratulationsStyle {
  return GoogleFonts.urbanist(
    color: ColorValues.redColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
}

TextStyle get titalstyle {
  return GoogleFonts.urbanist(fontSize: 17, fontWeight: FontWeight.bold);
}

TextStyle get titalstyle1 {
  return GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700);
}

TextStyle get titalstyle2 {
  return GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w500);
}

const kBoldItemTitleStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 19,
);

const kTextHeaderStyleTV = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 30,
  color: Colors.white,
);

const kTextVerySmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallAboutBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  overflow: TextOverflow.ellipsis,
);

const kTextStyleColorBlack = TextStyle(color: Colors.black);

const kTableLeftStyle =
    TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold);

TextStyle get accountReadyStyle {
  return GoogleFonts.urbanist(
    fontSize: 14,
    color: ColorValues.blackColor,
  );
}

TextStyle get letsInStyle {
  return GoogleFonts.urbanist(fontSize: 35, fontWeight: FontWeight.bold);
}

TextStyle get loginMathodStyle {
  return GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600);
}

TextStyle get orStyle {
  return GoogleFonts.urbanist(fontSize: 15);
}

TextStyle get signInWithPasswordStyle {
  return GoogleFonts.urbanist(
      fontSize: 15, fontWeight: FontWeight.w600, color: ColorValues.whiteColor);
}
