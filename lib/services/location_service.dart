import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? district;
  final String? state;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.district,
    this.state,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  LocationResult? _lastLocation;

  Future<LocationResult?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? district;
    String? state;
    String? placeName;

    if (placemarks.isNotEmpty) {
      final pm = placemarks.first;
      placeName = pm.locality ?? pm.subAdministrativeArea;
      district = pm.subAdministrativeArea;
      state = pm.administrativeArea;
    }

    _lastLocation = LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      placeName: placeName,
      district: district,
      state: state,
    );

    return _lastLocation;
  }

  LocationResult? get lastLocation => _lastLocation;

  String get regionName {
    if (_lastLocation?.district != null) {
      return _lastLocation!.district!.replaceAll(' District', '');
    }
    return 'Unknown';
  }
}
