// ignore_for_file: unused_import

import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/payment_method.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/utils/theme/app_gradient.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscribeToPremium extends StatelessWidget {
  const SubscribeToPremium({Key? key}) : super(key: key);

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Appbarlayout(),
                const SizedBox(
                  width: double.infinity,
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
                  'Enjoy watching Full-HD movies, without \nrestrictions and without ads',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 4,
                ),
                const PremiumItemCard(
                  subscriptionPrice: '9.99',
                  subscriptionTime: 'month',
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 4,
                ),
                const PremiumItemCard(
                  subscriptionPrice: '99.99',
                  subscriptionTime: 'year',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumItemCard extends StatelessWidget {
  final String subscriptionPrice;
  final String subscriptionTime;

  const PremiumItemCard(
      {Key? key,
      required this.subscriptionPrice,
      required this.subscriptionTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeMode == "dark" || themeMode == "amoled"
              ? ColorValues.blackColor
              : ColorValues.grey50,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Image.asset(
              MovixIcon.king,
              color: Theme.of(context).colorScheme.primary,
              height: SizeConfig.blockSizeVertical * 6,
            ),
            const SizedBox(
              height: 16,
            ),
            RichText(
              text: TextSpan(
                text: '\$$subscriptionPrice',
                style: GoogleFonts.urbanist(
                    color: themeMode == "dark" || themeMode == "amoled"
                        ? ColorValues.whiteColor
                        : ColorValues.blackColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                children: [
                  const WidgetSpan(
                    child: SizedBox(
                      width: 8,
                    ),
                  ),
                  TextSpan(
                    text: '/$subscriptionTime',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Divider(
              color: themeMode == "dark" || themeMode == "amoled"
                  ? ColorValues.whiteColor
                  : ColorValues.blackColor,
              thickness: 1,
              height: 1,
            ),
            const SizedBox(
              height: 16,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: AppStaticData.subscriptionCardFeaturesTitle.length,
              itemBuilder: (context, index) => Row(
                children: [
                  SvgPicture.asset(
                    MovixIcon.done,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    AppStaticData.subscriptionCardFeaturesTitle[index],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.to(
                  () => const paymentMethod(),
                );
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
    );
  }
}
