// ignore_for_file: must_be_immutable

import 'package:caffiene/utils/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Appbarlayout extends StatelessWidget {
  String? tital;
  String? imageicon;

  Appbarlayout({super.key, this.tital, this.imageicon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(
          width: 20,
        ),
        (tital == null)
            ? Container()
            : Text(
                "$tital",
                style: titalstyle,
              ),
        const Spacer(),
        (imageicon == null)
            ? Container()
            : InkWell(
                onTap: () {},
                child: ImageIcon(
                  AssetImage("$imageicon"),
                  size: 30,
                ),
              ),
      ],
    );
  }
}
