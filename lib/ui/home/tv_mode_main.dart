import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/ui/home/tvmode_home_screen.dart';

class tvModeMain extends StatelessWidget {
  const tvModeMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: MaterialApp(
        title: 'caffeine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: GoogleFonts.openSans().fontFamily,
            primarySwatch: Colors.blueGrey,
            backgroundColor: Color.fromARGB(255, 35, 40, 50)),
        home: tvModeHome(title: 'caffiene'),
      ),
    );
  }
}
