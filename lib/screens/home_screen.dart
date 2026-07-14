import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/prediction_service.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../models/prediction.dart';
import '../widgets/weather_animation.dart';
import '../widgets/field_view.dart';
import '../widgets/disease_radar.dart';
import 'prediction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final PredictionService _predictionService = PredictionService();

  LocationResult? _location;
  WeatherData? _weather;
  Prediction? _prediction;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadInitialData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (loc != null && mounted) {
        setState(() => _location = loc);
        await _loadWeather(loc.latitude, loc.longitude);
      } else {
        setState(() => _error = 'Location permission required');
      }
    } catch (e) {
      setState(() => _error = 'Could not get location');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadWeather(double lat, double lng) async {
    final weather = await _weatherService.getCurrentWeather(lat, lng);
    if (mounted) setState(() => _weather = weather);
  }

  Future<void> _analyze() async {
    if (_location == null) return;
    setState(() => _isAnalyzing = true);

    try {
      final prediction = await _predictionService.getPredictionOffline(
        lat: _location!.latitude,
        lng: _location!.longitude,
        temperature: _weather?.temperature ?? 30,
        humidity: _weather?.humidity ?? 70,
      );

      if (prediction != null && mounted) {
        await DatabaseService.savePrediction(prediction);
        setState(() => _prediction = prediction);

        // Auto voice in Tamil if locale is Tamil
        final locale = Localizations.localeOf(context);
        if (locale.languageCode == 'ta') {
          await TTSService().speakPrediction(
            crop: prediction.recommendedCrop,
            risk: prediction.diseaseRisk,
            cropTa: '',
          );
        }

        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PredictionScreen(prediction: prediction),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Analysis failed');
    }

    if (mounted) setState(() => _isAnalyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: WeatherBackground(
        weatherType: _weather?.weatherAnimation ?? 'normal',
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadInitialData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with location
                  _buildHeader(loc),
                  const SizedBox(height: 20),

                  // Current conditions card
                  if (_weather != null) _buildWeatherCard(loc, isDark),
                  if (_weather == null && !_isLoading)
                    _buildSkeletonCard(isDark),

                  const SizedBox(height: 16),

                  // Location info
                  if (_location != null) _buildLocationCard(loc, isDark),

                  const SizedBox(height: 20),

                  // Analyze button
                  _buildAnalyzeButton(loc),

                  const SizedBox(height: 20),

                  // Error
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _location?.placeName ?? loc.currentLocation,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (_location?.district != null)
              Text(
                _location!.district!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Text(
            loc.appName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(AppLocalizations loc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[800]!]
              : [Colors.white, const Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_weather!.temperature.round()}°C',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF4E342E),
                    ),
                  ),
                  Text(
                    _weather!.description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              // Weather icon
              Column(
                children: [
                  Icon(
                    _weather!.isRainy
                        ? Icons.water_drop
                        : _weather!.isCloudy
                            ? Icons.cloud
                            : Icons.wb_sunny,
                    size: 40,
                    color: _weather!.isRainy
                        ? Colors.blue[400]
                        : _weather!.isCloudy
                            ? Colors.grey[400]
                            : Colors.orange[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _weather!.isRainy
                        ? loc.rain
                        : _weather!.isCloudy
                            ? loc.cloudy
                            : loc.clear,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Humidity + Wind row
          Row(
            children: [
              _buildWeatherStat(
                Icons.water_drop,
                '${_weather!.humidity.round()}%',
                loc.humidity,
                Colors.blue[400]!,
              ),
              const SizedBox(width: 16),
              _buildWeatherStat(
                Icons.air,
                '${_weather!.windSpeed.round()} km/h',
                'Wind',
                Colors.teal[400]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(AppLocalizations loc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location, color: Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.currentLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _locationService.regionName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(AppLocalizations loc) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _analyze,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final scale = 1.0 + (_pulseController.value * 0.02);
          return Transform.scale(
            scale: _isAnalyzing ? 0.95 : scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isAnalyzing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    _isAnalyzing ? 'Analyzing...' : loc.analyze,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(color: Colors.green[400]),
      ),
    );
  }
}
