import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';
import '../app_config.dart';

class PredictionService {
  static const String _baseUrl = AppConfig.backendUrl;

  Future<Prediction?> getPrediction({
    required double lat,
    required double lng,
    required double temperature,
    required double humidity,
    double? rainfall,
    double? soilMoisture,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/predict');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'lat': lat,
          'lng': lng,
          'temp': temperature,
          'humidity': humidity,
          'rainfall': rainfall ?? 0,
          'soil_moisture': soilMoisture ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Prediction.fromJson({
          ...data,
          'temperature': temperature,
          'humidity': humidity,
        });
      }
    } catch (_) {}
    return null;
  }

  Future<Prediction?> getPredictionOffline({
    required double lat,
    required double lng,
    required double temperature,
    required double humidity,
  }) async {
    final region = _getRegion(lat, lng);
    if (region == null) return null;

    final crops = _regionCrops[region] ?? [];
    if (crops.isEmpty) return null;

    crops.sort((a, b) {
      final scoreA = _scoreCrop(a, temperature, humidity);
      final scoreB = _scoreCrop(b, temperature, humidity);
      return scoreB.compareTo(scoreA);
    });

    final best = crops.first;
    final risk = _calculateRisk(best, temperature, humidity);

    return Prediction(
      recommendedCrop: best['crop']!,
      diseaseName: risk['disease'] ?? 'None',
      diseaseRisk: risk['level'] ?? 'Low',
      preventionTipsEn: _tipsEn[best['crop']] ?? '',
      preventionTipsTa: _tipsTa[best['crop']] ?? '',
      temperature: temperature,
      humidity: humidity,
      region: region,
      confidence: 0.85,
    );
  }

  double _scoreCrop(Map<String, dynamic> crop, double temp, double hum) {
    double score = 100;
    final tMin = (crop['temp_min'] as num).toDouble();
    final tMax = (crop['temp_max'] as num).toDouble();
    final hMin = (crop['hum_min'] as num).toDouble();
    final hMax = (crop['hum_max'] as num).toDouble();

    if (temp < tMin) score -= (tMin - temp) * 2;
    if (temp > tMax) score -= (temp - tMax) * 2;
    if (hum < hMin) score -= (hMin - hum) * 1.5;
    if (hum > hMax) score -= (hum - hMax) * 1.5;

    return score.clamp(0, 100);
  }

  String _getRegion(double lat, double lng) {
    for (final entry in _regionCentroids.entries) {
      final c = entry.value;
      final dist = (lat - c['lat']!) * (lat - c['lat']!) +
          (lng - c['lng']!) * (lng - c['lng']!);
      if (dist < 0.5) return entry.key;
    }
    final nearest = _regionCentroids.entries
        .map((e) => MapEntry(
              e.key,
              (lat - e.value['lat']!) * (lat - e.value['lat']!) +
                  (lng - e.value['lng']!) * (lng - e.value['lng']!),
            ))
        .reduce((a, b) => a.value < b.value ? a : b);
    return nearest.key;
  }

  Map<String, double> _calculateRisk(Map<String, dynamic> crop, double t, double h) {
    final rMin = (crop['risk_t_min'] as num).toDouble();
    final rMax = (crop['risk_t_max'] as num).toDouble();
    final rhMin = (crop['risk_h_min'] as num).toDouble();
    final rhMax = (crop['risk_h_max'] as num).toDouble();

    if (t >= rMin && t <= rMax && h >= rhMin && h <= rhMax) {
      return {'disease': crop['disease'], 'level': 'High'};
    }
    if ((t >= rMin - 2 && t <= rMax + 2) && (h >= rhMin - 5 && h <= rhMax + 5)) {
      return {'disease': crop['disease'], 'level': 'Medium'};
    }
    return {'disease': crop['disease'], 'level': 'Low'};
  }

  static const Map<String, Map<String, double>> _regionCentroids = {
    'Namakkal': {'lat': 11.22, 'lng': 78.17},
    'Erode': {'lat': 11.34, 'lng': 77.72},
    'Salem': {'lat': 11.66, 'lng': 78.14},
    'Coimbatore': {'lat': 11.02, 'lng': 76.96},
    'Thanjavur': {'lat': 10.79, 'lng': 79.14},
    'Madurai': {'lat': 9.93, 'lng': 78.12},
  };

  static const List<Map<String, dynamic>> _regionCrops = {
    'Namakkal': [
      {'crop': 'Onion', 'temp_min': 25, 'temp_max': 35, 'hum_min': 60, 'hum_max': 85, 'disease': 'Purple Blotch', 'risk_t_min': 28, 'risk_t_max': 35, 'risk_h_min': 70, 'risk_h_max': 90},
      {'crop': 'Tomato', 'temp_min': 22, 'temp_max': 34, 'hum_min': 55, 'hum_max': 80, 'disease': 'Early Blight', 'risk_t_min': 25, 'risk_t_max': 32, 'risk_h_min': 75, 'risk_h_max': 90},
      {'crop': 'Chilli', 'temp_min': 24, 'temp_max': 36, 'hum_min': 50, 'hum_max': 75, 'disease': 'Leaf Curl', 'risk_t_min': 28, 'risk_t_max': 36, 'risk_h_min': 60, 'risk_h_max': 80},
      {'crop': 'Cotton', 'temp_min': 22, 'temp_max': 38, 'hum_min': 40, 'hum_max': 70, 'disease': 'Root Rot', 'risk_t_min': 30, 'risk_t_max': 38, 'risk_h_min': 70, 'risk_h_max': 85},
    ],
    'Erode': [
      {'crop': 'Turmeric', 'temp_min': 22, 'temp_max': 33, 'hum_min': 65, 'hum_max': 85, 'disease': 'Rhizome Rot', 'risk_t_min': 25, 'risk_t_max': 33, 'risk_h_min': 75, 'risk_h_max': 90},
      {'crop': 'Coconut', 'temp_min': 25, 'temp_max': 36, 'hum_min': 60, 'hum_max': 85, 'disease': 'Leaf Wilt', 'risk_t_min': 28, 'risk_t_max': 36, 'risk_h_min': 70, 'risk_h_max': 85},
      {'crop': 'Sugarcane', 'temp_min': 22, 'temp_max': 35, 'hum_min': 55, 'hum_max': 80, 'disease': 'Red Rot', 'risk_t_min': 25, 'risk_t_max': 35, 'risk_h_min': 75, 'risk_h_max': 90},
      {'crop': 'Banana', 'temp_min': 24, 'temp_max': 34, 'hum_min': 65, 'hum_max': 85, 'disease': 'Panama Wilt', 'risk_t_min': 26, 'risk_t_max': 34, 'risk_h_min': 75, 'risk_h_max': 90},
    ],
    'Salem': [
      {'crop': 'Mango', 'temp_min': 24, 'temp_max': 37, 'hum_min': 50, 'hum_max': 75, 'disease': 'Powdery Mildew', 'risk_t_min': 26, 'risk_t_max': 36, 'risk_h_min': 60, 'risk_h_max': 80},
      {'crop': 'Maize', 'temp_min': 20, 'temp_max': 36, 'hum_min': 40, 'hum_max': 70, 'disease': 'Stem Borer', 'risk_t_min': 26, 'risk_t_max': 35, 'risk_h_min': 65, 'risk_h_max': 85},
      {'crop': 'Groundnut', 'temp_min': 24, 'temp_max': 34, 'hum_min': 50, 'hum_max': 75, 'disease': 'Rust', 'risk_t_min': 26, 'risk_t_max': 34, 'risk_h_min': 70, 'risk_h_max': 90},
    ],
    'Coimbatore': [
      {'crop': 'Coconut', 'temp_min': 25, 'temp_max': 36, 'hum_min': 60, 'hum_max': 85, 'disease': 'Leaf Wilt', 'risk_t_min': 28, 'risk_t_max': 36, 'risk_h_min': 70, 'risk_h_max': 85},
      {'crop': 'Banana', 'temp_min': 24, 'temp_max': 34, 'hum_min': 65, 'hum_max': 85, 'disease': 'Panama Wilt', 'risk_t_min': 26, 'risk_t_max': 34, 'risk_h_min': 75, 'risk_h_max': 90},
      {'crop': 'Coffee', 'temp_min': 18, 'temp_max': 28, 'hum_min': 70, 'hum_max': 90, 'disease': 'Leaf Rust', 'risk_t_min': 20, 'risk_t_max': 28, 'risk_h_min': 80, 'risk_h_max': 95},
    ],
    'Thanjavur': [
      {'crop': 'Paddy', 'temp_min': 22, 'temp_max': 34, 'hum_min': 65, 'hum_max': 90, 'disease': 'Blast Disease', 'risk_t_min': 25, 'risk_t_max': 33, 'risk_h_min': 80, 'risk_h_max': 95},
      {'crop': 'Sugarcane', 'temp_min': 22, 'temp_max': 35, 'hum_min': 55, 'hum_max': 80, 'disease': 'Red Rot', 'risk_t_min': 25, 'risk_t_max': 35, 'risk_h_min': 75, 'risk_h_max': 90},
    ],
    'Madurai': [
      {'crop': 'Cotton', 'temp_min': 22, 'temp_max': 38, 'hum_min': 40, 'hum_max': 70, 'disease': 'Root Rot', 'risk_t_min': 30, 'risk_t_max': 38, 'risk_h_min': 70, 'risk_h_max': 85},
      {'crop': 'Chilli', 'temp_min': 24, 'temp_max': 36, 'hum_min': 50, 'hum_max': 75, 'disease': 'Leaf Curl', 'risk_t_min': 28, 'risk_t_max': 36, 'risk_h_min': 60, 'risk_h_max': 80},
      {'crop': 'Onion', 'temp_min': 25, 'temp_max': 35, 'hum_min': 60, 'hum_max': 85, 'disease': 'Purple Blotch', 'risk_t_min': 28, 'risk_t_max': 35, 'risk_h_min': 70, 'risk_h_max': 90},
    ],
  };

  static const Map<String, String> _tipsEn = {
    'Onion': 'Spray Mancozeb 2g/L every 7 days. Ensure proper drainage.',
    'Tomato': 'Remove infected leaves. Spray Copper Oxychloride 3g/L.',
    'Chilli': 'Use neem oil 5ml/L. Remove curled leaves immediately.',
    'Cotton': 'Avoid waterlogging. Apply Trichoderma viride 5g/kg seed.',
    'Turmeric': 'Treat seeds with Carbendazim 2g/kg before sowing.',
    'Coconut': 'Remove infected fronds. Apply Bordeaux mixture 1%.',
    'Sugarcane': 'Use disease-free setts. Apply Carbendazim 1g/L.',
    'Banana': 'Use tissue culture plants. Apply Pseudomonas 10g/plant.',
    'Mango': 'Spray Sulfur 2g/L during flowering. Prune affected branches.',
    'Paddy': 'Maintain proper spacing. Spray Tricyclazole 0.6g/L.',
    'Maize': 'Apply Carbofuran 8kg/ha at sowing time.',
    'Groundnut': 'Spray Mancozeb 2g/L at 15-day intervals.',
    'Coffee': 'Prune for ventilation. Spray Copper fungicide 3g/L.',
  };

  static const Map<String, String> _tipsTa = {
    'Onion': 'ஒவ்வொரு 7 நாட்களுக்கும் மான்கோசெப் 2g/L தெளிக்கவும். நீர் வடிகால் உறுதி செய்யவும்.',
    'Tomato': 'பாதிக்கப்பட்ட இலைகளை அகற்றவும். காப்பர் ஆக்ஸிகுளோரைடு 3g/L தெளிக்கவும்.',
    'Chilli': 'வேப்ப எண்ணெய் 5ml/L பயன்படுத்தவும். சுருண்ட இலைகளை உடனே அகற்றவும்.',
    'Cotton': 'நீர் தேக்கத்தை தவிர்க்கவும். டிரைக்கோடெர்மா 5g/kg விதை நேர்த்தி செய்யவும்.',
    'Turmeric': 'விதை நேர்த்திக்கு கார்பென்டாசிம் 2g/kg பயன்படுத்தவும்.',
    'Coconut': 'பாதிக்கப்பட்ட ஓலைகளை அகற்றவும். போர்டோ கலவை 1% தெளிக்கவும்.',
    'Sugarcane': 'நோயற்ற கரும்புத் தண்டுகளை பயன்படுத்தவும். கார்பென்டாசிம் 1g/L தெளிக்கவும்.',
    'Banana': 'திசு வளர்ப்பு செடிகளை பயன்படுத்தவும். சூடோமோனாஸ் 10g/செடி இடவும்.',
    'Mango': 'பூக்கும் காலத்தில் கந்தகம் 2g/L தெளிக்கவும். பாதித்த கிளைகளை வெட்டவும்.',
    'Paddy': 'சரியான இடைவெளியில் நடவு செய்யவும். டிரைசைக்லசோல் 0.6g/L தெளிக்கவும்.',
    'Maize': 'விதைப்பின் போது கார்போஃப்யூரான் 8kg/ha இடவும்.',
    'Groundnut': '15 நாட்கள் இடைவெளியில் மான்கோசெப் 2g/L தெளிக்கவும்.',
    'Coffee': 'காற்றோட்டத்திற்காக கத்தரிக்கவும். காப்பர் பூஞ்சைக் கொல்லி 3g/L தெளிக்கவும்.',
  };
}
