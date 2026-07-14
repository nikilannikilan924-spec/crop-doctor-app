class Prediction {
  final String recommendedCrop;
  final String diseaseName;
  final String diseaseRisk;
  final String preventionTipsEn;
  final String preventionTipsTa;
  final double confidence;
  final double temperature;
  final double humidity;
  final String weather;
  final DateTime timestamp;
  final String region;

  Prediction({
    required this.recommendedCrop,
    required this.diseaseName,
    required this.diseaseRisk,
    required this.preventionTipsEn,
    required this.preventionTipsTa,
    this.confidence = 0.0,
    this.temperature = 0,
    this.humidity = 0,
    this.weather = '',
    DateTime? timestamp,
    this.region = '',
  }) : timestamp = timestamp ?? DateTime.now();

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      recommendedCrop: json['recommended_crop'] ?? '',
      diseaseName: json['disease_name'] ?? 'None',
      diseaseRisk: json['disease_risk'] ?? 'Low',
      preventionTipsEn: json['prevention_tips_en'] ?? '',
      preventionTipsTa: json['prevention_tips_ta'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      weather: json['weather'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      region: json['region'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'recommended_crop': recommendedCrop,
        'disease_name': diseaseName,
        'disease_risk': diseaseRisk,
        'prevention_tips_en': preventionTipsEn,
        'prevention_tips_ta': preventionTipsTa,
        'confidence': confidence,
        'temperature': temperature,
        'humidity': humidity,
        'weather': weather,
        'timestamp': timestamp.toIso8601String(),
        'region': region,
      };

  Color get riskColor {
    switch (diseaseRisk.toLowerCase()) {
      case 'high':
        return const Color(0xFFF44336);
      case 'medium':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF4CAF50);
    }
  }
}

class CropInfo {
  final String name;
  final String nameTa;
  final String icon;
  final double suitability;
  final String season;
  final String soilType;
  final List<String> diseases;

  CropInfo({
    required this.name,
    required this.nameTa,
    required this.icon,
    required this.suitability,
    required this.season,
    required this.soilType,
    required this.diseases,
  });

  static final Map<String, CropInfo> crops = {
    'Onion': CropInfo(
        name: 'Onion', nameTa: 'வெங்காயம்', icon: '🧅', suitability: 0, season: 'Oct-Dec', soilType: 'Loamy', diseases: ['Purple Blotch']),
    'Tomato': CropInfo(
        name: 'Tomato', nameTa: 'தக்காளி', icon: '🍅', suitability: 0, season: 'Jun-Aug', soilType: 'Loamy', diseases: ['Early Blight']),
    'Paddy': CropInfo(
        name: 'Paddy', nameTa: 'நெல்', icon: '🌾', suitability: 0, season: 'Jun-Sep', soilType: 'Clay', diseases: ['Blast Disease']),
    'Cotton': CropInfo(
        name: 'Cotton', nameTa: 'பருத்தி', icon: '🌿', suitability: 0, season: 'May-Aug', soilType: 'Black', diseases: ['Root Rot']),
    'Coconut': CropInfo(
        name: 'Coconut', nameTa: 'தேங்காய்', icon: '🥥', suitability: 0, season: 'Year-round', soilType: 'Sandy', diseases: ['Leaf Wilt']),
    'Banana': CropInfo(
        name: 'Banana', nameTa: 'வாழை', icon: '🍌', suitability: 0, season: 'Year-round', soilType: 'Loamy', diseases: ['Panama Wilt']),
    'Sugarcane': CropInfo(
        name: 'Sugarcane', nameTa: 'கரும்பு', icon: '🎋', suitability: 0, season: 'Jan-Mar', soilType: 'Clay', diseases: ['Red Rot']),
    'Mango': CropInfo(
        name: 'Mango', nameTa: 'மாம்பழம்', icon: '🥭', suitability: 0, season: 'Jan-Mar', soilType: 'Red', diseases: ['Powdery Mildew']),
    'Groundnut': CropInfo(
        name: 'Groundnut', nameTa: 'நிலக்கடலை', icon: '🥜', suitability: 0, season: 'Jun-Aug', soilType: 'Sandy', diseases: ['Rust']),
    'Chilli': CropInfo(
        name: 'Chilli', nameTa: 'மிளகாய்', icon: '🌶️', suitability: 0, season: 'May-Jul', soilType: 'Loamy', diseases: ['Leaf Curl']),
    'Turmeric': CropInfo(
        name: 'Turmeric', nameTa: 'மஞ்சள்', icon: '🟡', suitability: 0, season: 'Apr-Jun', soilType: 'Loamy', diseases: ['Rhizome Rot']),
    'Coffee': CropInfo(
        name: 'Coffee', nameTa: 'காபி', icon: '☕', suitability: 0, season: 'Oct-Dec', soilType: 'Red', diseases: ['Leaf Rust']),
  };
}
