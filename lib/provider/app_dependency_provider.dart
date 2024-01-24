import 'package:caffiene/utils/constant.dart';
import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = CONSUMET_API;
  String get consumetUrl => _consumetUrl;

  String _caffeineAPIUrl = caffeineApiUrl;
  String get caffeineAPIURL => _caffeineAPIUrl;

  String _caffieneLogo = 'default';
  String get caffieneLogo => _caffieneLogo;

  String _opensubtitlesKey = openSubtitlesKey;
  String get opensubtitlesKey => _opensubtitlesKey;

  String _streamingServerFlixHQ = STREAMING_SERVER_FLIXHQ;
  String get streamingServerFlixHQ => _streamingServerFlixHQ;

  String _streamingServerDCVA = STREAMING_SERVER_DCVA;
  String get streamingServerDCVA => _streamingServerDCVA;

  String _streamingServerZoro = STREAMING_SERVER_ZORO;
  String get streamingServerZoro => _streamingServerZoro;

  bool _enableADS = true;
  bool get enableADS => _enableADS;

  String _fetchRoute = "flixHQ";
  String get fetchRoute => _fetchRoute;

  bool _useExternalSubtitles = false;
  bool get useExternalSubtitles => _useExternalSubtitles;

  bool _enableOTTADS = true;
  bool get enableOTTADS => _enableOTTADS;

  bool _enableTrendingHoliday = true;
  bool get enableTrendingHoliday => _enableTrendingHoliday;

  bool _displayWatchNowButton = true;
  bool get displayWatchNowButton => _displayWatchNowButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

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

  Future<void> getFQUrl() async {
    caffeineAPIURL = await appDependencies.getFQURL();
  }

  set caffeineAPIURL(String value) {
    _caffeineAPIUrl = value;
    appDependencies.setCaffeineAPIUrl(value);
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

  Future<void> getStreamingServerFlixHQ() async {
    streamingServerFlixHQ = await appDependencies.getStreamServerFlixHQ();
  }

  set streamingServerFlixHQ(String value) {
    _streamingServerFlixHQ = value;
    appDependencies.setStreamServerFlixHQ(value);
    notifyListeners();
  }

  Future<void> getStreamingServerDCVA() async {
    streamingServerDCVA = await appDependencies.getStreamServerDCVA();
  }

  set streamingServerDCVA(String value) {
    _streamingServerDCVA = value;
    appDependencies.setStreamServerDCVA(value);
    notifyListeners();
  }

  Future<void> getStreamingServerZoro() async {
    streamingServerZoro = await appDependencies.getStreamServerZoro();
  }

  set streamingServerZoro(String value) {
    _streamingServerZoro = value;
    appDependencies.setStreamServerZoro(value);
    notifyListeners();
  }

  set enableADS(bool value) {
    _enableADS = value;
    notifyListeners();
  }

  Future<void> getStreamRoute() async {
    fetchRoute = await appDependencies.getStreamRoute();
  }

  set fetchRoute(String value) {
    _fetchRoute = value;
    appDependencies.setStreamRoute(value);
    notifyListeners();
  }

  set useExternalSubtitles(bool value) {
    _useExternalSubtitles = value;
    notifyListeners();
  }

  set enableOTTADS(bool value) {
    _enableOTTADS = value;
    notifyListeners();
  }

  set enableTrendingHoliday(bool value) {
    _enableTrendingHoliday = value;
    notifyListeners();
  }

  set displayWatchNowButton(bool value) {
    _displayWatchNowButton = value;
    notifyListeners();
  }

  set displayOTTDrawer(bool value) {
    _displayOTTDrawer = value;
    notifyListeners();
  }
}
