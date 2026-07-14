import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<void> load() async {
    final langCode = locale.languageCode;
    try {
      final jsonString = await rootBundle.loadString('assets/lang/$langCode.json');
      _strings = Map<String, String>.from(json.decode(jsonString));
    } catch (_) {
      _strings = _fallbackEn;
    }
  }

  String get appName => _strings['appName'] ?? 'Crop Doctor';
  String get currentLocation => _strings['currentLocation'] ?? 'Current Location';
  String get bestCrop => _strings['bestCrop'] ?? 'Best Crop';
  String get temperature => _strings['temperature'] ?? 'Temperature';
  String get humidity => _strings['humidity'] ?? 'Humidity';
  String get weatherForecast => _strings['weatherForecast'] ?? 'Weather Forecast';
  String get diseasePrediction => _strings['diseasePrediction'] ?? 'Disease Prediction';
  String get riskLevel => _strings['riskLevel'] ?? 'Risk Level';
  String get preventionTips => _strings['preventionTips'] ?? 'Prevention Tips';
  String get analyze => _strings['analyze'] ?? 'Analyze Now';
  String get history => _strings['history'] ?? 'History';
  String get settings => _strings['settings'] ?? 'Settings';
  String get language => _strings['language'] ?? 'Language';
  String get noPredictionYet => _strings['noPredictionYet'] ?? 'No predictions yet';
  String get tapAnalyze => _strings['tapAnalyze'] ?? 'Tap "Analyze Now" to get started';
  String get offline => _strings['offline'] ?? 'Offline Mode';
  String get diseaseRiskLow => _strings['diseaseRiskLow'] ?? 'Low Risk';
  String get diseaseRiskMedium => _strings['diseaseRiskMedium'] ?? 'Medium Risk';
  String get diseaseRiskHigh => _strings['diseaseRiskHigh'] ?? 'High Risk';
  String get noDisease => _strings['noDisease'] ?? 'No disease detected';
  String get allGood => _strings['allGood'] ?? 'Conditions are favorable';
  String get rain => _strings['rain'] ?? 'Rain';
  String get clear => _strings['clear'] ?? 'Clear';
  String get cloudy => _strings['cloudy'] ?? 'Cloudy';
  String get share => _strings['share'] ?? 'Share';
  String get voice => _strings['voice'] ?? 'Voice';

  static const Map<String, String> _fallbackEn = {
    'appName': 'Crop Doctor',
    'currentLocation': 'Current Location',
    'bestCrop': 'Best Crop',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'weatherForecast': 'Weather Forecast',
    'diseasePrediction': 'Disease Prediction',
    'riskLevel': 'Risk Level',
    'preventionTips': 'Prevention Tips',
    'analyze': 'Analyze Now',
    'history': 'History',
    'settings': 'Settings',
    'language': 'Language',
    'noPredictionYet': 'No predictions yet',
    'tapAnalyze': 'Tap "Analyze Now" to get started',
    'offline': 'Offline Mode',
    'diseaseRiskLow': 'Low Risk',
    'diseaseRiskMedium': 'Medium Risk',
    'diseaseRiskHigh': 'High Risk',
    'noDisease': 'No disease detected',
    'allGood': 'Conditions are favorable',
    'rain': 'Rain',
    'clear': 'Clear',
    'cloudy': 'Cloudy',
    'share': 'Share',
    'voice': 'Voice',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
