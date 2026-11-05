import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/domain/ai/natural_insights.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final prediction = moodProvider.prediction;
    final clusters = moodProvider.clusters;
    final insights = moodProvider.insights;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primaryNeon, size: 20),
            SizedBox(width: 8),
            Text('Inteligencia Local MoodWave'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Privacidad Local de la IA (PDF 2 Reglas)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primaryNeon),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privacidad Primero: Todo el procesamiento de IA (Sentimiento, Forecasting y Clustering) corre 100% local en tu dispositivo, sin enviar tus reflexiones a servidores externos.',
                      style: TextStyle(fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // SECCIÓN 1: Predicción de Estado de Ánimo para Mañana (PDF 2 Nivel 3.B)
            const Text(
              '1. Predicción Temporal para Mañana',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (prediction == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Text(
                  'Se requieren al menos 7 registros cronológicos para entrenar la validación walk-forward '
                  'y calcular el MAE frente al baseline.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            else
              _buildPredictionCard(context, prediction),

            const SizedBox(height: 24),

            // SECCIÓN 2: Arquetipos Conductuales / Clustering de Días (PDF 2 Nivel 3.C)
            const Text(
              '2. Patrones de Conducta (Clustering de Días)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Clasificación automática de tus jornadas según correlaciones de esfuerzo, descanso y emoción.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            if (clusters.isEmpty)
              const Text('Sin datos suficientes para clustering.', style: TextStyle(color: Colors.grey))
            else
              ...clusters.map((cl) => _buildClusterCard(context, cl)),

            const SizedBox(height: 24),

            // SECCIÓN 3: Insights en Lenguaje Natural Responsable con Explicabilidad (PDF 2 Nivel 3.D)
            const Text(
              '3. Insights en Lenguaje Natural (Explicables)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Asociaciones observadas con redacción responsable ("se observa una relación", sin diagnósticos).',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ...insights.map((ins) => _buildInsightCard(context, ins)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, dynamic prediction) {
    final eval = prediction.evaluation;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNeon.withValues(alpha: 0.25),
            AppColors.secondaryNeon.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(prediction.predictedEmoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pronóstico: ${prediction.predictedLabel}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      Text(
                        'Puntaje estimado: ${prediction.predictedMood} / 8 pts',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${prediction.confidencePercent}% conf.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryNeon),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Factores contribuyentes:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          ...prediction.contributingFactors.map<Widget>((f) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right_rounded, size: 16, color: AppColors.primaryNeon),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
          const Divider(height: 24),

          // Validación Científica contra Baseline (PDF 2 Requisito Obligatorio)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.analytics_rounded, size: 16, color: AppColors.secondaryNeon),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evaluación Temporal Walk-Forward (Sin fuga de datos)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondaryNeon),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MAE Modelo: ${eval.modelMae} | Baseline Persistencia: ${eval.baselineYesterdayMae} | Baseline Media: ${eval.baselineMeanMae}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eval.metricSummary,
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClusterCard(BuildContext context, dynamic cluster) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(cluster.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(cluster.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${cluster.count} días', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(cluster.description, style: const TextStyle(fontSize: 12, height: 1.3)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Ánimo promedio: ${cluster.avgMood}/8', style: const TextStyle(fontSize: 11, color: AppColors.primaryNeon, fontWeight: FontWeight.bold)),
                const SizedBox(width: 14),
                Text('Energía: ${cluster.avgEnergy}/10', style: const TextStyle(fontSize: 11, color: AppColors.energyAmber, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightItem ins) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(ins.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ins.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(ins.category, style: const TextStyle(fontSize: 10, color: AppColors.primaryNeon, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ins.text,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 12, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Explicabilidad: ${ins.sampleExplanation}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
