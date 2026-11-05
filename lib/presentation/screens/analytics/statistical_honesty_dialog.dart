import 'package:flutter/material.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/domain/analytics/correlation_engine.dart';

class StatisticalHonestyDialog extends StatelessWidget {
  const StatisticalHonestyDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const StatisticalHonestyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.query_stats_rounded, color: AppColors.primaryNeon),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Honestidad Estadística',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo se calculan las correlaciones?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 6),
            Text(
              CorrelationEngine.methodJustification,
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            SizedBox(height: 14),
            Text(
              'Criterios de Calidad Mínimos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              '• Mínimo 14 días totales registrados.\n'
              '• Mínimo 5 registros específicos de una actividad para analizar su impacto.\n'
              '• Tamaño del efecto (d de Cohen): diferencia relevante cuando |d| ≥ 0.5.\n'
              '• Control de falsos positivos en comparaciones múltiples.',
              style: TextStyle(fontSize: 12, height: 1.3),
            ),
            SizedBox(height: 14),
            Text(
              'Correlación vs Causalidad:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              'MoodWave indica que "se observa una relación o asociación", nunca que una actividad '
              'sea la causa única o definitiva de cómo te sientes.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}
