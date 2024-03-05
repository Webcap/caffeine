// ignore_for_file: unused_import

import 'package:caffiene/main.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:caffiene/utils/theme/textStyle.dart';
import 'package:caffiene/widgets/appbarlayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
  CardFieldInputDetails? _card;
  bool loading = false;
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
      backgroundColor: themeMode == "dark" || themeMode == "amoled"
          ? ColorValues.blackColor
          : ColorValues.whiteColor,
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
              Text('Insert your card details',
                  style: GoogleFonts.urbanist(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  )),
              const SizedBox(
                height: 20,
              ),
              CardFormField(onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              })
            ],
          ),
        ),
      )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            const Expanded(child: Text('Total \$10.00')),
            const SizedBox(width: 16),
            Expanded(
                child: FilledButton(
              onPressed: loading ? null : () => handlePayment(),
              child: const Text('Pay Now'),
            ))
          ],
        ),
      ),
    );
  }

  handlePayment() async {
    if (_card?.complete != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in your card details'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await processPayment();
    } catch (err) {
      throw Exception(err.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  processPayment() async {
    final paymentMethod = await Stripe.instance.createPaymentMethod(
      params: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );

    final response = await paymentClient.processPayment(
      paymentMethodId: paymentMethod.id,
      planId: 1,
    );

    print(response);
    if (response['requiresAction'] == true &&
        response['clientSecret'] != null) {
      // final paymentIntent =
      //     await Stripe.instance.handleNextAction(response['clientSecret']);

      // print(paymentIntent);
      // if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
      // final response = await paymentClient.confirmPayment(
      //   paymentIntentId: paymentIntent.id,
      // );

      // print(response);
      // }
    }
  }
}
