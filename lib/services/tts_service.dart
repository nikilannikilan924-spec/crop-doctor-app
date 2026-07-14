import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._();
  factory TTSService() => _instance;
  TTSService._();

  final FlutterTts _tts = FlutterTts();
  bool _isTamil = false;

  Future<void> init({bool tamil = false}) async {
    _isTamil = tamil;
    await _tts.setLanguage(tamil ? 'ta-IN' : 'en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  Future<void> setLanguage(bool tamil) async {
    _isTamil = tamil;
    await _tts.setLanguage(tamil ? 'ta-IN' : 'en-US');
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakPrediction({
    required String crop,
    required String risk,
    required String cropTa,
  }) async {
    if (_isTamil) {
      await speak('பரிந்துரைக்கப்படும் பயிர் $cropTa. நோய் அபாய நிலை $risk');
    } else {
      await speak('Recommended crop: $crop. Disease risk level: $risk');
    }
  }

  Future<void> stop() async => await _tts.stop();
}
