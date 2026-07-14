import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../app_config.dart';

class WeatherService {
  static const String _apiKey = AppConfig.weatherApiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData?> getCurrentWeather(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lng&units=metric&appid=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return null;
  }

  Future<List<ForecastDay>> getForecast(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lng&units=metric&appid=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<ForecastDay> forecasts = [];
        final seen = <String>{};
        for (var item in data['list']) {
          final day = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final key = '${day.year}-${day.month}-${day.day}';
          if (!seen.contains(key)) {
            seen.add(key);
            forecasts.add(ForecastDay.fromJson(item));
          }
        }
        return forecasts.take(5).toList();
      }
    } catch (_) {}
    return [];
  }
}
