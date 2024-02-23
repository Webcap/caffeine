// ignore_for_file: must_be_immutable

import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/screens/common/stripe_card.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

class paymentMethod extends StatefulWidget {
  String planPrice;
  String planType;
  paymentMethod({super.key, required this.planPrice, required this.planType});

  @override
  State<paymentMethod> createState() => _paymentMethodState();
}

class _paymentMethodState extends State<paymentMethod> {
  late final Future<PaymentConfiguration> _googlePayConfigFuture;
  String? payment;
  Map<String, dynamic>? paymentIntent;

  static const _paymentItems = [
    PaymentItem(
      label: 'month',
      amount: '9.99',
      status: PaymentItemStatus.final_price,
    ),
    PaymentItem(
      label: 'year',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('default_google_pay_config.json');
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

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
                      "Continue with Payment",
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
                      "Plan starts from $formatted \nThe price is \$${widget.planPrice}/${widget.planType}.",
                      style: GoogleFonts.urbanist(
                        color: ColorValues.grey600,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.screenHeight / 45,
                    ),

                    // google pay //
                    FutureBuilder<PaymentConfiguration>(
                        future: _googlePayConfigFuture,
                        builder: (context, snapshot) => snapshot.hasData
                            ? GooglePayButton(
                                paymentConfiguration: snapshot.data!,
                                paymentItems: _paymentItems,
                                type: GooglePayButtonType.subscribe,
                                margin: const EdgeInsets.only(top: 15.0),
                                height: SizeConfig.screenHeight / 11,
                                width: SizeConfig.screenWidth,
                                onPaymentResult: onGooglePayResult,
                                loadingIndicator: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink()),

                    SizedBox(
                      height: SizeConfig.screenHeight / 45,
                    ),

                    /// paypal ///
                    Padding(
                      padding: EdgeInsets.only(
                        top: SizeConfig.blockSizeVertical * 1,
                        bottom: SizeConfig.blockSizeVertical * 1,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            payment = "Paypal";
                          });
                        },
                        child: Container(
                          height: SizeConfig.screenHeight / 11,
                          decoration: BoxDecoration(
                            color: themeMode == "dark" || themeMode == "amoled"
                                ? ColorValues.darkmodesecond
                                : ColorValues.whiteColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: ListTile(
                            leading: Image.asset(
                              AssetValues.paypal,
                              height: SizeConfig.blockSizeVertical * 6,
                            ),
                            title: Text(
                              "Paypal",
                              style: GoogleFonts.urbanist(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: Radio(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => ColorValues.redColor),
                              activeColor: ColorValues.redColor,
                              value: "Paypal",
                              groupValue: payment,
                              onChanged: (value) {
                                setState(() {
                                  payment = value.toString();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    //const NativAdsScreen(),

                    /// Apple Pay ///
                    // Padding(
                    //   padding: EdgeInsets.only(
                    //     top: SizeConfig.blockSizeVertical * 1,
                    //     bottom: SizeConfig.blockSizeVertical * 1,
                    //   ),
                    //   child: InkWell(
                    //     onTap: () {
                    //       setState(() {
                    //         payment = "Apple Pay";
                    //       });
                    //     },
                    //     child: Container(
                    //       height: SizeConfig.screenHeight / 11,
                    //       decoration: BoxDecoration(
                    //           color: themeMode == "dark" || themeMode == "amoled"
                    //               ? ColorValues.darkmodesecond
                    //               : ColorValues.whiteColor,
                    //           borderRadius: BorderRadius.circular(12)),
                    //       alignment: Alignment.center,
                    //       child: ListTile(
                    //         leading: SvgPicture.asset(
                    //           MovixIcon.apple,
                    //           height: SizeConfig.blockSizeVertical * 4,
                    //           color: themeMode == "dark" || themeMode == "amoled"
                    //               ? ColorValues.whiteColor
                    //               : ColorValues.blackColor,
                    //         ),
                    //         title: Text(
                    //           "Apple Pay",
                    //           style: GoogleFonts.urbanist(
                    //               fontSize: 16, fontWeight: FontWeight.bold),
                    //         ),
                    //         trailing: Radio(
                    //           fillColor: MaterialStateColor.resolveWith(
                    //               (states) => ColorValues.redColor),
                    //           value: "Apple Pay",
                    //           groupValue: payment,
                    //           activeColor: ColorValues.redColor,
                    //           onChanged: (value) {
                    //             setState(() {
                    //               payment = value.toString();
                    //             });
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    /// Card Payments ///
                    Padding(
                      padding: EdgeInsets.only(
                        top: SizeConfig.blockSizeVertical * 1,
                        bottom: SizeConfig.blockSizeVertical * 1,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            payment = "Select Card";
                          });
                        },
                        child: Container(
                          height: SizeConfig.screenHeight / 11,
                          decoration: BoxDecoration(
                              color:
                                  themeMode == "dark" || themeMode == "amoled"
                                      ? ColorValues.darkmodesecond
                                      : ColorValues.whiteColor,
                              borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: ListTile(
                            leading: Image.asset(
                              AssetValues.card,
                              fit: BoxFit.cover,
                              height: SizeConfig.blockSizeVertical * 3,
                            ),
                            title: Text(
                              "Credit/Debit Card",
                              style: GoogleFonts.urbanist(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: Radio(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => ColorValues.redColor),
                              value: "Select Card",
                              groupValue: payment,
                              activeColor: ColorValues.redColor,
                              onChanged: (value) {
                                setState(() {
                                  payment = value.toString();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    //end card
                    const Spacer(),
                    AbsorbPointer(
                      absorbing: !enabled,
                      child: InkWell(
                        onTap: () async {
                          print('buttonClicked');
                          setState(() {
                            enabled = false;
                            Future.delayed(const Duration(seconds: 3), () {
                              setState(() {
                                enabled = true;
                              });
                            });
                          });
                          if (payment == "Paypal") {
                            // openCheckout();
                            print("paypal");
                          } else if (payment == "Apple Pay") {
                            print("Apple Pay");
                          } else if (payment == "Select Card") {
                            Get.to(() =>
                              NoWebhookPaymentCardFormScreen()
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 500),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                content: const Text(
                                  "Please select any Payment Option",
                                  style: TextStyle(
                                    color: ColorValues.whiteColor,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: Get.height / 15.5,
                          width: Get.width / 1.1,
                          margin: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "Continue",
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColorValues.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 5,
                    ),
                  ])),
        ));
  }
}
