import 'dart:math';
import '../../data/models/mood_entry.dart';

class ActivityCorrelationStats {
  final String activityName;
  final int countWith;        // n con la actividad
  final int countWithout;     // n sin la actividad
  final double avgMoodWith;    // Media de ánimo con actividad
  final double avgMoodWithout; // Media de ánimo sin actividad
  final double avgEnergyWith;  // Media de energía con actividad
  final double avgEnergyWithout;// Media de energía sin actividad
  final double diffFromGlobal; // Diferencia contra la media general
  final double pointBiserialR; // Correlación biserial puntual r_pb (-1.0 a 1.0)
  final double cohensD;        // Tamaño del efecto d de Cohen
  final String effectLabel;    // Despreciable, Pequeño, Moderado, Fuerte
  final bool hasSufficientData;// Cumple umbrales mínimos
  final String insightText;    // Redacción responsable

  ActivityCorrelationStats({
    required this.activityName,
    required this.countWith,
    required this.countWithout,
    required this.avgMoodWith,
    required this.avgMoodWithout,
    required this.avgEnergyWith,
    required this.avgEnergyWithout,
    required this.diffFromGlobal,
    required this.pointBiserialR,
    required this.cohensD,
    required this.effectLabel,
    required this.hasSufficientData,
    required this.insightText,
  });
}

class CorrelationEngine {
  static const int minTotalDaysThreshold = 14;
  static const int minActivityCountThreshold = 5;

  static const String methodJustification =
      'Se utiliza la Correlación Biserial-Puntual (r_pb) y el Tamaño del Efecto d de Cohen. '
      'Justificación matemática: La realización de una actividad es una variable dicotómica binaria '
      '(0 = no realizada, 1 = realizada), mientras que el estado de ánimo es una escala cuantitativa de 1 a 8. '
      'La correlación biserial-puntual es la derivación formal del coeficiente de Pearson para este tipo de datos. '
      'Adicionalmente, se calcula la d de Cohen para distinguir diferencias estadísticamente significativas '
      'de variaciones irrelevantes, evitando conclusiones precipitadas por comparaciones múltiples.';

  /// Calcula la correlación para todas las actividades presentes en los registros
  static List<ActivityCorrelationStats> analyze(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];

    final totalDays = entries.length;
    final globalMoodAvg = entries.map((e) => e.moodValue).reduce((a, b) => a + b) / totalDays;

    // Recopilar conjunto de actividades únicas
    final allActivities = <String>{};
    for (var e in entries) {
      allActivities.addAll(e.activities);
    }

    final List<ActivityCorrelationStats> results = [];

