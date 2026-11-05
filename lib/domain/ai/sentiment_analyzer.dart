import '../../core/constants/mood_constants.dart';

class SentimentAnalysisResult {
  final String label; // 'positivo', 'neutro', 'negativo'
  final double score; // -1.0 a +1.0
  final bool hasDiscrepancy;
  final String? discrepancyExplanation;
  final List<String> detectedKeywords;

  SentimentAnalysisResult({
    required this.label,
    required this.score,
    required this.hasDiscrepancy,
    this.discrepancyExplanation,
    required this.detectedKeywords,
  });
}

class SentimentAnalyzer {
  // Léxico positivo con expresiones y mexicanismos coloquiales
  static const Map<String, double> _positiveLexicon = {
    'feliz': 1.0,
    'alegre': 0.9,
    'excelente': 1.0,
    'genial': 0.9,
    'maravilloso': 0.9,
    'contento': 0.8,
    'tranquilo': 0.7,
    'paz': 0.8,
    'relajado': 0.8,
    'motivado': 0.9,
    'energia': 0.8,
    'vitalidad': 0.8,
    'agradecido': 0.9,
    'chido': 0.8,
    'padre': 0.8,
    'padrisimo': 1.0,
    'chingon': 1.0,
    'fregon': 0.9,
    'rico': 0.7,
    'disfrute': 0.8,
    'logre': 0.8,
    'exito': 0.9,
    'alivio': 0.7,
    'esperanza': 0.8,
    'bien': 0.6,
    'mejor': 0.7,
    'amor': 0.9,
    'risa': 0.8,
    'descansado': 0.8,
  };

  // Léxico negativo con expresiones y mexicanismos coloquiales
  static const Map<String, double> _negativeLexicon = {
    'triste': -0.9,
    'enojado': -0.9,
    'deprimido': -1.0,
    'cansado': -0.6,
    'cansadisimo': -0.9,
    'agotado': -0.8,
    'exhausto': -0.9,
    'estres': -0.7,
    'estresado': -0.8,
    'ansioso': -0.8,
    'ansiedad': -0.8,
    'pesado': -0.6,
    'horrible': -0.9,
    'fatal': -1.0,
    'terrible': -0.9,
    'odio': -0.9,
    'bronca': -0.7,
    'coraje': -0.8,
    'harto': -0.8,
    'bajon': -0.8,
    'fregado': -0.8,
    'chafa': -0.7,
    'gacho': -0.8,
    'frustrado': -0.8,
    'frustracion': -0.8,
    'preocupado': -0.7,
    'malo': -0.7,
    'mal': -0.7,
    'dolor': -0.8,
    'vacio': -0.9,
    'desesperado': -0.9,
  };

  static const List<String> _negationWords = [
    'no',
    'nunca',
    'jamas',
    'tampoco',
    'sin',
    'nada',
  ];

  static const List<String> _intensifiers = [
    'muy',
    'mucho',
    'sumamente',
    'bastante',
    'totalmente',
    'demasiado',
    'super',
  ];

  /// Analiza el texto del diario y compara con el estado de ánimo seleccionado
  static SentimentAnalysisResult analyze(String text, int selectedMoodValue) {
    if (text.trim().isEmpty) {
      return SentimentAnalysisResult(
        label: 'neutro',
        score: 0.0,
        hasDiscrepancy: false,
        detectedKeywords: [],
      );
    }

    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    double totalScore = 0.0;
    int matchedWords = 0;
    final List<String> detectedWords = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      double wordVal = 0.0;

      if (_positiveLexicon.containsKey(word)) {
        wordVal = _positiveLexicon[word]!;
        detectedWords.add(word);
      } else if (_negativeLexicon.containsKey(word)) {
        wordVal = _negativeLexicon[word]!;
        detectedWords.add(word);
      }

      if (wordVal != 0.0) {
        // Verificar si la palabra anterior fue una negación ("no estuve feliz")
        bool isNegated = false;
        if (i > 0 && _negationWords.contains(words[i - 1])) {
          isNegated = true;
        } else if (i > 1 && _negationWords.contains(words[i - 2])) {
          isNegated = true;
        }

        // Verificar intensificadores ("muy agotado")
        double multiplier = 1.0;
        if (i > 0 && _intensifiers.contains(words[i - 1])) {
          multiplier = 1.4;
        }

        if (isNegated) {
          wordVal = -wordVal * 0.8;
        } else {
          wordVal *= multiplier;
        }

        totalScore += wordVal;
        matchedWords++;
      }
    }

    double normalizedScore = 0.0;
    if (matchedWords > 0) {
      normalizedScore = (totalScore / matchedWords).clamp(-1.0, 1.0);
    }

    String label = 'neutro';
    if (normalizedScore >= 0.25) {
      label = 'positivo';
    } else if (normalizedScore <= -0.25) {
      label = 'negativo';
    }
    // Detección de discrepancias emocionales
    bool hasDiscrepancy = false;
    String? discrepancyMsg;

    final moodItem = MoodConstants.fromValue(selectedMoodValue);

    // Caso A: Ánimo muy alto (Feliz / Excelente >= 7) pero texto predominantemente negativo
    if (selectedMoodValue >= 7 && normalizedScore <= -0.25 && matchedWords >= 1) {
      hasDiscrepancy = true;
      discrepancyMsg =
          'Seleccionaste "${moodItem.label} ${moodItem.emoji}", pero tus palabras reflejan cansancio o tensión emocional '
          '("${detectedWords.take(3).join(', ')}"). Reconocer el cansancio aun en días buenos es parte del autocuidado.';
    }
    // Caso B: Ánimo bajo (Enojado / Triste / Deprimido <= 3) pero texto notablemente positivo
    else if (selectedMoodValue <= 3 && normalizedScore >= 0.35 && matchedWords >= 1) {
      hasDiscrepancy = true;
      discrepancyMsg =
          'Marcaste "${moodItem.label} ${moodItem.emoji}", pero en tu reflexión expresaste gratitud o momentos positivos '
          '("${detectedWords.take(3).join(', ')}"). Experimentar emociones agridulces o contradictorias es natural.';
    }

    return SentimentAnalysisResult(
      label: label,
      score: double.parse(normalizedScore.toStringAsFixed(2)),
      hasDiscrepancy: hasDiscrepancy,
      discrepancyExplanation: discrepancyMsg,
      detectedKeywords: detectedWords,
    );
  }
}

