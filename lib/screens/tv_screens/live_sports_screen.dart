import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LiveSportsScreen extends StatefulWidget {
  const LiveSportsScreen({Key? key}) : super(key: key);

  @override
  _LiveSportsScreenState createState() => _LiveSportsScreenState();
}

class _LiveSportsScreenState extends State<LiveSportsScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final DateTime now = DateTime.now();
    final String formatted = formatter.format(now);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
        backgroundColor: themeMode == "dark" || themeMode == "amoled"
            ? ColorValues.blackColor
            : ColorValues.whiteColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 4,
              right: SizeConfig.blockSizeHorizontal * 4,
              top: SizeConfig.blockSizeVertical * 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Appbarlayout(),
                SizedBox(
                  height: SizeConfig.screenHeight / 45,
                ),
                Text(
                  "Live Sport Schedule",
                  style: GoogleFonts.urbanist(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight / 55,
                ),
                Text(
                  "Sports for Today $formatted",
                  style: GoogleFonts.urbanist(
                    color: ColorValues.grey600,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
