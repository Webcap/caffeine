import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = 'https://consumet.beamlak.dev';
  String get consumetUrl => _consumetUrl;

  String _caffieneLogo = 'default';
  String get caffieneLogo => _caffieneLogo;

  Future<void> getConsumetUrl() async {
    consumetUrl = await appDependencies.getConsumetUrl();
  }

  set consumetUrl(String value) {
    _consumetUrl = value;
    appDependencies.setConsumetUrl(value);
    notifyListeners();
  }

  Future<void> getCinemaxLogo() async {
    caffieneLogo = await appDependencies.getCaffieneLogo();
  }

  set caffieneLogo(String value) {
    _caffieneLogo = value;
    appDependencies.setCaffieneUrl(value);
    notifyListeners();
  }
}
