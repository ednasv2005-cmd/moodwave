import '../../data/models/mood_entry.dart';
import '../analytics/emotional_stats.dart';

class DayClusterArchetype {
  final String title;
  final String icon;
  final String description;
  final int count;
  final double avgMood;
  final double avgEnergy;
  final List<String> typicalActivities;

  DayClusterArchetype({
    required this.title,
    required this.icon,
    required this.description,
    required this.count,
    required this.avgMood,
    required this.avgEnergy,
    required this.typicalActivities,
  });
}

class AnomalyAlert {
  final bool hasAnomaly;
  final String title;
  final String message;
  final int consecutiveDaysBelow;

  AnomalyAlert({
    required this.hasAnomaly,
    required this.title,
    required this.message,
    required this.consecutiveDaysBelow,
  });

  static AnomalyAlert none() => AnomalyAlert(
        hasAnomaly: false,
        title: '',
        message: '',
        consecutiveDaysBelow: 0,
      );
}

class PatternClusterer {
  /// Clasifica los días en 4 arquetipos de patrones conductuales
  static List<DayClusterArchetype> clusterDays(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];

    final List<MoodEntry> vitalDays = [];
    final List<MoodEntry> demandingDays = [];
    final List<MoodEntry> burnoutDays = [];
    final List<MoodEntry> rechargeDays = [];

    for (var e in entries) {
      final isHighMood = e.moodValue >= 7;
      final isLowMood = e.moodValue <= 4;
      final isHighEnergy = e.energyLevel >= 7;
      final isLowEnergy = e.energyLevel <= 4;
      final hasWork = e.activities.contains('Trabajo') || e.activities.contains('Estudio');
      final hasRestOrExercise = e.activities.contains('Ejercicio') || e.activities.contains('Descanso');

      if (isHighMood && isHighEnergy) {
        vitalDays.add(e);
      } else if (isLowMood && isLowEnergy && hasWork) {
        burnoutDays.add(e);
      } else if (hasWork && !isLowMood) {
        demandingDays.add(e);
      } else if (hasRestOrExercise || e.sleepHours >= 7.5) {
        rechargeDays.add(e);
      } else {
        demandingDays.add(e);
      }
    }

    final List<DayClusterArchetype> clusters = [];

    if (vitalDays.isNotEmpty) {
      clusters.add(
        DayClusterArchetype(
          title: 'Días de Vitalidad y Plenitud',
          icon: '⚡',
          description: 'Jornadas con ánimo elevado y energía sobresaliente, asociadas frecuentemente a ejercicio y logros.',
          count: vitalDays.length,
          avgMood: double.parse((vitalDays.map((e) => e.moodValue).reduce((a, b) => a + b) / vitalDays.length).toStringAsFixed(1)),
          avgEnergy: double.parse((vitalDays.map((e) => e.energyLevel).reduce((a, b) => a + b) / vitalDays.length).toStringAsFixed(1)),
          typicalActivities: ['Ejercicio', 'Familia', 'Amigos'],
        ),
      );
    }

    if (demandingDays.isNotEmpty) {
      clusters.add(
        DayClusterArchetype(
          title: 'Días Productivos Exigentes',
          icon: '💼',
          description: 'Jornadas enfocadas en metas laborales o académicas con estabilidad emocional pero gasto de energía.',
          count: demandingDays.length,
          avgMood: double.parse((demandingDays.map((e) => e.moodValue).reduce((a, b) => a + b) / demandingDays.length).toStringAsFixed(1)),
          avgEnergy: double.parse((demandingDays.map((e) => e.energyLevel).reduce((a, b) => a + b) / demandingDays.length).toStringAsFixed(1)),
          typicalActivities: ['Trabajo', 'Estudio', 'Tareas domésticas'],
        ),
      );
    }

    if (burnoutDays.isNotEmpty) {
      clusters.add(
        DayClusterArchetype(
          title: 'Días de Tensión o Carga',
          icon: '🌧️',
          description: 'Jornadas donde la combinación de exigencia y menor descanso se asoció a un estado de ánimo más sensible.',
          count: burnoutDays.length,
          avgMood: double.parse((burnoutDays.map((e) => e.moodValue).reduce((a, b) => a + b) / burnoutDays.length).toStringAsFixed(1)),
          avgEnergy: double.parse((burnoutDays.map((e) => e.energyLevel).reduce((a, b) => a + b) / burnoutDays.length).toStringAsFixed(1)),
          typicalActivities: ['Trabajo', 'Poco sueño'],
        ),
      );
    }

    if (rechargeDays.isNotEmpty) {
      clusters.add(
        DayClusterArchetype(
          title: 'Días de Recarga y Calma',
          icon: '🛋️',
          description: 'Jornadas de recuperación, ocio tranquilo y sueño reparador que restablecen tu energía basal.',
          count: rechargeDays.length,
          avgMood: double.parse((rechargeDays.map((e) => e.moodValue).reduce((a, b) => a + b) / rechargeDays.length).toStringAsFixed(1)),
          avgEnergy: double.parse((rechargeDays.map((e) => e.energyLevel).reduce((a, b) => a + b) / rechargeDays.length).toStringAsFixed(1)),
          typicalActivities: ['Descanso', 'Entretenimiento'],
        ),
      );
    }

    return clusters;
  }

  /// Detección de anomalías: avisa si el ánimo permanece bajo durante 3 o más días consecutivos
  static AnomalyAlert detectAnomalies(List<MoodEntry> entries) {
    if (entries.length < 5) return AnomalyAlert.none();

    final stats = EmotionalStatsCalculator.calculate(entries);
    final threshold = stats.mean - (1.2 * stats.standardDeviation);

    // Ordenar cronológicamente descendente (más reciente primero)
    final sortedDesc = List<MoodEntry>.from(entries)..sort((a, b) => b.date.compareTo(a.date));

    int consecutiveLow = 0;
    for (var e in sortedDesc) {
      if (e.moodValue < threshold || e.moodValue <= 3) {
        consecutiveLow++;
      } else {
        break;
      }
    }

    if (consecutiveLow >= 3) {
      return AnomalyAlert(
        hasAnomaly: true,
        title: 'Pausa para el Autocuidado',
        message: 'Se observa que en tus últimos $consecutiveLow registros tu estado de ánimo ha estado por debajo '
            'de tu media habitual (${stats.mean} pts). Recuerda ser compasivo contigo mismo, descansar y apoyarte en personas de confianza si lo requieres.',
        consecutiveDaysBelow: consecutiveLow,
      );
    }

    return AnomalyAlert.none();
  }
}

