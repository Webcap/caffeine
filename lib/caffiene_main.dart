import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/bookmarks_provider.dart';
import 'package:caffiene/provider/recently_watched_provider.dart';
import 'package:caffiene/provider/premium_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/provider/sign_in_provider.dart';
import 'package:caffiene/services/ad_service.dart';
import 'package:caffiene/services/cast_service.dart';
import 'package:caffiene/utils/config_api.dart';
import 'package:caffiene/utils/routes/app_pages.dart';
import 'package:caffiene/utils/theme/theme_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class caffeine extends StatefulWidget {
  const caffeine(
      {required this.settingsProvider,
      required this.recentProvider,
      required this.appDependencyProvider,
      super.key});

  final SettingsProvider settingsProvider;
  final RecentProvider recentProvider;
  final AppDependencyProvider appDependencyProvider;

  @override
  State<caffeine> createState() => _caffeineState();
}

/// Lazy getter - Supabase must be initialized in main() before first use
SupabaseClient get supabase => Supabase.instance.client;

class _caffeineState extends State<caffeine>
    with ChangeNotifier, WidgetsBindingObserver {
  bool? isFirstLaunch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fileDelete();
    [Permission.notification, Permission.storage].request();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshConfig(widget.appDependencyProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return widget.settingsProvider;
        }),
        ChangeNotifierProvider(create: (_) {
          return widget.recentProvider;
        }),
        ChangeNotifierProvider(create: (_) {
          return widget.appDependencyProvider;
        }),
        ChangeNotifierProvider(create: (context) {
          return SignInProvider(
              appDependencyProvider: context.read<AppDependencyProvider>());
        }),
        ChangeNotifierProvider(create: (_) => CastService()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (context) => PremiumProvider(context.read<AppDependencyProvider>())),
        ChangeNotifierProvider.value(value: AdService.instance),
      ],
      child: Consumer3<SettingsProvider, AppDependencyProvider, RecentProvider>(
        builder: (context, settingsProvider, appDependencyProvider,
            recentProvider, snapshot) {
          return GetMaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            getPages: AppPages.pages,
            theme: Styles.themeData(
                appThemeMode: settingsProvider.appTheme,
                context: context),
          );
        },
      ),
    );
  }
}
