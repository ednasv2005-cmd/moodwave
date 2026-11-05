import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/models/mood_entry.dart';

class SyntheticDataGenerator {
  /// Genera 90 días de datos con patrones estadísticos plantados
  static List<MoodEntry> generate90Days() {
    final List<MoodEntry> entries = [];
    final random = Random(42); // Semilla fija para reproducibilidad matemática
    const uuid = Uuid();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final exerciseNotes = [
      'Salí a correr por la mañana, me sentí lleno de vitalidad y despejado.',
      'Fui al gimnasio con amigos, sesión intensa pero muy gratificante.',
      'Caminata larga por el parque, excelente momento para pensar y respirar.',
      'Entrenamiento de fuerza y estiramientos, terminé con mucha energía.',
    ];

    final workNotes = [
      'Día pesado en la oficina con entregas acumuladas y algo de tensión.',
      'Mucho trabajo pendiente y juntas largas, terminé algo agotado.',
      'Resolví varios pendientes laborales pero el ritmo estuvo muy demandante.',
      'Jornada laboral extensa, poco tiempo para descansar.',
    ];

    final familyNotes = [
      'Comida familiar el fin de semana, pláticas amenas y risas.',
      'Tarde tranquila conviviendo en casa con la familia.',
      'Visitamos a mis abuelos, me dio mucha paz verlos contentos.',
    ];

    final restNotes = [
      'Día de descanso total, me dediqué a leer y recargar baterías.',
      'Dormí hasta tarde y disfruté una tarde sin alarmas ni prisa.',
      'Día tranquilo desconectado de pantallas y estrés.',
    ];

    for (int i = 89; i >= 0; i--) {
      final date = today.subtract(Duration(days: i, hours: 21));
      final dayOfWeek = date.weekday; // 1 = Lunes, 7 = Domingo

      // Patrón 1: Fines de semana vs días laborales
      final isWeekend = (dayOfWeek == 6 || dayOfWeek == 7);

      // Selección de actividades
      final activities = <String>[];
      final rollEx = random.nextDouble();
      final rollWork = random.nextDouble();
      final rollFam = random.nextDouble();
      final rollRest = random.nextDouble();

      // Probabilidades según día
      final bool hasExercise = rollEx < 0.45;
      final bool hasWork = !isWeekend && rollWork < 0.85;
      final bool hasFamily = (isWeekend && rollFam < 0.70) || (!isWeekend && rollFam < 0.25);
      final bool hasRest = (isWeekend && rollRest < 0.60) || (!isWeekend && rollRest < 0.20);

      if (hasExercise) activities.add('Ejercicio');
      if (hasWork) activities.add('Trabajo');
      if (hasFamily) activities.add('Familia');
      if (hasRest) activities.add('Descanso');
      if (random.nextDouble() < 0.35) activities.add('Entretenimiento');
      if (random.nextDouble() < 0.30) activities.add('Estudio');

      // Patrón plantado: Sueño y Pasos
      double sleepHours;
      if (hasRest || isWeekend) {
        sleepHours = 7.5 + random.nextDouble() * 1.5; // 7.5 a 9.0 hrs
      } else if (hasWork) {
        sleepHours = 5.5 + random.nextDouble() * 2.0; // 5.5 a 7.5 hrs
      } else {
        sleepHours = 6.5 + random.nextDouble() * 1.5;
      }

      int stepsCount;
      if (hasExercise) {
        stepsCount = 8000 + random.nextInt(4500); // 8,000 a 12,500 pasos
      } else if (hasWork) {
        stepsCount = 3000 + random.nextInt(3500); // 3,000 a 6,500 pasos
      } else {
        stepsCount = 4000 + random.nextInt(3000);
      }

      // Cálculo del estado de ánimo con efecto plantado:
      // Base general: 6.0 (Bien)
      double moodScore = 6.0;

      // Ejercicio planta +1.4 puntos aproximadamente
      if (hasExercise) moodScore += 1.4 + (random.nextDouble() * 0.4 - 0.2);

      // Trabajo planta -0.6 a -0.8 puntos
      if (hasWork) moodScore -= 0.7 + (random.nextDouble() * 0.4 - 0.2);

      // Familia planta +0.8 puntos
      if (hasFamily) moodScore += 0.8 + (random.nextDouble() * 0.3 - 0.15);

      // Sueño: < 6 hrs resta, 7-9 hrs suma
      if (sleepHours < 6.0) {
        moodScore -= 1.0;
      } else if (sleepHours >= 7.5 && sleepHours <= 9.0) {
        moodScore += 0.6;
      }

      // Ruido aleatorio controlado
      moodScore += (random.nextDouble() * 0.8 - 0.4);

      // Clampear a 1 - 8
      int moodValue = moodScore.round().clamp(1, 8);

      // Energía relacionada con sueño y ejercicio
      double energyScore = 5.0;
      if (hasExercise) energyScore += 2.5;
      if (sleepHours >= 7.5) energyScore += 1.8;
      if (hasWork && sleepHours < 6.5) energyScore -= 2.0;
      energyScore += (random.nextDouble() * 1.0 - 0.5);
      int energyLevel = energyScore.round().clamp(1, 10);

      // Nota del diario
      String note;
      if (hasExercise && random.nextBool()) {
        note = exerciseNotes[random.nextInt(exerciseNotes.length)];
      } else if (hasWork && random.nextBool()) {
        note = workNotes[random.nextInt(workNotes.length)];
      } else if (hasFamily && random.nextBool()) {
        note = familyNotes[random.nextInt(familyNotes.length)];
      } else if (hasRest) {
        note = restNotes[random.nextInt(restNotes.length)];
      } else {
        note = 'Día regular completando pendientes y descansando en casa.';
      }

      // Etiqueta de sentimiento
      String sentimentLabel;
      double sentimentScore;
      if (moodValue >= 6) {
        sentimentLabel = 'positivo';
        sentimentScore = 0.4 + (moodValue - 5) * 0.15;
      } else if (moodValue <= 3) {
        sentimentLabel = 'negativo';
        sentimentScore = -0.3 - (4 - moodValue) * 0.18;
      } else {
        sentimentLabel = 'neutro';
        sentimentScore = 0.05 * (random.nextDouble() * 2 - 1);
      }

      entries.add(
        MoodEntry(
          id: uuid.v4(),
          date: date,
          moodValue: moodValue,
          energyLevel: energyLevel,
          note: note,
          activities: activities,
          sleepHours: double.parse(sleepHours.toStringAsFixed(1)),
          stepsCount: stepsCount,
          sentimentLabel: sentimentLabel,
          sentimentScore: double.parse(sentimentScore.toStringAsFixed(2)),
        ),
      );
    }

    return entries;
  }
}

