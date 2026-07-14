import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/prediction.dart';
import '../widgets/disease_radar.dart';
import '../widgets/risk_gauge.dart';
import '../services/tts_service.dart';

class PredictionScreen extends StatelessWidget {
  final Prediction prediction;

  const PredictionScreen({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final riskColor = prediction.riskColor;
    final cropInfo = CropInfo.crops[prediction.recommendedCrop];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + share
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.green.withOpacity(0.1),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () async {
                          await TTSService().speakPrediction(
                            crop: prediction.recommendedCrop,
                            risk: prediction.diseaseRisk,
                            cropTa: cropInfo?.nameTa ?? '',
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.green.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.green.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main result card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.grey[850]!, Colors.grey[900]!]
                        : [Colors.white, const Color(0xFFF1F8E9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Crop icon + name
                    Text(
                      cropInfo?.icon ?? '🌱',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      prediction.recommendedCrop,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (cropInfo != null)
                      Text(
                        cropInfo.nameTa,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Confidence
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Confidence: ${(prediction.confidence * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Disease risk gauge
                    DiseaseRadar(
                      riskLevel: prediction.diseaseRisk,
                      size: 180,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      prediction.diseaseName == 'None'
                          ? loc.allGood
                          : '${prediction.diseaseName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: prediction.diseaseName == 'None'
                            ? Colors.green
                            : riskColor,
                      ),
                    ),
                    Text(
                      prediction.diseaseName == 'None'
                          ? ''
                          : loc.riskLevel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),

                    const SizedBox(height: 20),

                    // Risk level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: riskColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: riskColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _riskText(loc),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current conditions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat, size: 18, color: Colors.green[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Current Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCondition(
                            Icons.thermostat,
                            '${prediction.temperature.round()}°C',
                            loc.temperature,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCondition(
                            Icons.water_drop,
                            '${prediction.humidity.round()}%',
                            loc.humidity,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Prevention tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange[700]),
                        const SizedBox(width: 6),
                        Text(
                          loc.preventionTips,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getPreventionText(context, loc),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCondition(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.green[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _riskText(AppLocalizations loc) {
    switch (prediction.diseaseRisk.toLowerCase()) {
      case 'high':
        return loc.diseaseRiskHigh;
      case 'medium':
        return loc.diseaseRiskMedium;
      default:
        return loc.diseaseRiskLow;
    }
  }

  String _getPreventionText(BuildContext context, AppLocalizations loc) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ta' && prediction.preventionTipsTa.isNotEmpty) {
      return prediction.preventionTipsTa;
    }
    return prediction.preventionTipsEn.isNotEmpty
        ? prediction.preventionTipsEn
        : 'Maintain regular monitoring. Ensure proper irrigation and drainage.';
  }
}
