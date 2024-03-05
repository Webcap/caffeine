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
              const CardFormField()
            ],
          ),
        ),
      )),
    );
  }
}
