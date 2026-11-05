import 'dart:math';
import '../../data/models/mood_entry.dart';

class TrendDataPoint {
  final DateTime date;
  final double value;
  final double movingAverage;
  final String label;

  TrendDataPoint({
    required this.date,
    required this.value,
    required this.movingAverage,
    required this.label,
  });
}

class TrendAnalysisResult {
  final int daysWindow;
  final List<TrendDataPoint> points;
  final double startAvg;
  final double endAvg;
  final double percentChange;
  final String trendDescription;

  TrendAnalysisResult({
    required this.daysWindow,
    required this.points,
    required this.startAvg,
    required this.endAvg,
    required this.percentChange,
    required this.trendDescription,
  });
}

class TrendAnalyzer {
  /// Genera puntos ordenados temporalmente con media móvil calculada
  static TrendAnalysisResult analyzeTrends(List<MoodEntry> entries, int daysWindow, {int maWindow = 3}) {
    if (entries.isEmpty) {
      return TrendAnalysisResult(
        daysWindow: daysWindow,
        points: [],
        startAvg: 0.0,
        endAvg: 0.0,
        percentChange: 0.0,
        trendDescription: 'Aún no hay datos suficientes para calcular tendencias.',
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(Duration(days: daysWindow - 1));

    // Filtrar por ventana
    final filtered = entries.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(cutoff) && !d.isAfter(today);
    }).toList();

    // Agrupar por día (si hay más de 1 en el mismo día, calcular promedio)
    final Map<DateTime, List<int>> dailyMap = {};
    for (var entry in filtered) {
      final dayKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyMap.putIfAbsent(dayKey, () => []).add(entry.moodValue);
    }

    // Ordenar fechas cronológicamente
    final sortedDates = dailyMap.keys.toList()..sort((a, b) => a.compareTo(b));

    List<TrendDataPoint> points = [];
    List<double> dailyAverages = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final d = sortedDates[i];
      final vals = dailyMap[d]!;
      final dayAvg = vals.reduce((a, b) => a + b) / vals.length;
      dailyAverages.add(dayAvg);

      // Calcular media móvil con ventana maWindow
      final startIdx = max(0, i - maWindow + 1);
      final windowSlice = dailyAverages.sublist(startIdx, i + 1);
      final ma = windowSlice.reduce((a, b) => a + b) / windowSlice.length;

      points.add(
        TrendDataPoint(
          date: d,
          value: double.parse(dayAvg.toStringAsFixed(1)),
          movingAverage: double.parse(ma.toStringAsFixed(2)),
          label: '${d.day}/${d.month}',
        ),
      );
    }

    // Calcular cambio porcentual
    double startAvg = 0.0;
    double endAvg = 0.0;
    double percentChange = 0.0;
    String description = 'Estabilidad en tus registros.';

    if (points.length >= 4) {
      final half = points.length ~/ 2;
      final firstHalf = points.sublist(0, half).map((p) => p.value).toList();
      final secondHalf = points.sublist(half).map((p) => p.value).toList();

      startAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      endAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (startAvg > 0) {
        percentChange = ((endAvg - startAvg) / startAvg) * 100.0;
      }

      final roundedPct = percentChange.abs().toStringAsFixed(1);
      if (percentChange > 3.0) {
        description = 'Se observa una tendencia al alza: tu estado de ánimo promedio aumentó un $roundedPct% en este periodo.';
      } else if (percentChange < -3.0) {
        description = 'Se observa una tendencia a la baja: tu estado de ánimo promedio disminuyó un $roundedPct% en este periodo.';
      } else {
        description = 'Se observa un comportamiento emocional estable con variaciones menores a ±3%.';
      }
    } else {
      description = 'Registra más días consecutivos para habilitar el análisis de cambio porcentual.';
    }

    return TrendAnalysisResult(
      daysWindow: daysWindow,
      points: points,
      startAvg: double.parse(startAvg.toStringAsFixed(2)),
      endAvg: double.parse(endAvg.toStringAsFixed(2)),
      percentChange: double.parse(percentChange.toStringAsFixed(1)),
      trendDescription: description,
    );
  }
}

