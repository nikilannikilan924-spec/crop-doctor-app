import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prediction.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'crop_doctor.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> savePrediction(Prediction prediction) async {
    final db = await database;
    return db.insert('predictions', {
      'data': json.encode(prediction.toJson()),
      'created_at': prediction.timestamp.toIso8601String(),
    });
  }

  static Future<List<Prediction>> getPredictions({int limit = 20}) async {
    final db = await database;
    final results = await db.query(
      'predictions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return results.map((r) {
      return Prediction.fromJson(json.decode(r['data'] as String));
    }).toList();
  }

  static Future<int> clearHistory() async {
    final db = await database;
    return db.delete('predictions');
  }

  static Future<int> getPredictionCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM predictions');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