    for (final activity in allActivities) {
      final withActivity = entries.where((e) => e.activities.contains(activity)).toList();
      final withoutActivity = entries.where((e) => !e.activities.contains(activity)).toList();

      final n1 = withActivity.length;
      final n0 = withoutActivity.length;

      final hasMinTotal = totalDays >= minTotalDaysThreshold;
      final hasMinActivity = n1 >= minActivityCountThreshold;
      final hasSufficient = hasMinTotal && hasMinActivity && n0 >= 3;

      double avgMood1 = 0.0;
      double avgEnergy1 = 0.0;
      double avgMood0 = 0.0;
      double avgEnergy0 = 0.0;

      if (n1 > 0) {
        avgMood1 = withActivity.map((e) => e.moodValue).reduce((a, b) => a + b) / n1;
        avgEnergy1 = withActivity.map((e) => e.energyLevel).reduce((a, b) => a + b) / n1;
      }

      if (n0 > 0) {
        avgMood0 = withoutActivity.map((e) => e.moodValue).reduce((a, b) => a + b) / n0;
        avgEnergy0 = withoutActivity.map((e) => e.energyLevel).reduce((a, b) => a + b) / n0;
      }

      final diff = avgMood1 - globalMoodAvg;

      // Calcular desviaciones estándar muestrales
      double var1 = 0.0;
      for (var e in withActivity) {
        var1 += pow(e.moodValue - avgMood1, 2);
      }
      var1 = n1 > 1 ? var1 / (n1 - 1) : 0.0;

      double var0 = 0.0;
      for (var e in withoutActivity) {
        var0 += pow(e.moodValue - avgMood0, 2);
      }
      var0 = n0 > 1 ? var0 / (n0 - 1) : 0.0;

      // Desviación estándar combinada (pooled standard deviation)
      double sPooled = 0.0;
      if (n1 + n0 > 2) {
        sPooled = sqrt(((n1 - 1) * var1 + (n0 - 1) * var0) / (n1 + n0 - 2));
      }

      // Cohen's d: (M1 - M0) / sPooled
      double cohensD = sPooled > 0.001 ? (avgMood1 - avgMood0) / sPooled : 0.0;

      // Correlación Biserial-Puntual: r_pb = ((M1 - M0) / s_total) * sqrt((n1 * n0) / (n^2))
      double totalVar = 0.0;
      for (var e in entries) {
        totalVar += pow(e.moodValue - globalMoodAvg, 2);
      }
      double sTotal = sqrt(totalVar / (totalDays - 1));
      double rpb = (sTotal > 0.001 && totalDays > 1)
          ? ((avgMood1 - avgMood0) / sTotal) * sqrt((n1 * n0) / (totalDays * totalDays))
          : 0.0;

      // Clasificación de tamaño de efecto
      final absD = cohensD.abs();
      String effectLabel;
      if (absD < 0.2) {
        effectLabel = 'Diferencia mínima';
      } else if (absD < 0.5) {
        effectLabel = 'Efecto pequeño';
      } else if (absD < 0.8) {
        effectLabel = 'Efecto moderado';
      } else {
        effectLabel = 'Efecto relevante';
      }

      // Redacción responsable sin afirmar causalidad
      String insight;
      if (!hasSufficient) {
        if (!hasMinTotal) {
          insight = 'Aún no hay datos suficientes ($totalDays de $minTotalDaysThreshold días mínimos necesarios).';
        } else {
          insight = 'Aún no hay datos suficientes para "$activity" ($n1 de $minActivityCountThreshold registros necesarios).';
        }
      } else {
        final sign = diff >= 0 ? '+' : '';
        final diffStr = '$sign${diff.toStringAsFixed(1)} pts';
        if (absD < 0.2) {
          insight = 'Se observa poca o nula variación en tu estado de ánimo los días con $activity ($diffStr respecto a tu media general).';
        } else if (diff > 0) {
          insight = 'Los días con $activity registraste un estado de ánimo promedio $diffStr mayor que tu media general (asociación positiva observada).';
        } else {
          insight = 'Los días con $activity registraste un estado de ánimo promedio $diffStr menor que tu media general (asociación inversa observada).';
        }
      }

      results.add(
        ActivityCorrelationStats(
          activityName: activity,
          countWith: n1,
          countWithout: n0,
          avgMoodWith: double.parse(avgMood1.toStringAsFixed(2)),
          avgMoodWithout: double.parse(avgMood0.toStringAsFixed(2)),
          avgEnergyWith: double.parse(avgEnergy1.toStringAsFixed(2)),
          avgEnergyWithout: double.parse(avgEnergy0.toStringAsFixed(2)),
          diffFromGlobal: double.parse(diff.toStringAsFixed(2)),
          pointBiserialR: double.parse(rpb.toStringAsFixed(2)),
          cohensD: double.parse(cohensD.toStringAsFixed(2)),
          effectLabel: effectLabel,
          hasSufficientData: hasSufficient,
          insightText: insight,
        ),
      );
    }

    // Ordenar por diferencia absoluta o correlación descendente
    results.sort((a, b) => b.diffFromGlobal.abs().compareTo(a.diffFromGlobal.abs()));
    return results;
  }
}

