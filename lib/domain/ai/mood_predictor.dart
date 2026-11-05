import '../../data/models/mood_entry.dart';
import '../../core/constants/mood_constants.dart';

class PredictionEvaluation {
  final double modelMae;
  final double baselineYesterdayMae;
  final double baselineMeanMae;
  final bool modelOutperformsBaseline;
  final int testSampleSize;
  final String metricSummary;

  PredictionEvaluation({
    required this.modelMae,
    required this.baselineYesterdayMae,
    required this.baselineMeanMae,
    required this.modelOutperformsBaseline,
    required this.testSampleSize,
    required this.metricSummary,
  });
}

class NextDayPrediction {
  final double predictedMood;
  final int predictedMoodRounded;
  final String predictedLabel;
  final String predictedEmoji;
  final double confidencePercent;
  final List<String> contributingFactors;
  final PredictionEvaluation evaluation;

  NextDayPrediction({
    required this.predictedMood,
    required this.predictedMoodRounded,
    required this.predictedLabel,
    required this.predictedEmoji,
    required this.confidencePercent,
    required this.contributingFactors,
    required this.evaluation,
  });
}

class MoodPredictor {
  /// Realiza validación temporal walk-forward sin fuga de datos futuros
  static NextDayPrediction? predictTomorrow(List<MoodEntry> entries) {
    if (entries.length < 7) {
      return null; // Mínimo 7 días consecutivos para poder entrenar y evaluar temporalmente
    }

    // Ordenar estrictamente cronológico (del pasado al presente)
    final sorted = List<MoodEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Separación temporal: primeros 70% histórico, últimos 30% evaluación (out-of-sample)
    final int splitIdx = (sorted.length * 0.7).floor();
    final trainSet = sorted.sublist(0, splitIdx);
    final testSet = sorted.sublist(splitIdx);

    // Calcular MAE sobre el conjunto de prueba temporal
    double modelErrorSum = 0.0;
    double baselineYesterdayErrorSum = 0.0;
    double baselineMeanErrorSum = 0.0;

    final trainMean = trainSet.map((e) => e.moodValue).reduce((a, b) => a + b) / trainSet.length;

    for (int i = 0; i < testSet.length; i++) {
      final actual = testSet[i].moodValue.toDouble();
      
      // Registro anterior inmediato
      final MoodEntry prevEntry = (i == 0) ? trainSet.last : testSet[i - 1];

      // Baseline 1: Igual que ayer
      final baselineYesterday = prevEntry.moodValue.toDouble();
      baselineYesterdayErrorSum += (actual - baselineYesterday).abs();

      // Baseline 2: Media histórica de entrenamiento
      baselineMeanErrorSum += (actual - trainMean).abs();

      // Modelo Predictivo Autorregresivo Multivariable
      final pred = _computePointPrediction(prevEntry, trainMean);
      modelErrorSum += (actual - pred).abs();
    }

    final double modelMae = testSet.isNotEmpty ? modelErrorSum / testSet.length : 0.0;
    final double baselineYesterdayMae = testSet.isNotEmpty ? baselineYesterdayErrorSum / testSet.length : 0.0;
    final double baselineMeanMae = testSet.isNotEmpty ? baselineMeanErrorSum / testSet.length : 0.0;

    final bool beatsBaseline = modelMae <= baselineYesterdayMae;

    final eval = PredictionEvaluation(
      modelMae: double.parse(modelMae.toStringAsFixed(2)),
      baselineYesterdayMae: double.parse(baselineYesterdayMae.toStringAsFixed(2)),
      baselineMeanMae: double.parse(baselineMeanMae.toStringAsFixed(2)),
      modelOutperformsBaseline: beatsBaseline,
      testSampleSize: testSet.length,
      metricSummary: beatsBaseline
          ? 'El modelo predictivo obtuvo un MAE de ${modelMae.toStringAsFixed(2)}, superando al baseline trivial de persistencia (${baselineYesterdayMae.toStringAsFixed(2)}).'
          : 'El modelo obtuvo un MAE de ${modelMae.toStringAsFixed(2)} frente a ${baselineYesterdayMae.toStringAsFixed(2)} del baseline. En series volátiles, la persistencia simple suele ser competitiva.',
    );

    // Predicción para mañana usando el último registro disponible
    final lastEntry = sorted.last;
    final double fullMean = sorted.map((e) => e.moodValue).reduce((a, b) => a + b) / sorted.length;
    final double pointPred = _computePointPrediction(lastEntry, fullMean);
    final int rounded = pointPred.round().clamp(1, 8);
    final moodItem = MoodConstants.fromValue(rounded);

    final List<String> factors = [];
    if (lastEntry.sleepHours >= 7.5) {
      factors.add('Buen descanso previo (${lastEntry.sleepHours} hrs de sueño)');
    } else if (lastEntry.sleepHours < 6.0) {
      factors.add('Sueño reducido en la noche anterior (${lastEntry.sleepHours} hrs)');
    }

    if (lastEntry.activities.contains('Ejercicio')) {
      factors.add('Inercia positiva por actividad física reciente');
    }
    if (lastEntry.activities.contains('Trabajo')) {
      factors.add('Carga laboral registrada en la jornada');
    }

    // Confianza calculada a partir del inverso del MAE
    double confidence = (1.0 - (modelMae / 7.0)).clamp(0.5, 0.95) * 100.0;

    return NextDayPrediction(
      predictedMood: double.parse(pointPred.toStringAsFixed(1)),
      predictedMoodRounded: rounded,
      predictedLabel: moodItem.label,
      predictedEmoji: moodItem.emoji,
      confidencePercent: double.parse(confidence.toStringAsFixed(0)),
      contributingFactors: factors.isNotEmpty ? factors : ['Inercia del estado de ánimo reciente'],
      evaluation: eval,
    );
  }

  static double _computePointPrediction(MoodEntry prev, double historicalMean) {
    // Ponderación: 50% inercia inmediata (ayer) + 30% media histórica + 20% factores sueño/energía
    double score = (0.50 * prev.moodValue) + (0.30 * historicalMean);

    // Ajuste por sueño
    if (prev.sleepHours >= 7.5) {
      score += 0.35;
    } else if (prev.sleepHours < 6.0) {
      score -= 0.45;
    }

    // Ajuste por nivel de energía
    if (prev.energyLevel >= 8) {
      score += 0.25;
    } else if (prev.energyLevel <= 3) {
      score -= 0.35;
    }

    return score.clamp(1.0, 8.0);
  }
}

