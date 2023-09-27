import 'package:caffiene/models/app_languages.dart';
import 'package:caffiene/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLanguageChoose extends StatefulWidget {
  const AppLanguageChoose({Key? key}) : super(key: key);

  @override
  State<AppLanguageChoose> createState() => _AppLanguageChooseState();
}

class _AppLanguageChooseState extends State<AppLanguageChoose> {
  LanguageData languageData = LanguageData();

  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    List<AppLanguages> count = languageData.langs;

    return Scaffold(
        appBar: AppBar(title: Text(tr("choose_language"))),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  children: count
                      .map(
                        (AppLanguages langs) => ListTile(
                          title: Text(langs.languageName),
                          leading: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Radio(
                                value: langs.languageCode,
                                groupValue: languageChange.appLanguage,
                                onChanged: (String? value) {
                                  setState(() {
                                    languageChange.appLanguage = value!;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        tr("restart_language"),
                                        maxLines: 5,
                                        style: kTextSmallBodyStyle,
                                      ),
                                      // action: SnackBarAction(
                                      //     label: tr("restart"),
                                      //     onPressed: () {
                                      //       Phoenix.rebirth(context);
                                      //     }),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                },
                              ),
                              Image.asset(
                                langs.languageFlag,
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList())),
        ));
  }
}
