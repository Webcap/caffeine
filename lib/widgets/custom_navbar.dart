import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
          color: Color(0xFF292837),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          )),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InkWell(
          onTap: () {
            // nextScreen(context, dash_screen());
          },
          child: const Icon(
            Icons.home,
            size: 35,
            color: Colors.white,
          ),
        ),
        // InkWell(
        //   onTap: () {
        //     nextScreen(context, category_screen());
        //   },
        //   child: Icon(
        //     Icons.category,
        //     size: 35,
        //     color: Colors.white,
        //   ),
        // ),
        InkWell(
          onTap: () {},
          child: const Icon(
            Icons.favorite_border,
            size: 35,
            color: Colors.white,
          ),
        ),
        InkWell(
          onTap: () {},
          child: const Icon(
            Icons.download,
            size: 35,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}
