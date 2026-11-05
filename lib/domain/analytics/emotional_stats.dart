import 'dart:math';
import '../../data/models/mood_entry.dart';

class EmotionalStatsResult {
  final double mean;
  final double median;
  final List<int> mode;
  final double standardDeviation;
  final int totalCount;
  final int currentStreak;
  final double energyMean;
  final double sleepMean;
  final double stepsMean;

  const EmotionalStatsResult({
    required this.mean,
    required this.median,
    required this.mode,
    required this.standardDeviation,
    required this.totalCount,
    required this.currentStreak,
    required this.energyMean,
    required this.sleepMean,
    required this.stepsMean,
  });

  static EmotionalStatsResult empty() {
    return const EmotionalStatsResult(
      mean: 0.0,
      median: 0.0,
      mode: [],
      standardDeviation: 0.0,
      totalCount: 0,
      currentStreak: 0,
      energyMean: 0.0,
      sleepMean: 0.0,
      stepsMean: 0.0,
    );
  }
}

class EmotionalStatsCalculator {
  /// Calcula estadísticas completas para una lista de registros
  static EmotionalStatsResult calculate(List<MoodEntry> entries) {
    if (entries.isEmpty) return EmotionalStatsResult.empty();

    final moodValues = entries.map((e) => e.moodValue).toList();
    final energyValues = entries.map((e) => e.energyLevel).toList();
    final sleepValues = entries.map((e) => e.sleepHours).toList();
    final stepsValues = entries.map((e) => e.stepsCount).toList();

    final mean = calculateMean(moodValues);
    final median = calculateMedian(moodValues);
    final mode = calculateMode(moodValues);
    final stdDev = calculateStdDev(moodValues, mean);
    final streak = calculateStreak(entries);

    final energyMean = calculateMean(energyValues);
    final sleepMean = sleepValues.isEmpty
        ? 0.0
        : sleepValues.reduce((a, b) => a + b) / sleepValues.length;
    final stepsMean = stepsValues.isEmpty
        ? 0.0
        : stepsValues.reduce((a, b) => a + b) / stepsValues.length;

    return EmotionalStatsResult(
      mean: double.parse(mean.toStringAsFixed(2)),
      median: double.parse(median.toStringAsFixed(2)),
      mode: mode,
      standardDeviation: double.parse(stdDev.toStringAsFixed(2)),
      totalCount: entries.length,
      currentStreak: streak,
      energyMean: double.parse(energyMean.toStringAsFixed(2)),
      sleepMean: double.parse(sleepMean.toStringAsFixed(2)),
      stepsMean: double.parse(stepsMean.toStringAsFixed(0)),
    );
  }

  /// Media aritmética: sum(x) / N
  static double calculateMean(List<int> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }

  /// Mediana: valor central de la lista ordenada
  static double calculateMedian(List<int> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<int>.from(values)..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  /// Moda: elemento(s) con mayor frecuencia
  static List<int> calculateMode(List<int> values) {
    if (values.isEmpty) return [];
    final frequencyMap = <int, int>{};
    for (final v in values) {
      frequencyMap[v] = (frequencyMap[v] ?? 0) + 1;
    }

    int maxFrequency = 0;
    for (final count in frequencyMap.values) {
      if (count > maxFrequency) {
        maxFrequency = count;
      }
    }

    final modes = frequencyMap.entries
        .where((entry) => entry.value == maxFrequency)
        .map((entry) => entry.key)
        .toList();
    modes.sort();
    return modes;
  }

  /// Desviación estándar poblacional: sqrt( sum( (x - mean)^2 ) / N )
  static double calculateStdDev(List<int> values, double mean) {
    if (values.length <= 1) return 0.0;
    double sumSquaredDiff = 0.0;
    for (final val in values) {
      final diff = val - mean;
      sumSquaredDiff += diff * diff;
    }
    return sqrt(sumSquaredDiff / values.length);
  }

  /// Racha de días consecutivos registrados
  static int calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    // Normalizar fechas a día sin hora y ordenar descendente
    final uniqueDays = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Si el día más reciente no es hoy ni ayer, la racha activa es 0
    if (uniqueDays.first.isBefore(yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < uniqueDays.length - 1; i++) {
      final diff = uniqueDays[i].difference(uniqueDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Filtro por ventana de tiempo (7 días, 30 días, etc.)
  static List<MoodEntry> filterByDays(List<MoodEntry> entries, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((e) => e.date.isAfter(cutoff)).toList();
  }
}

