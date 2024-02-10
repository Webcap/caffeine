import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/app_colors.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscribeToPremium extends StatefulWidget {
  const SubscribeToPremium({Key? key}) : super(key: key);

  @override
  _SubscribeToPremiumState createState() => _SubscribeToPremiumState();
}

class _SubscribeToPremiumState extends State<SubscribeToPremium> {
  final CarouselController scrollController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
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
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 2,
              ),
              Text(
                "Enjoy watching Premium Movie",
                style: GoogleFonts.urbanist(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 4,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal * 2.5,
                    right: SizeConfig.blockSizeHorizontal * 3,
                    top: SizeConfig.blockSizeVertical * 2.5,
                    bottom: SizeConfig.blockSizeHorizontal * 3,
                  ),
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Image.asset(
                        MovixIcon.king,
                        color: Theme.of(context).colorScheme.primary,
                        height: SizeConfig.blockSizeVertical * 6,
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      Text(
                        "\$10.00",
                        style: GoogleFonts.urbanist(
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? ColorValues.whiteColor
                                : ColorValues.blackColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "1 Month",
                        textDirection: TextDirection.ltr,
                        style: GoogleFonts.urbanist(
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? ColorValues.whiteColor
                              : ColorValues.blackColor,
                          fontSize: 20,
                        ),
                      ),
                      // for (int i = 0;
                      //     i < planProvider.planList[index].planBenefit!.length;
                      //     i++)
                      Row(
                        children: [
                          Icon(
                            Icons.done,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 5,
                          ),
                          const SizedBox(
                            width: 235,
                            child: Text(
                              'NO ADS',
                              overflow: TextOverflow.clip,
                              maxLines: 3,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockSizeVertical * 2,
                      ),
                      InkWell(
                        onTap: () {
                          // Get.to(
                          //   () => PayMentMethod(
                          //     planid: planProvider.planList[index].id!,
                          //     planPrice: planProvider.planList[index].dollar
                          //         .toString(),
                          //   ),
                          // );
                        },
                        child: Container(
                          height: Get.height / 15,
                          width: Get.width / 2,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Buy Now",
                            style: GoogleFonts.urbanist(
                              color: ColorValues.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
