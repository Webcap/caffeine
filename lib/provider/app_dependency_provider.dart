import 'package:caffiene/utils/config.dart';
import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = 'https://consumet-api-beryl.vercel.app/';
  String get consumetUrl => _consumetUrl;

  String _caffieneLogo = 'default';
  String get caffieneLogo => _caffieneLogo;

  String _streamingServer = STREAMING_SERVER;
  String get streamingServer => _streamingServer;

  String _opensubtitlesKey = openSubtitlesKey;
  String get opensubtitlesKey => _opensubtitlesKey;

  bool _enableADS = false;
  bool get enableADS => _enableADS;

  String _fetchRoute = "tmDB";
  String get fetchRoute => _fetchRoute;

  bool _enableHolidayMovieTab = false;
  bool get enableHolidayMovieTab => _enableHolidayMovieTab;

  bool _useExternalSubtitles = false;
  bool get useExternalSubtitles => _useExternalSubtitles;

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

  Future<void> getOpenSubKey() async {
    opensubtitlesKey = await appDependencies.getOpenSubtitlesKey();
  }

  set opensubtitlesKey(String value) {
    _opensubtitlesKey = value;
    appDependencies.setOpenSubKey(value);
    notifyListeners();
  }

  Future<void> getStreamingServer() async {
    streamingServer = await appDependencies.getStreamServer();
  }

  set streamingServer(String value) {
    _streamingServer = value;
    appDependencies.setStreamServer(value);
    notifyListeners();
  }

  set enableADS(bool value) {
    _enableADS = value;
    notifyListeners();
  }

  set fetchRoute(String value) {
    _fetchRoute = value;
    notifyListeners();
  }

  set enableHolidayMovieTab(bool value) {
    _enableHolidayMovieTab = value;
    notifyListeners();
  }

  set useExternalSubtitles(bool value) {
    _useExternalSubtitles = value;
    notifyListeners();
  }
}
