class MentalHealthResource {
  final String title;
  final String phone;
  final String description;
  final String available;

  const MentalHealthResource({
    required this.title,
    required this.phone,
    required this.description,
    required this.available,
  });
}

class EthicsProtocol {
  static const String disclaimer =
      'MoodWave es una herramienta de autoobservación y análisis de hábitos personales. '
      'No realiza diagnósticos médicos, psicológicos ni psiquiátricos, y nunca sustituye '
      'la atención, orientación o tratamiento de profesionales de la salud mental.';

  static const List<MentalHealthResource> resources = [
    MentalHealthResource(
      title: 'Línea de la Vida (México)',
      phone: '800 911 2000',
      description: 'Atención especializada en crisis emocionales, salud mental y prevención del suicidio.',
      available: '24 horas / 365 días (Gratuita)',
    ),
    MentalHealthResource(
      title: 'SAPTEL - Apoyo Psicológico Telefónico',
      phone: '55 5259 8121',
      description: 'Servicio de apoyo psicológico en crisis y contención emocional.',
      available: '24 horas',
    ),
    MentalHealthResource(
      title: 'Número General de Emergencias',
      phone: '911',
      description: 'Atención inmediata ante situaciones de riesgo o emergencia de salud.',
      available: '24 horas',
    ),
  ];

  // Palabras y expresiones asociadas a señales de riesgo o malestar severo
  static const List<String> _riskKeywords = [
    'suicid',
    'matarme',
    'quitarme la vida',
    'no quiero vivir',
    'desaparecer para siempre',
    'acabar con todo',
    'autolesion',
    'hacerme dano',
    'hacerme daño',
    'cortarme',
    'morirme',
    'no sirvo para nada',
    'ya no aguanto',
    'no vale la pena seguir',
  ];

  /// Detecta si el texto del diario contiene indicios explícitos de riesgo emocional.
  static bool detectRiskSignals(String text) {
    if (text.trim().isEmpty) return false;
    final normalized = text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');

    for (final keyword in _riskKeywords) {
      if (normalized.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}

