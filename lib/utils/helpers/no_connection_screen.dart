import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/utils/theme/app_colors.dart';
import 'package:reelriot/utils/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NetworkErrorItem extends StatefulWidget {
  const NetworkErrorItem({super.key});

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
                backgroundColor: WidgetStateProperty.all(ColorValues.grayColor),
              ),
              onPressed: () async {
                final result = await Connectivity().checkConnectivity();
                final isOffline = result.length == 1 &&
                    result.first == ConnectivityResult.none;
                if (!isOffline && context.mounted) {
                  final auth = Supabase.instance.client.auth;
                  if (auth.currentUser != null) {
                    Get.offAllNamed(Routes.dash);
                  } else {
                    Get.offAllNamed(Routes.login);
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr("check_try_again")),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
