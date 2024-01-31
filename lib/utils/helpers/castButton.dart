import 'package:caffiene/utils/app_images.dart';
import 'package:caffiene/widgets/size_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CastButton extends StatefulWidget {
  final Function()? onTap;
  const CastButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  _CastButtonState createState() => _CastButtonState();
}

class _CastButtonState extends State<CastButton> {
  bool deviceConnected = false;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
          onPressed: () {
            widget.onTap!();
          },
          child: 
            deviceConnected == false
              ? SvgPicture.asset(
                  MovixIcon.chromecast,
                  color: Colors.white,
                  width: SizeConfig.blockSizeHorizontal * 6,
                )
              : SvgPicture.asset(
                  MovixIcon.chromecast,
                  color: Colors.blue,
                  width: SizeConfig.blockSizeHorizontal * 6,
                )
        ),
    );
  }
}
