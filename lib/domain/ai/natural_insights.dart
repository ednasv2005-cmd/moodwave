import '../../data/models/mood_entry.dart';
import '../analytics/emotional_stats.dart';
import '../analytics/correlation_engine.dart';

class InsightItem {
  final String icon;
  final String title;
  final String text;
  final String sampleExplanation; // Explicabilidad: n registros, rango de fechas
  final String category; // 'Sueño', 'Actividad', 'Pasos', 'Tendencia'

  InsightItem({
    required this.icon,
    required this.title,
    required this.text,
    required this.sampleExplanation,
    required this.category,
  });
}

class NaturalInsightsGenerator {
  /// Genera insights en lenguaje natural con estricto apego ético y estadístico
  static List<InsightItem> generateInsights(List<MoodEntry> entries) {
    if (entries.length < 5) {
      return [
        InsightItem(
          icon: '🌱',
          title: 'Comenzando tu camino',
          text: 'Continúa registrando tus días. Se requieren al menos 5 a 14 registros para identificar asociaciones confiables con tus hábitos.',
          sampleExplanation: 'Actualmente cuentas con ${entries.length} registros.',
          category: 'Inicio',
        ),
      ];
    }

    final List<InsightItem> insights = [];
    final stats = EmotionalStatsCalculator.calculate(entries);

    // 1. Análisis Sueño vs Estado de Ánimo
    final optimalSleepEntries = entries.where((e) => e.sleepHours >= 7.0 && e.sleepHours <= 9.0).toList();
    final lowSleepEntries = entries.where((e) => e.sleepHours < 6.0).toList();

    if (optimalSleepEntries.length >= 3 && lowSleepEntries.length >= 2) {
      final optAvg = optimalSleepEntries.map((e) => e.moodValue).reduce((a, b) => a + b) / optimalSleepEntries.length;
      final lowAvg = lowSleepEntries.map((e) => e.moodValue).reduce((a, b) => a + b) / lowSleepEntries.length;
      final diff = optAvg - lowAvg;

      if (diff > 0.5) {
        insights.add(
          InsightItem(
            icon: '🌙',
            title: 'Asociación Sueño - Bienestar',
            text: 'En tus registros, los días con 7–9 horas de sueño presentan un estado de ánimo promedio '
                '${diff.toStringAsFixed(1)} puntos superior a los días con menos de 6 horas. Se presenta como un patrón observado, no como diagnóstico.',
            sampleExplanation: 'Basado en ${optimalSleepEntries.length} días de sueño óptimo vs ${lowSleepEntries.length} días de sueño reducido.',
            category: 'Sueño',
          ),
        );
      }
    }

    // 2. Análisis Pasos vs Energía
    final highStepsEntries = entries.where((e) => e.stepsCount >= 7500).toList();
    final lowStepsEntries = entries.where((e) => e.stepsCount < 4000).toList();

    if (highStepsEntries.length >= 3 && lowStepsEntries.length >= 2) {
      final highEnergyAvg = highStepsEntries.map((e) => e.energyLevel).reduce((a, b) => a + b) / highStepsEntries.length;
      final lowEnergyAvg = lowStepsEntries.map((e) => e.energyLevel).reduce((a, b) => a + b) / lowStepsEntries.length;
      final energyDiff = highEnergyAvg - lowEnergyAvg;

      if (energyDiff > 0.8) {
        insights.add(
          InsightItem(
            icon: '👟',
            title: 'Movimiento y Nivel de Energía',
            text: 'Se observa una relación positiva: en los días con más de 7,500 pasos tu nivel de energía registrado '
                'promedió ${energyDiff.toStringAsFixed(1)} puntos más alto que en días con menor movilidad.',
            sampleExplanation: 'Muestra: ${highStepsEntries.length} días activos vs ${lowStepsEntries.length} días sedentarios.',
            category: 'Pasos',
          ),
        );
      }
    }

    // 3. Análisis Actividades con Correlaciones Significativas
    final correlations = CorrelationEngine.analyze(entries);
    for (var corr in correlations) {
      if (corr.hasSufficientData && corr.cohensD.abs() >= 0.4) {
        final icon = corr.diffFromGlobal > 0 ? '✨' : '💼';
        insights.add(
          InsightItem(
            icon: icon,
            title: 'Patrón con ${corr.activityName}',
            text: corr.insightText,
            sampleExplanation: 'Analizado con n=${corr.countWith} registros con ${corr.activityName} '
                'frente a n=${corr.countWithout} sin ella. Tamaño de efecto (Cohen\'s d): ${corr.cohensD} (${corr.effectLabel}).',
            category: 'Actividad',
          ),
        );
      }
    }

    // 4. Insight de Estabilidad / Racha
    if (stats.currentStreak >= 3) {
      insights.add(
        InsightItem(
          icon: '🔥',
          title: 'Hábito de Autoobservación',
          text: 'Has mantenido una racha de ${stats.currentStreak} días consecutivos registrando tu sentir. '
              'La constancia en la autoobservación fortalece tu autoconocimiento.',
          sampleExplanation: 'Racha activa consecutiva de ${stats.currentStreak} días sobre un total de ${entries.length} registros.',
          category: 'Tendencia',
        ),
      );
    }

    return insights;
  }
}

