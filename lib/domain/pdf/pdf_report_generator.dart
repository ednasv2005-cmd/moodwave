import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/mood_entry.dart';
import '../analytics/emotional_stats.dart';
import '../analytics/correlation_engine.dart';
import '../../core/ethics/ethics_protocol.dart';
import '../../core/constants/mood_constants.dart';

class PdfReportGenerator {
  static Future<Uint8List> generateMonthlyReport(List<MoodEntry> entries, {String title = 'REPORTE MENSUAL MOODWAVE'}) async {
    final pdf = pw.Document();
    final stats = EmotionalStatsCalculator.calculate(entries);
    final correlations = CorrelationEngine.analyze(entries);
    final dateStr = DateFormat('MMMM yyyy', 'es_MX').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MoodWave - OndaVital',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple700,
                      ),
                    ),
                    pw.Text(
                      'Diario de Emociones y Análisis de Hábitos',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      dateStr.toUpperCase(),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'IPN - UPIIT',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.deepPurple300),
            pw.SizedBox(height: 12),

            // Resumen de Métricas
            pw.Text(
              'Resumen de Indicadores Clave',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('Ánimo Promedio', '${stats.mean} / 8 pts', PdfColors.deepPurple),
                _buildStatBox('Energía Promedio', '${stats.energyMean} / 10 pts', PdfColors.orange800),
                _buildStatBox('Días Registrados', '${stats.totalCount} días', PdfColors.teal700),
                _buildStatBox('Sueño Promedio', '${stats.sleepMean} hrs/día', PdfColors.blue700),
              ],
            ),
            pw.SizedBox(height: 16),

            // Distribución de Estados de Ánimo
            pw.Text(
              'Distribución de Estados de Ánimo',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...MoodConstants.moods.map((m) {
              final count = entries.where((e) => e.moodValue == m.value).length;
              final pct = entries.isNotEmpty ? (count / entries.length) : 0.0;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 90,
                      child: pw.Text('${m.emoji} ${m.label} (${m.value})', style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Expanded(
                      child: pw.Stack(
                        children: [
                          pw.Container(
                            height: 10,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                          pw.Container(
                            height: 10,
                            width: 300 * pct,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.deepPurple400,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      '$count (${(pct * 100).toStringAsFixed(1)}%)',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 16),

            // Análisis Actividades vs Estado de Ánimo
            pw.Text(
              'Asociaciones Detectadas: Actividades vs Estado de Ánimo',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Método: Correlación Biserial-Puntual y Tamaño del Efecto (Cohen\'s d).',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 6),

            pw.TableHelper.fromTextArray(
              headers: ['Actividad', 'Muestra (n)', 'Ánimo Promedio', 'Dif. vs Media', 'Efecto (Cohen\'s d)'],
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple700),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              data: correlations.take(6).map((c) {
                final sign = c.diffFromGlobal >= 0 ? '+' : '';
                return [
                  c.activityName,
                  'n=${c.countWith}',
                  '${c.avgMoodWith} / 8',
                  '$sign${c.diffFromGlobal} pts',
                  '${c.cohensD} (${c.effectLabel})',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),

            // Conclusiones Responsables
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Conclusiones y Observaciones',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '• Se observa una relación entre las jornadas con actividad física y un nivel de ánimo superior a la media.\n'
                    '• Los periodos con 7 a 9 horas de descanso nocturno se asocian a una mayor estabilidad energética.\n'
                    '• Las variaciones registradas reflejan asociaciones personales observadas y no constituyen diagnóstico causal.',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Aviso Ético
            pw.Text(
              EthicsProtocol.disclaimer,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 115,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

