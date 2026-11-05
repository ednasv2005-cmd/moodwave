import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/core/constants/mood_constants.dart';
import 'package:moodwave/domain/analytics/trend_analyzer.dart';
import 'package:moodwave/presentation/widgets/stat_card.dart';
import 'package:moodwave/presentation/screens/analytics/statistical_honesty_dialog.dart';

class AnalyticsHubScreen extends StatelessWidget {
  const AnalyticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final stats = moodProvider.stats;
    final trendResult = moodProvider.trendResult;
    final correlations = moodProvider.correlations;
    final filterDays = moodProvider.selectedFilterDays;
    final entries = moodProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis y Patrones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.primaryNeon),
            onPressed: () => StatisticalHonestyDialog.show(context),
            tooltip: 'Honestidad estadística',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de Ventana de Tiempo (7, 30, 90 días)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [7, 30, 90].map((days) {
                final isSel = filterDays == days;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$days días', style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    selected: isSel,
                    selectedColor: AppColors.primaryNeon.withValues(alpha: 0.3),
                    onSelected: (_) => moodProvider.setFilterDays(days),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tarjetas de Métricas Estadísticas (Nivel 1 Núcleo: Media, Mediana, Moda, Desv, Racha)
            const Text(
              'Estadísticas Emocionales del Periodo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Promedio (Media)',
                  value: '${stats.mean}',
                  subtitle: 'Escala 1 a 8 pts',
                  icon: Icons.functions_rounded,
                  accentColor: AppColors.primaryNeon,
                ),
                StatCard(
                  title: 'Mediana',
                  value: '${stats.median}',
                  subtitle: 'Punto medio de la serie',
                  icon: Icons.align_horizontal_center_rounded,
                  accentColor: AppColors.secondaryNeon,
                ),
                StatCard(
                  title: 'Moda',
                  value: stats.mode.isNotEmpty ? '${stats.mode.first} (${MoodConstants.fromValue(stats.mode.first).emoji})' : 'N/A',
                  subtitle: 'Estado más frecuente',
                  icon: Icons.repeat_rounded,
                  accentColor: AppColors.energyAmber,
                ),
                StatCard(
                  title: 'Desv. Estándar (σ)',
                  value: '±${stats.standardDeviation}',
                  subtitle: 'Variabilidad del ánimo',
                  icon: Icons.stacked_line_chart_rounded,
                  accentColor: AppColors.accentNeon,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // GRÁFICA 1: Tendencias Temporales con Media Móvil (Nivel 1 Requisito 2 y 5)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '1. Tendencia y Media Móvil',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.show_chart_rounded, size: 14, color: AppColors.secondaryNeon),
                            SizedBox(width: 4),
                            Text('Media móvil (3d)', style: TextStyle(fontSize: 10, color: AppColors.secondaryNeon, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (trendResult != null)
                    Text(
                      trendResult.trendDescription,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildTrendChart(trendResult),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GRÁFICA 2: Actividad vs Estado de Ánimo (Nivel 1 Requisito 3, 4 y 5)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2. Impacto por Actividad (Muestra n y Ánimo Promedio)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Diferencia contra tu media general. Se requiere n ≥ 5 para validar el patrón.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (correlations.isEmpty)
                    const Center(child: Text('Sin actividades registradas', style: TextStyle(color: Colors.grey)))
                  else
                    ...correlations.take(6).map((c) => _buildActivityBarItem(c)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GRÁFICA 3: Cruzamiento Sueño y Pasos vs Ánimo (PDF 1 Requisitos 12 y 13)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3. Hábitos Biológicos: Sueño y Movimiento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Relación entre descanso nocturno, pasos y estado de ánimo promedio observado.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildSleepVsMoodSection(entries),
                  const Divider(height: 28),
                  _buildStepsVsMoodSection(entries),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(TrendAnalysisResult? trend) {
    if (trend == null || trend.points.length < 2) {
      return const Center(
        child: Text(
          'Registra al menos 2 días para visualizar la curva de tendencia.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    final points = trend.points;
    final spotsValue = points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
    final spotsMA = points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.movingAverage)).toList();

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 8.5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (val) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 28,
              getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: max(1, (points.length / 5).floor().toDouble()),
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(points[idx].label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Línea 1: Registro diario (Puntos y línea suave)
          LineChartBarData(
            spots: spotsValue,
            isCurved: true,
            color: AppColors.primaryNeon.withValues(alpha: 0.4),
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, p, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.primaryNeon,
                strokeColor: Colors.white,
                strokeWidth: 1,
              ),
            ),
          ),
          // Línea 2: Media móvil (Resaltada y suave)
          LineChartBarData(
            spots: spotsMA,
            isCurved: true,
            color: AppColors.secondaryNeon,
            barWidth: 3.5,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondaryNeon.withValues(alpha: 0.08),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBarItem(dynamic corr) {
    final hasData = corr.hasSufficientData;
    final diff = corr.diffFromGlobal;
    final isPositive = diff >= 0;
    final sign = isPositive ? '+' : '';
    final color = isPositive ? AppColors.moodGood : AppColors.moodWorried;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${corr.activityName} (n=${corr.countWith})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (hasData)
                Text(
                  '${corr.avgMoodWith}/8 pts ($sign${diff.toStringAsFixed(1)})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
                )
              else
                Text(
                  'Aún sin datos suficientes (${corr.countWith}/5)',
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (corr.avgMoodWith / 8.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(hasData ? color : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepVsMoodSection(List<dynamic> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final sleepBuckets = {
      '< 6h': entries.where((e) => e.sleepHours < 6.0).toList(),
      '6 - 7h': entries.where((e) => e.sleepHours >= 6.0 && e.sleepHours < 7.0).toList(),
      '7 - 9h': entries.where((e) => e.sleepHours >= 7.0 && e.sleepHours <= 9.0).toList(),
      '> 9h': entries.where((e) => e.sleepHours > 9.0).toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🌙 Sueño vs Estado de Ánimo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: sleepBuckets.entries.map((entry) {
            final list = entry.value;
            final count = list.length;
            final avg = count > 0 ? (list.map((e) => e.moodValue).reduce((a, b) => a + b) / count) : 0.0;
            return Column(
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  count > 0 ? '${avg.toStringAsFixed(1)}' : '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: count > 0 ? AppColors.secondaryNeon : Colors.grey,
                  ),
                ),
                Text('n=$count', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepsVsMoodSection(List<dynamic> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final stepsBuckets = {
      '< 2k': entries.where((e) => e.stepsCount < 2000).toList(),
      '2k - 5k': entries.where((e) => e.stepsCount >= 2000 && e.stepsCount < 5000).toList(),
      '5k - 8k': entries.where((e) => e.stepsCount >= 5000 && e.stepsCount <= 8000).toList(),
      '> 8k': entries.where((e) => e.stepsCount > 8000).toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👟 Pasos vs Estado de Ánimo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stepsBuckets.entries.map((entry) {
            final list = entry.value;
            final count = list.length;
            final avg = count > 0 ? (list.map((e) => e.moodValue).reduce((a, b) => a + b) / count) : 0.0;
            return Column(
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  count > 0 ? '${avg.toStringAsFixed(1)}' : '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: count > 0 ? AppColors.primaryNeon : Colors.grey,
                  ),
                ),
                Text('n=$count', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
