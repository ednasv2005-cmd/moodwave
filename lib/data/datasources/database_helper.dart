import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/mood_entry.dart';
import '../models/activity_model.dart';
import '../../core/constants/mood_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moodwave_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        moodValue INTEGER NOT NULL,
        energyLevel INTEGER NOT NULL,
        note TEXT,
        activities TEXT,
        sleepHours REAL DEFAULT 7.0,
        stepsCount INTEGER DEFAULT 6000,
        sentimentLabel TEXT,
        sentimentScore REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        category TEXT,
        isCustom INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_mood_entries_date ON mood_entries (date)');

    // Insertar actividades por defecto
    for (var act in MoodConstants.defaultActivities) {
      await db.insert('activities', {
        'id': act['name']!.toLowerCase(),
        'name': act['name']!,
        'icon': act['icon']!,
        'category': act['category']!,
        'isCustom': 0,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración Etapa 1 -> Etapa 2
      try {
        await db.execute('ALTER TABLE mood_entries ADD COLUMN sleepHours REAL DEFAULT 7.0');
        await db.execute('ALTER TABLE mood_entries ADD COLUMN stepsCount INTEGER DEFAULT 6000');
        await db.execute('ALTER TABLE mood_entries ADD COLUMN sentimentLabel TEXT');
        await db.execute('ALTER TABLE mood_entries ADD COLUMN sentimentScore REAL');
      } catch (_) {}
    }
  }

  // --- Operaciones de Registros de Ánimo ---

  Future<int> insertEntry(MoodEntry entry) async {
    final db = await database;
    return await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEntry(MoodEntry entry) async {
    final db = await database;
    return await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await database;
    return await db.delete(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      orderBy: 'date DESC',
    );
    return maps.map((e) => MoodEntry.fromMap(e)).toList();
  }

  Future<MoodEntry?> getEntryByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final results = await db.query(
      'mood_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return MoodEntry.fromMap(results.first);
    }
    return null;
  }

  // Consulta SQL con agregaciones estadísticas directas
  Future<Map<String, dynamic>> getAggregateStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalEntries,
        AVG(moodValue) as avgMood,
        AVG(energyLevel) as avgEnergy,
        AVG(sleepHours) as avgSleep,
        AVG(stepsCount) as avgSteps,
        MIN(moodValue) as minMood,
        MAX(moodValue) as maxMood
      FROM mood_entries
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }

  // --- Operaciones de Actividades ---

  Future<List<ActivityModel>> getAllActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      orderBy: 'isCustom ASC, name ASC',
    );
    return maps.map((e) => ActivityModel.fromMap(e)).toList();
  }

  Future<int> insertActivity(ActivityModel activity) async {
    final db = await database;
    return await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteActivity(String id) async {
    final db = await database;
    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Control ético del usuario: Borrar todos los datos ("Derecho al olvido")
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('mood_entries');
  }

  Future<void> replaceAllEntries(List<MoodEntry> entries) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('mood_entries');
    for (var entry in entries) {
      batch.insert('mood_entries', entry.toMap());
    }
    await batch.commit(noResult: true);
  }
}

