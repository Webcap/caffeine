import 'package:caffiene/utils/constant.dart';
import 'package:flutter/material.dart';
import '../preferences/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  final AppDependencies __appDependencies = AppDependencies();

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

  bool _displayCastButton = true;
  bool get displayCastButton => _displayCastButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

  bool _isForcedUpdate = false;
  bool get isForcedUpdate => _isForcedUpdate;

  String _flixhqZoeServer = "vidcloud";
  String get flixhqZoeServer => _flixhqZoeServer;

  String _goMoviesServer = "upcloud";
  String get goMoviesServer => _goMoviesServer;

  String _vidSrcToServer = "vidplay";
  String get vidSrcToServer => _vidSrcToServer;

  String _vidSrcServer = "vidsrcembed";
  String get vidSrcServer => _vidSrcServer;

  Future<void> getConsumetUrl() async {
    consumetUrl = await __appDependencies.getConsumetUrl();
  }

  set consumetUrl(String value) {
    _consumetUrl = value;
    __appDependencies.setConsumetUrl(value);
    notifyListeners();
  }

  Future<void> getCinemaxLogo() async {
    caffieneLogo = await __appDependencies.getCaffieneLogo();
  }

  set caffieneLogo(String value) {
    _caffieneLogo = value;
    __appDependencies.setCaffieneUrl(value);
    notifyListeners();
  }

  Future<void> getFQUrl() async {
    caffeineAPIURL = await __appDependencies.getFQURL();
  }

  set caffeineAPIURL(String value) {
    _caffeineAPIUrl = value;
    __appDependencies.setCaffeineAPIUrl(value);
    notifyListeners();
  }

  Future<void> getOpenSubKey() async {
    opensubtitlesKey = await __appDependencies.getOpenSubtitlesKey();
  }

  set opensubtitlesKey(String value) {
    _opensubtitlesKey = value;
    __appDependencies.setOpenSubKey(value);
    notifyListeners();
  }

  Future<void> getStreamingServerFlixHQ() async {
    streamingServerFlixHQ = await __appDependencies.getStreamServerFlixHQ();
  }

  set streamingServerFlixHQ(String value) {
    _streamingServerFlixHQ = value;
    __appDependencies.setStreamServerFlixHQ(value);
    notifyListeners();
  }

  Future<void> getStreamingServerDCVA() async {
    streamingServerDCVA = await __appDependencies.getStreamServerDCVA();
  }

  set streamingServerDCVA(String value) {
    _streamingServerDCVA = value;
    __appDependencies.setStreamServerDCVA(value);
    notifyListeners();
  }

  Future<void> getStreamingServerZoro() async {
    streamingServerZoro = await __appDependencies.getStreamServerZoro();
  }

  set streamingServerZoro(String value) {
    _streamingServerZoro = value;
    __appDependencies.setStreamServerZoro(value);
    notifyListeners();
  }

  set enableADS(bool value) {
    _enableADS = value;
    notifyListeners();
  }

  Future<void> getStreamRoute() async {
    fetchRoute = await __appDependencies.getStreamRoute();
  }

  set fetchRoute(String value) {
    _fetchRoute = value;
    __appDependencies.setStreamRoute(value);
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

  set displayCastButton(bool value) {
    _displayCastButton = value;
    notifyListeners();
  }

  set displayOTTDrawer(bool value) {
    _displayOTTDrawer = value;
    notifyListeners();
  }

  set isForcedUpdate(bool value) {
    _isForcedUpdate = value;
    notifyListeners();
  }

  set goMoviesServer(String value) {
    _goMoviesServer = value;
    notifyListeners();
  }

  set flixhqZoeServer(String value) {
    _flixhqZoeServer = value;
    notifyListeners();
  }

  set vidSrcServer(String value) {
    _vidSrcServer = value;
    notifyListeners();
  }

  set vidSrcToServer(String value) {
    _vidSrcToServer = value;
    notifyListeners();
  }
}
