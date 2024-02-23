import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/utils/theme/textStyle.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> {
  DateTime startDate = DateTime.now();
  TextEditingController nameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  Future<void> _startDatePicket(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2100));
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Appbarlayout(),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(ProfileAssetValues.profileMocard12),
                      fit: BoxFit.fill),
                ),
                height: Get.height / 3.8,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Card Name",
                style: titalstyle3,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: Get.height / 15.5,
                width: Get.width / 1.11,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: themeMode == "dark" || themeMode == "amoled"
                      ? ColorValues.darkmodesecond
                      : ColorValues.boxColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: nameController,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  enabled: true,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                "Card Number",
                style: titalstyle3,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: Get.height / 15.5,
                width: Get.width / 1.11,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: themeMode == "dark" || themeMode == "amoled"
                      ? ColorValues.darkmodesecond
                      : ColorValues.boxColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: cardNumberController,
                  cursorColor: Theme.of(context).colorScheme.primary,
                  enabled: true,
                  obscureText: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expiry Date",
                        style: titalstyle3,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 45,
                        width: 150,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? ColorValues.darkmodesecond
                              : ColorValues.boxColor,
                        ),
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text(
                              "${startDate.day}/${startDate.month}/${startDate.year}",
                              style: titalstyle2,
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            InkWell(
                              child: SvgPicture.asset(
                                MovixIcon.calendar,
                                height: 18,
                                width: 18,
                                color: themeMode == "dark" || themeMode == "amoled"
                                    ? ColorValues.whiteColor
                                    : ColorValues.blackColor,
                              ),
                              onTap: () {
                                _startDatePicket(context);
                                
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CVV",
                        style: titalstyle3,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: Get.height / 15.5,
                        width: 150,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: themeMode == "dark" || themeMode == "amoled"
                              ? ColorValues.darkmodesecond
                              : ColorValues.boxColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: cvvController,
                          enabled: true,
                          obscureText: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: Get.height / 12,
              ),
              InkWell(
                onTap: () {
                  
                },
                child: Container(
                  alignment: Alignment.center,
                  height: Get.height / 14.5,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Continue with Payment",
                    style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorValues.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
