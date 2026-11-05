import 'dart:convert';

class MoodEntry {
  final String id;
  final DateTime date;
  final int moodValue;      // 1 to 8
  final int energyLevel;    // 1 to 10
  final String note;        // Reflexión / diario
  final List<String> activities;
  final double sleepHours;  // Horas de sueño (Etapa 2)
  final int stepsCount;     // Pasos del día (Etapa 2)
  final String? sentimentLabel; // 'positivo', 'neutro', 'negativo'
  final double? sentimentScore; // -1.0 a +1.0

  MoodEntry({
    required this.id,
    required this.date,
    required this.moodValue,
    required this.energyLevel,
    required this.note,
    required this.activities,
    this.sleepHours = 7.0,
    this.stepsCount = 6000,
    this.sentimentLabel,
    this.sentimentScore,
  });

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    int? moodValue,
    int? energyLevel,
    String? note,
    List<String>? activities,
    double? sleepHours,
    int? stepsCount,
    String? sentimentLabel,
    double? sentimentScore,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodValue: moodValue ?? this.moodValue,
      energyLevel: energyLevel ?? this.energyLevel,
      note: note ?? this.note,
      activities: activities ?? this.activities,
      sleepHours: sleepHours ?? this.sleepHours,
      stepsCount: stepsCount ?? this.stepsCount,
      sentimentLabel: sentimentLabel ?? this.sentimentLabel,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodValue': moodValue,
      'energyLevel': energyLevel,
      'note': note,
      'activities': jsonEncode(activities),
      'sleepHours': sleepHours,
      'stepsCount': stepsCount,
      'sentimentLabel': sentimentLabel,
      'sentimentScore': sentimentScore,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    List<String> acts = [];
    if (map['activities'] != null) {
      if (map['activities'] is String) {
        try {
          acts = List<String>.from(jsonDecode(map['activities'] as String));
        } catch (_) {
          acts = [];
        }
      } else if (map['activities'] is List) {
        acts = List<String>.from(map['activities']);
      }
    }

    return MoodEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      moodValue: (map['moodValue'] as num).toInt(),
      energyLevel: (map['energyLevel'] as num).toInt(),
      note: map['note'] as String? ?? '',
      activities: acts,
      sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 7.0,
      stepsCount: (map['stepsCount'] as num?)?.toInt() ?? 6000,
      sentimentLabel: map['sentimentLabel'] as String?,
      sentimentScore: (map['sentimentScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry.fromMap(json);
}

