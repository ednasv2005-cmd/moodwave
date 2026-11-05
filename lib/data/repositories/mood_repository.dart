import 'dart:convert';
import '../datasources/database_helper.dart';
import '../datasources/preference_helper.dart';
import '../models/mood_entry.dart';
import '../models/activity_model.dart';
import '../../core/security/crypto_service.dart';
import '../../domain/analytics/synthetic_data_generator.dart';

class MoodRepository {
  final DatabaseHelper _dbHelper;
  final PreferenceHelper _prefHelper;

  MoodRepository(this._dbHelper, this._prefHelper);

  // Entries
  Future<List<MoodEntry>> getAllEntries() => _dbHelper.getAllEntries();
  Future<int> saveEntry(MoodEntry entry) => _dbHelper.insertEntry(entry);
  Future<int> updateEntry(MoodEntry entry) => _dbHelper.updateEntry(entry);
  Future<int> deleteEntry(String id) => _dbHelper.deleteEntry(id);
  Future<MoodEntry?> getEntryByDate(DateTime date) => _dbHelper.getEntryByDate(date);
  Future<void> clearAllEntries() => _dbHelper.clearAllData();

  // Activities
  Future<List<ActivityModel>> getAllActivities() => _dbHelper.getAllActivities();
  Future<int> saveActivity(ActivityModel activity) => _dbHelper.insertActivity(activity);
  Future<int> deleteActivity(String id) => _dbHelper.deleteActivity(id);

  // Synthetic Data Generator (Etapa 2)
  Future<void> populateWithSyntheticData() async {
    final syntheticEntries = SyntheticDataGenerator.generate90Days();
    await _dbHelper.replaceAllEntries(syntheticEntries);
  }

  // Backup cifrado (PBKDF2 + AES Stream + HMAC)
  Future<String> exportEncryptedBackup(String password) async {
    final entries = await _dbHelper.getAllEntries();
    final activities = await _dbHelper.getAllActivities();

    final data = {
      'app': 'MoodWave',
      'version': '2.0',
      'exportDate': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => e.toMap()).toList(),
      'activities': activities.map((a) => a.toMap()).toList(),
    };

    final jsonString = jsonEncode(data);
    final encryptedPackage = CryptoService.encryptData(jsonString, password);
    return jsonEncode(encryptedPackage);
  }

  Future<int> importEncryptedBackup(String encryptedJsonString, String password) async {
    final encryptedPackage = jsonDecode(encryptedJsonString) as Map<String, dynamic>;
    final decryptedString = CryptoService.decryptData(encryptedPackage, password);

    final data = jsonDecode(decryptedString) as Map<String, dynamic>;
    final rawEntries = data['entries'] as List<dynamic>;

    final List<MoodEntry> imported = rawEntries
        .map((e) => MoodEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    await _dbHelper.replaceAllEntries(imported);
    return imported.length;
  }

  // Preferences
  PreferenceHelper get preferences => _prefHelper;
}

