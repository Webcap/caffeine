import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscribeToPremium extends StatefulWidget {
  const SubscribeToPremium({Key? key}) : super(key: key);

  @override
  _SubscribeToPremiumState createState() => _SubscribeToPremiumState();
}

class _SubscribeToPremiumState extends State<SubscribeToPremium> {
  final CarouselController scrollController = CarouselController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 4,
            right: SizeConfig.blockSizeHorizontal * 4,
            top: SizeConfig.blockSizeVertical * 3,
          ),
          child: Column(
            children: [
              Appbarlayout(),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Subscribe to Premium",
                style: GoogleFonts.urbanist(
                  color: ColorValues.redColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
