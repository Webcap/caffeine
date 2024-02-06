import 'package:caffiene/preferences/setting_preferences.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class SettingsProvider with ChangeNotifier {
  ThemeModePreferences themeModePreferences = ThemeModePreferences();
  AdultModePreferences adultModePreferences = AdultModePreferences();
  DefaultHomePreferences defaultHomePreferences = DefaultHomePreferences();
  ImagePreferences imagePreferences = ImagePreferences();
  ViewPreferences viewPreferences = ViewPreferences();
  CountryPreferences countryPreferences = CountryPreferences();
  Material3Preferences material3preferences = Material3Preferences();
  VideoPlayerPreferences videoPlayerPreferences = VideoPlayerPreferences();
  AppLanguagePreferences appLanguagePreferences = AppLanguagePreferences();
  AppColorPreferences appColorPreferences = AppColorPreferences();
  ProviderPrecedencePreference providerPrecedencePreference =
      ProviderPrecedencePreference();

  bool _isAdult = false;
  bool get isAdult => _isAdult;

  bool _isMaterial3Enabled = false;
  bool get isMaterial3Enabled => _isMaterial3Enabled;

  String _appTheme = "dark";
  String get appTheme => _appTheme;

  final bool _subtitleStatus = false;
  bool get subtitleStatus => _subtitleStatus;

  int _defaultValue = 0;
  int get defaultValue => _defaultValue;

  String _imageQuality = "w500/";
  String get imageQuality => _imageQuality;

  String _defaultCountry = 'US';
  String get defaultCountry => _defaultCountry;

  String _defaultView = 'list';
  String get defaultView => _defaultView;

  int _defaultSeekDuration = 10;
  int get defaultSeekDuration => _defaultSeekDuration;

  // int _defaultMinBufferDuration = 120000;
  // int get defaultMinBufferDuration => _defaultMinBufferDuration;

  int _defaultMaxBufferDuration = 360000;
  int get defaultMaxBufferDuration => _defaultMaxBufferDuration;

  int _defaultVideoResolution = 0;
  int get defaultVideoResolution => _defaultVideoResolution;

  String _defaultSubtitleLanguage = 'en';
  String get defaultSubtitleLanguage => _defaultSubtitleLanguage;

  bool _defaultViewMode = true;
  bool get defaultViewMode => _defaultViewMode;

  late Mixpanel mixpanel;

  String _subtitleForegroundColor = Colors.white.toString();
  String get subtitleForegroundColor => _subtitleForegroundColor;

  String _subtitleBackgroundColor = Colors.black45.toString();
  String get subtitleBackgroundColor => _subtitleBackgroundColor;

  int _subtitleFontSize = 17;
  int get subtitleFontSize => _subtitleFontSize;

  String _appLanguage = 'en';
  String get appLanguage => _appLanguage;

  bool _fetchSpecificLangSubs = false;
  bool get fetchSpecificLangSubs => _fetchSpecificLangSubs;

  int _appColorIndex = -1;
  int get appColorIndex => _appColorIndex;

  String _proPrecedence = providerPreference;
  String get proPreference => _proPrecedence;

  // theme change
  Future<void> getCurrentThemeMode() async {
    appTheme = await themeModePreferences.getThemeMode();
  }

  set appTheme(String value) {
    _appTheme = value;
    themeModePreferences.setThemeMode(value);
    notifyListeners();
  }

  // material theme change
  Future<void> getCurrentMaterial3Mode() async {
    isMaterial3Enabled = await material3preferences.getMaterial3Mode();
  }

  set isMaterial3Enabled(bool value) {
    _isMaterial3Enabled = value;
    material3preferences.setMaterial3Mode(value);
    notifyListeners();
  }

  // adult preference change
  Future<void> getCurrentAdultMode() async {
    isAdult = await adultModePreferences.getAdultMode();
  }

  set isAdult(bool value) {
    _isAdult = value;
    adultModePreferences.setAdultMode(value);
    notifyListeners();
  }

  // screen preference
  Future<void> getCurrentDefaultScreen() async {
    defaultValue = await defaultHomePreferences.getDefaultHome();
  }

  set defaultValue(int value) {
    _defaultValue = value;
    defaultHomePreferences.setDefaultHome(value);
    notifyListeners();
  }

  // image preference
  Future<void> getCurrentImageQuality() async {
    imageQuality = await imagePreferences.getImageQuality();
  }

  set imageQuality(String value) {
    _imageQuality = value;
    imagePreferences.setImageQuality(value);
    notifyListeners();
  }

  // watch country
  Future<void> getCurrentWatchCountry() async {
    defaultCountry = await countryPreferences.getCountryName();
  }

  set defaultCountry(String value) {
    _defaultCountry = value;
    countryPreferences.setCountryName(value);
    notifyListeners();
  }

  // mixpanel
  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(mixpanelKey,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
    notifyListeners();
  }

  // view preference
  Future<void> getCurrentViewType() async {
    defaultView = await viewPreferences.getViewType();
  }

  set defaultView(String value) {
    _defaultView = value;
    viewPreferences.setViewType(value);
    notifyListeners();
  }

  Future<void> getSeekDuration() async {
    defaultSeekDuration = await videoPlayerPreferences.getSeekDuraion();
  }

  set defaultSeekDuration(int value) {
    _defaultSeekDuration = value;
    videoPlayerPreferences.setSeekDuration(value);
    notifyListeners();
  }

  Future<void> getViewMode() async {
    defaultViewMode = await videoPlayerPreferences.autoFullScreen();
  }

  set defaultViewMode(bool value) {
    _defaultViewMode = value;
    videoPlayerPreferences.setDefaultFullScreen(value);
    notifyListeners();
  }

  // Future<void> getMinBufferDuration() async {
  //   defaultMinBufferDuration = await videoPlayerPreferences.getMinBuffer();
  // }

  // set defaultMinBufferDuration(int value) {
  //   _defaultMinBufferDuration = value;
  //   videoPlayerPreferences.setMinBufferDuration(value);
  //   notifyListeners();
  // }

  // BUFFER_DURATION
  Future<void> getMaxBufferDuration() async {
    defaultMaxBufferDuration = await videoPlayerPreferences.getMaxBuffer();
  }

  set defaultMaxBufferDuration(int value) {
    _defaultMaxBufferDuration = value;
    videoPlayerPreferences.setMaxBufferDuration(value);
    notifyListeners();
  }

  // Video player preferences
  // video Resolution
  Future<void> getVideoResolution() async {
    defaultVideoResolution =
        await videoPlayerPreferences.getDefaultVideoQuality();
  }

  set defaultVideoResolution(int value) {
    _defaultVideoResolution = value;
    videoPlayerPreferences.setDefaultVideoQuality(value);
    notifyListeners();
  }

  // subtitle
  Future<void> getSubtitleLanguage() async {
    defaultSubtitleLanguage = await videoPlayerPreferences.getSubLanguage();
  }

  // get default subtitle language
  set defaultSubtitleLanguage(String value) {
    _defaultSubtitleLanguage = value;
    videoPlayerPreferences.setDefaultSubtitle(value);
    notifyListeners();
  }

  // subtitle foreground color
  Future<void> getForegroundSubtitleColor() async {
    subtitleForegroundColor = await videoPlayerPreferences.subtitleForeground();
  }

  set subtitleForegroundColor(String value) {
    _subtitleForegroundColor = value;
    videoPlayerPreferences.setSubtitleForeground(value);
    notifyListeners();
  }

  Future<void> getBackgroundSubtitleColor() async {
    subtitleBackgroundColor = await videoPlayerPreferences.subtitleBackground();
  }

  set subtitleBackgroundColor(String value) {
    _subtitleBackgroundColor = value;
    videoPlayerPreferences.setSubtitleBackground(value);
    notifyListeners();
  }

  Future<void> getSubtitleSize() async {
    subtitleFontSize = await videoPlayerPreferences.subtitleFont();
  }

  set subtitleFontSize(int value) {
    _subtitleFontSize = value;
    videoPlayerPreferences.setSubtitleFont(value);
    notifyListeners();
  }

  Future<void> getAppLanguage() async {
    appLanguage = await appLanguagePreferences.getAppLang();
  }

  set appLanguage(String value) {
    _appLanguage = value;
    appLanguagePreferences.setAppLanguage(value);
    notifyListeners();
  }

  Future<void> getSubtitleMode() async {
    fetchSpecificLangSubs = await videoPlayerPreferences.getSubtitleMode();
  }

  set fetchSpecificLangSubs(bool value) {
    _fetchSpecificLangSubs = value;
    videoPlayerPreferences.setSubtitleMode(value);
    notifyListeners();
  }

  Future<void> getAppColorIndex() async {
    appColorIndex = await appColorPreferences.getAppColorIndex();
  }

  set appColorIndex(int value) {
    _appColorIndex = value;
    appColorPreferences.setAppColorIndex(value);
    notifyListeners();
  }

  // provider precedence
  Future<void> getProviderPrecedence() async {
    proPreference = await providerPrecedencePreference.getProviderPrecedence();
  }

  set proPreference(String value) {
    _proPrecedence = value;
    providerPrecedencePreference.setProviderPrecedence(value);
    notifyListeners();
  }
}
