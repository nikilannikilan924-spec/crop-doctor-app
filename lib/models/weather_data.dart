class WeatherData {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double rainfall;
  final double windSpeed;
  final String condition;
  final String description;
  final String iconCode;
  final List<ForecastDay> forecast;
  final String locationName;

  WeatherData({
    required this.temperature,
    this.feelsLike = 0,
    required this.humidity,
    this.rainfall = 0,
    this.windSpeed = 0,
    required this.condition,
    this.description = '',
    this.iconCode = '01d',
    this.forecast = const [],
    this.locationName = '',
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      rainfall: (json['rain']?['1h'] ?? 0).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      locationName: json['name'] ?? '',
    );
  }

  bool get isRainy => condition.contains('Rain') || condition.contains('Drizzle');
  bool get isCloudy => condition.contains('Cloud') || condition.contains('Overcast');
  bool get isSunny => condition == 'Clear';
  bool get isHot => temperature > 35;
  bool get isHumid => humidity > 75;

  String get weatherAnimation {
    if (isRainy) return 'rain';
    if (isCloudy) return 'clouds';
    if (isSunny) return 'sunny';
    return 'normal';
  }
}

class ForecastDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double humidity;
  final String condition;
  final String iconCode;

  ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.condition,
    required this.iconCode,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: (json['temp']['min'] as num).toDouble(),
      tempMax: (json['temp']['max'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
    );
  }
}
