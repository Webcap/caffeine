import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NetworkErrorItem extends StatefulWidget {
  const NetworkErrorItem({Key? key}) : super(key: key);

  @override
  State<NetworkErrorItem> createState() => _NetworkErrorItemState();
}

class _NetworkErrorItemState extends State<NetworkErrorItem> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      body: SizedBox(
        height: Get.height, //Get.height = MediaQuery.of(context).size.height
        width: Get.width, //Get.width = MediaQuery.of(context).size.width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Here I am using an svg icon
            Icon(
              Icons.wifi_off,
              size: 100,
              color: themeMode == "dark" || themeMode == "amoled"
                  ? ColorValues.whiteColor
                  : ColorValues.blackColor,
            ),
            const SizedBox(height: 30),
            Text(
              tr("internet_lost"),
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              tr("check_try_again"),
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(ColorValues.grayColor),
              ),
              onPressed: () async {
                // SharedPreferences pref = await SharedPreferences.getInstance();
                // if(pref.getBool("isLogin") == true){
                //   setState(()  {
                //     checkInternet = true;
                //     pref.setBool("checkInternet", true);
                //     checkInternet = pref.getBool("checkInternet")!;
                //   });
                // }
                // else{}
                // Get.offAll(
                //       () => DownloadOffline(),
                // );
              },
              child: const Text(
                "Try Again",
                style: TextStyle(color: ColorValues.whiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
