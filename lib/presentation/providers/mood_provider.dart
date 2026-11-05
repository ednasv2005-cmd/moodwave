import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/mood_repository.dart';
import '../../domain/analytics/emotional_stats.dart';
import '../../domain/analytics/trend_analyzer.dart';
import '../../domain/analytics/correlation_engine.dart';
import '../../domain/ai/sentiment_analyzer.dart';
import '../../domain/ai/mood_predictor.dart';
import '../../domain/ai/pattern_clusterer.dart';
import '../../domain/ai/natural_insights.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _repository;

  List<MoodEntry> _entries = [];
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  int _selectedFilterDays = 30; // 7, 30, 90

  // Analítica y Caché de IA
  EmotionalStatsResult _stats = EmotionalStatsResult.empty();
  TrendAnalysisResult? _trendResult;
  List<ActivityCorrelationStats> _correlations = [];
  List<InsightItem> _insights = [];
  List<DayClusterArchetype> _clusters = [];
  AnomalyAlert _anomalyAlert = AnomalyAlert.none();
  NextDayPrediction? _prediction;

  MoodProvider(this._repository);

  // Getters
  List<MoodEntry> get entries => _entries;
  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  int get selectedFilterDays => _selectedFilterDays;

  EmotionalStatsResult get stats => _stats;
  TrendAnalysisResult? get trendResult => _trendResult;
  List<ActivityCorrelationStats> get correlations => _correlations;
  List<InsightItem> get insights => _insights;
  List<DayClusterArchetype> get clusters => _clusters;
  AnomalyAlert get anomalyAlert => _anomalyAlert;
  NextDayPrediction? get prediction => _prediction;

  int get maxJournalChars => _repository.preferences.maxJournalChars;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadData() async {
    _entries = await _repository.getAllEntries();
    _activities = await _repository.getAllActivities();
    _recomputeAnalytics();
    notifyListeners();
  }

  void setFilterDays(int days) {
    if (_selectedFilterDays != days) {
      _selectedFilterDays = days;
      _recomputeAnalytics();
      notifyListeners();
    }
  }

  void _recomputeAnalytics() {
    // Filtrar según ventana seleccionada
    final filtered = EmotionalStatsCalculator.filterByDays(_entries, _selectedFilterDays);

    _stats = EmotionalStatsCalculator.calculate(filtered.isNotEmpty ? filtered : _entries);
    _trendResult = TrendAnalyzer.analyzeTrends(_entries, _selectedFilterDays);
    _correlations = CorrelationEngine.analyze(_entries);
    _insights = NaturalInsightsGenerator.generateInsights(_entries);
    _clusters = PatternClusterer.clusterDays(_entries);
    _anomalyAlert = PatternClusterer.detectAnomalies(_entries);
    _prediction = MoodPredictor.predictTomorrow(_entries);
  }

  Future<void> saveEntry({
    String? id,
    required DateTime date,
    required int moodValue,
    required int energyLevel,
    required String note,
    required List<String> activities,
    double sleepHours = 7.0,
    int stepsCount = 6000,
  }) async {
    // Análisis de sentimiento local inmediato
    final sentiment = SentimentAnalyzer.analyze(note, moodValue);

    final entryId = id ?? const Uuid().v4();
    final newEntry = MoodEntry(
      id: entryId,
      date: date,
      moodValue: moodValue,
      energyLevel: energyLevel,
      note: note,
      activities: activities,
      sleepHours: sleepHours,
      stepsCount: stepsCount,
      sentimentLabel: sentiment.label,
      sentimentScore: sentiment.score,
    );

    await _repository.saveEntry(newEntry);
    await loadData();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    await loadData();
  }

  Future<void> addCustomActivity(String name, String icon, {String category = 'Personal'}) async {
    final act = ActivityModel(
      id: const Uuid().v4(),
      name: name.trim(),
      icon: icon.trim().isEmpty ? '⭐' : icon.trim(),
      category: category,
      isCustom: true,
    );
    await _repository.saveActivity(act);
    _activities = await _repository.getAllActivities();
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    await _repository.deleteActivity(id);
    _activities = await _repository.getAllActivities();
    notifyListeners();
  }

  Future<void> loadSyntheticDemoData() async {
    _isLoading = true;
    notifyListeners();

    await _repository.populateWithSyntheticData();
    await loadData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    await _repository.clearAllEntries();
    await loadData();

    _isLoading = false;
    notifyListeners();
  }

  Future<String> exportBackup(String password) => _repository.exportEncryptedBackup(password);

  Future<int> importBackup(String backupJson, String password) async {
    final count = await _repository.importEncryptedBackup(backupJson, password);
    await loadData();
    return count;
  }

  Future<void> updateMaxJournalChars(int count) async {
    await _repository.preferences.setMaxJournalChars(count);
    notifyListeners();
  }
}

