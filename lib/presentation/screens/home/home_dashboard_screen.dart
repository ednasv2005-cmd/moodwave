import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/presentation/providers/theme_provider.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/core/constants/mood_constants.dart';
import 'package:moodwave/core/ethics/ethics_protocol.dart';
import 'package:moodwave/presentation/widgets/mood_badge.dart';
import 'package:moodwave/presentation/widgets/breathing_widget.dart';
import 'package:moodwave/presentation/widgets/risk_protocol_dialog.dart';
import 'package:moodwave/presentation/screens/entry/new_entry_screen.dart';
import 'package:moodwave/data/models/mood_entry.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final entries = moodProvider.entries;
    final stats = moodProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.waveGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.waves_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('MoodWave', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Cambiar tema',
          ),
          IconButton(
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.primaryNeon),
            onPressed: () => RiskProtocolDialog.show(context),
            tooltip: 'Líneas de ayuda y ética',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewEntryScreen()),
          );
        },
        backgroundColor: AppColors.primaryNeon,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar día', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: moodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => moodProvider.loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner de Aviso Ético Transversal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryNeon),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              EthicsProtocol.disclaimer,
                              style: const TextStyle(fontSize: 11, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alerta suave de anomalía si se detectó malestar sostenido
                    if (moodProvider.anomalyAlert.hasAnomaly) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.moodWorried.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.moodWorried.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.spa_rounded, color: AppColors.moodWorried, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  moodProvider.anomalyAlert.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.moodWorried,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moodProvider.anomalyAlert.message,
                              style: const TextStyle(fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tarjeta Principal de Racha y Estado Actual
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryNeon.withValues(alpha: 0.2),
                            AppColors.secondaryNeon.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, d MMMM', 'es_MX').format(DateTime.now()).toUpperCase(),
                                    style: const TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '¿Cómo te sientes hoy?',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.energyAmber.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.energyAmber.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats.currentStreak} días',
                                      style: const TextStyle(
                                        color: AppColors.energyAmber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Línea de Tiempo de los Últimos 7 Días (PDF 1 Requisito 4)
                          const Text(
                            'Línea de tiempo reciente',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          _buildRecentTimelineStrip(context, entries),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Widget Ingenioso: Respiración Consciente (Desplegable)
                    const BreathingWidget(),
                    const SizedBox(height: 20),

                    // Título de Historial y Lista de Registros
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tus reflexiones diarias',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${entries.length} registros',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (entries.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          children: [
                            const Text('📝', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            const Text(
                              'Aún no tienes registros',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Toca el botón "+ Registrar día" o genera datos de prueba en Configuración.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => moodProvider.loadSyntheticDemoData(),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Cargar 90 días de prueba'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entries.length > 15 ? 15 : entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _buildEntryCard(context, entry);
                        },
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  // Tira de la línea de tiempo (7 días recientes)
  Widget _buildRecentTimelineStrip(BuildContext context, List<MoodEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: last7Days.map((date) {
        final dayEntry = entries.where((e) {
          final ed = DateTime(e.date.year, e.date.month, e.date.day);
          return ed.isAtSameMomentAs(date);
        }).toList();

        final hasEntry = dayEntry.isNotEmpty;
        final moodVal = hasEntry ? dayEntry.first.moodValue : 0;
        final color = hasEntry ? AppColors.getMoodColor(moodVal) : Colors.grey.withValues(alpha: 0.2);
        final dayLetter = DateFormat('E', 'es_MX').format(date).substring(0, 1).toUpperCase();

        return InkWell(
          onTap: () {
            if (hasEntry) {
              _showDayDetailModal(context, dayEntry.first);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewEntryScreen(initialDate: date)),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Text(
                dayLetter,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.25),
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: hasEntry
                      ? Text(
                          MoodConstants.fromValue(moodVal).emoji,
                          style: const TextStyle(fontSize: 14),
                        )
                      : const Icon(Icons.add, size: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryCard(BuildContext context, MoodEntry entry) {
    final dateStr = DateFormat('EEEE, d MMMM • HH:mm', 'es_MX').format(entry.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDayDetailModal(context, entry),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MoodBadge(moodValue: entry.moodValue),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.energyAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: AppColors.energyAmber),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.energyLevel}/10',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.energyAmber,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
              if (entry.activities.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: entry.activities.map((act) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        act,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetailModal(BuildContext context, MoodEntry entry) {
    final mood = MoodConstants.fromValue(entry.moodValue);
    final dateStr = DateFormat('d MMMM yyyy, HH:mm', 'es_MX').format(entry.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 8),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: mood.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primaryNeon),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewEntryScreen(entryToEdit: entry)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDetailChip('⚡ Energía', '${entry.energyLevel}/10', AppColors.energyAmber),
                  const SizedBox(width: 8),
                  _buildDetailChip('🌙 Sueño', '${entry.sleepHours} hrs', AppColors.secondaryNeon),
                  const SizedBox(width: 8),
                  _buildDetailChip('👟 Pasos', '${entry.stepsCount}', AppColors.primaryNeon),
                ],
              ),
              const SizedBox(height: 16),
              if (entry.activities.isNotEmpty) ...[
                const Text('Actividades realizadas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.activities.map((act) {
                    return Chip(
                      label: Text(act, style: const TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],
              if (entry.note.isNotEmpty) ...[
                const Text('Diario y Reflexión:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Text(entry.note, style: const TextStyle(fontSize: 13, height: 1.4)),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
