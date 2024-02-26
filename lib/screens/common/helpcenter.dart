import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class HelpCenterProfileScreen extends StatefulWidget {
  const HelpCenterProfileScreen({super.key});

  @override
  State<HelpCenterProfileScreen> createState() =>
      _HelpCenterProfileScreenState();
}

class _HelpCenterProfileScreenState extends State<HelpCenterProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: themeMode == "dark" || themeMode == "amoled"
                ? ColorValues.whiteColor
                : ColorValues.blackColor,
          ),
        ),
        title: Text(
          "Help Center",
          style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          labelColor: ColorValues.redColor,
          indicatorColor: ColorValues.redColor,
          controller: _tabController,
          labelStyle: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              text: "FAQ",
            ),
            Tab(
              text: "Contact Us",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Placeholder(),
          Placeholder(),
        ],
      ),
    );
  }
}
