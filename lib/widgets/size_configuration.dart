import 'package:flutter/widgets.dart';

/// Size Configuration ///
class SizeConfig {
  static late MediaQueryData queryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  void init(BuildContext context) {
    queryData = MediaQuery.of(context);
    screenWidth = queryData.size.width;
    screenHeight = queryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}
