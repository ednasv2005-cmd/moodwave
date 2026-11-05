import 'package:flutter_test/flutter_test.dart';
import 'package:moodwave/domain/analytics/emotional_stats.dart';
import 'package:moodwave/domain/analytics/correlation_engine.dart';
import 'package:moodwave/domain/analytics/synthetic_data_generator.dart';
import 'package:moodwave/domain/ai/sentiment_analyzer.dart';
import 'package:moodwave/domain/ai/mood_predictor.dart';
import 'package:moodwave/core/security/crypto_service.dart';
import 'package:moodwave/core/ethics/ethics_protocol.dart';

void main() {
  group('Pruebas Estadísticas y Analíticas (Etapa 2)', () {
    test('Cálculo manual exacto de media, mediana, moda y desviación estándar', () {
      // Valores de prueba manuales: [4, 6, 6, 7, 8, 8, 8, 9] (aquí con escala 1-8: [2, 4, 6, 6, 7, 7, 7, 8])
      final sample = [2, 4, 6, 6, 7, 7, 7, 8];
      
      // Media esperada: (2+4+6+6+7+7+7+8) / 8 = 47 / 8 = 5.875
      final mean = EmotionalStatsCalculator.calculateMean(sample);
      expect(mean, equals(5.875));

      // Mediana esperada: longitud 8 (par) -> elementos en pos 3 y 4 (6 y 7) -> (6+7)/2 = 6.5
      final median = EmotionalStatsCalculator.calculateMedian(sample);
      expect(median, equals(6.5));

      // Moda esperada: el 7 aparece 3 veces
      final mode = EmotionalStatsCalculator.calculateMode(sample);
      expect(mode, equals([7]));

      // Desviación estándar poblacional:
      // sum((x - 5.875)^2) = (-3.875)^2 + (-1.875)^2 + 2*(0.125)^2 + 3*(1.125)^2 + (2.125)^2
      // = 15.015625 + 3.515625 + 2*0.015625 + 3*1.265625 + 4.515625 = 26.875
      // 26.875 / 8 = 3.359375 -> sqrt(3.359375) ≈ 1.8328
      final stdDev = EmotionalStatsCalculator.calculateStdDev(sample, mean);
      expect(double.parse(stdDev.toStringAsFixed(2)), equals(1.83));
    });

    test('Generador sintético produce 90 días con correlación plantada de ejercicio', () {
      final entries = SyntheticDataGenerator.generate90Days();
      expect(entries.length, equals(90));

      // Comprobar análisis de correlación
      final correlations = CorrelationEngine.analyze(entries);
      expect(correlations.isNotEmpty, isTrue);

      final exerciseCorr = correlations.firstWhere((c) => c.activityName == 'Ejercicio');
      // Debe haber al menos 5 registros
      expect(exerciseCorr.countWith >= 5, isTrue);
      // El ejercicio fue plantado con correlación positiva
      expect(exerciseCorr.diffFromGlobal > 0, isTrue);
      expect(exerciseCorr.hasSufficientData, isTrue);
    });

    test('Análisis de sentimiento local y detección de discrepancias', () {
      // Discrepancia: Seleccionó Excelente (8) pero texto dice "agotado y triste"
      final resultDiscrepancy = SentimentAnalyzer.analyze('Hoy estuve super cansado, agotado y con mucho estres', 8);
      expect(resultDiscrepancy.hasDiscrepancy, isTrue);
      expect(resultDiscrepancy.label, equals('negativo'));

      // Coincidencia: Feliz (7) con palabras positivas
      final resultHappy = SentimentAnalyzer.analyze('Todo salio padrisimo y disfrute mucho con mis amigos', 7);
      expect(resultHappy.hasDiscrepancy, isFalse);
      expect(resultHappy.label, equals('positivo'));
    });

    test('Validación de pronóstico temporal y reporte de métricas MAE', () {
      final entries = SyntheticDataGenerator.generate90Days();
      final prediction = MoodPredictor.predictTomorrow(entries);

      expect(prediction, isNotNull);
      expect(prediction!.predictedMood >= 1.0 && prediction.predictedMood <= 8.0, isTrue);
      expect(prediction.evaluation.testSampleSize > 0, isTrue);
      expect(prediction.evaluation.modelMae >= 0, isTrue);
    });

    test('Cifrado y descifrado de respaldo con derivación PBKDF2 y firma HMAC', () {
      const plainText = '{"test":"MoodWave Backup", "entries": [1, 2, 3]}';
      const password = 'SuperClaveSegura2026!';

      final encryptedPkg = CryptoService.encryptData(plainText, password);
      expect(encryptedPkg.containsKey('salt'), isTrue);
      expect(encryptedPkg.containsKey('ciphertext'), isTrue);
      expect(encryptedPkg.containsKey('mac'), isTrue);

      // Descifrado correcto
      final decrypted = CryptoService.decryptData(encryptedPkg, password);
      expect(decrypted, equals(plainText));

      // Intento de descifrado con contraseña errónea debe lanzar excepción
      expect(
        () => CryptoService.decryptData(encryptedPkg, 'PasswordIncorrecto'),
        throwsA(isA<Exception>()),
      );
    });

    test('Protocolo ético detecta señales de riesgo', () {
      expect(EthicsProtocol.detectRiskSignals('Hoy salí a correr y comí rico'), isFalse);
      expect(EthicsProtocol.detectRiskSignals('Siento que no quiero vivir y ya no aguanto'), isTrue);
      expect(EthicsProtocol.detectRiskSignals('Tengo pensamientos de autolesion'), isTrue);
    });
  });
}

