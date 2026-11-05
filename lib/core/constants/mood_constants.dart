import 'package:flutter/material.dart';
import 'app_colors.dart';

class MoodItem {
  final int value;
  final String label;
  final String emoji;
  final Color color;
  final String description;

  const MoodItem({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
    required this.description,
  });
}

class MoodConstants {
  static const List<MoodItem> moods = [
    MoodItem(
      value: 1,
      label: 'Enojado',
      emoji: '😡',
      color: AppColors.moodAngry,
      description: 'Frustración, coraje o irritabilidad alta',
    ),
    MoodItem(
      value: 2,
      label: 'Triste',
      emoji: '😢',
      color: AppColors.moodSad,
      description: 'Sensación de vacío, melancolía o dolor emocional',
    ),
    MoodItem(
      value: 3,
      label: 'Deprimido',
      emoji: '😞',
      color: AppColors.moodDepressed,
      description: 'Desánimo, pesadez o apatía profunda',
    ),
    MoodItem(
      value: 4,
      label: 'Preocupado',
      emoji: '😕',
      color: AppColors.moodWorried,
      description: 'Inquietud mental, estrés o anticipación tensa',
    ),
    MoodItem(
      value: 5,
      label: 'Neutral',
      emoji: '😐',
      color: AppColors.moodNeutral,
      description: 'Día templado, sin picos emocionales marcados',
    ),
    MoodItem(
      value: 6,
      label: 'Bien',
      emoji: '🙂',
      color: AppColors.moodGood,
      description: 'Tranquilidad, ligereza y serenidad',
    ),
    MoodItem(
      value: 7,
      label: 'Feliz',
      emoji: '😄',
      color: AppColors.moodHappy,
      description: 'Alegría, satisfacción y entusiasmo activo',
    ),
    MoodItem(
      value: 8,
      label: 'Excelente',
      emoji: '🤩',
      color: AppColors.moodExcellent,
      description: 'Plenitud, euforia y máxima motivación',
    ),
  ];

  static MoodItem fromValue(int val) {
    return moods.firstWhere(
      (m) => m.value == val,
      orElse: () => moods[4], // Neutral
    );
  }

  // Actividades predefinidas según especificación de etapa 1
  static const List<Map<String, String>> defaultActivities = [
    {'name': 'Trabajo', 'icon': '💼', 'category': 'Productividad'},
    {'name': 'Estudio', 'icon': '📚', 'category': 'Productividad'},
    {'name': 'Ejercicio', 'icon': '🏃', 'category': 'Bienestar'},
    {'name': 'Familia', 'icon': '👨‍👩‍👧', 'category': 'Social'},
    {'name': 'Amigos', 'icon': '👥', 'category': 'Social'},
    {'name': 'Entretenimiento', 'icon': '🎮', 'category': 'Ocio'},
    {'name': 'Descanso', 'icon': '🛌', 'category': 'Bienestar'},
    {'name': 'Viaje', 'icon': '✈️', 'category': 'Aventura'},
    {'name': 'Compras', 'icon': '🛍️', 'category': 'Ocio'},
    {'name': 'Tareas domésticas', 'icon': '🧹', 'category': 'Hogar'},
  ];
}

