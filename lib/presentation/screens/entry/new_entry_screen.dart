import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/data/models/mood_entry.dart';
import 'package:moodwave/core/constants/mood_constants.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/core/ethics/ethics_protocol.dart';
import 'package:moodwave/domain/ai/sentiment_analyzer.dart';
import 'package:moodwave/presentation/widgets/energy_slider.dart';
import 'package:moodwave/presentation/widgets/risk_protocol_dialog.dart';

class NewEntryScreen extends StatefulWidget {
  final MoodEntry? entryToEdit;
  final DateTime? initialDate;

  const NewEntryScreen({
    super.key,
    this.entryToEdit,
    this.initialDate,
  });

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late DateTime _selectedDate;
  int _selectedMood = 7; // Feliz por defecto
  int _energyLevel = 7;
  late TextEditingController _noteController;
  final Set<String> _selectedActivities = {};

  double _sleepHours = 7.5;
  int _stepsCount = 6500;

  SentimentAnalysisResult? _currentSentiment;

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      final e = widget.entryToEdit!;
      _selectedDate = e.date;
      _selectedMood = e.moodValue;
      _energyLevel = e.energyLevel;
      _noteController = TextEditingController(text: e.note);
      _selectedActivities.addAll(e.activities);
      _sleepHours = e.sleepHours;
      _stepsCount = e.stepsCount;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _noteController = TextEditingController();
    }

    _noteController.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    final text = _noteController.text;
    if (text.isNotEmpty) {
      final sentiment = SentimentAnalyzer.analyze(text, _selectedMood);
      setState(() {
        _currentSentiment = sentiment;
      });

      // Chequeo de protocolo de riesgo ético
      if (EthicsProtocol.detectRiskSignals(text)) {
        RiskProtocolDialog.show(context);
      }
    } else {
      setState(() {
        _currentSentiment = null;
      });
    }
  }

  @override
  void dispose() {
    _noteController.removeListener(_onNoteChanged);
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    await moodProvider.saveEntry(
      id: widget.entryToEdit?.id,
      date: _selectedDate,
      moodValue: _selectedMood,
      energyLevel: _energyLevel,
      note: _noteController.text.trim(),
      activities: _selectedActivities.toList(),
      sleepHours: _sleepHours,
      stepsCount: _stepsCount,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entryToEdit != null ? 'Registro actualizado con éxito 🌟' : '¡Registro guardado con éxito! 🌊',
          ),
          backgroundColor: AppColors.primaryNeon,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _delete() async {
    if (widget.entryToEdit == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text('Esta acción eliminará permanentemente la entrada seleccionada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.moodAngry),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      await moodProvider.deleteEntry(widget.entryToEdit!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showAddCustomActivityDialog() {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '⭐';
    final emojis = ['⭐', '🎨', '🍳', '🚴', '🧘', '🧗', '🎵', '🌿', '☕', '💻'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la actividad',
                  hintText: 'Ej. Pintura, Cocina...',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Elige un emoji:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: emojis.map((e) {
                  final isSel = e == selectedEmoji;
                  return InkWell(
                    onTap: () => setDialogState(() => selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryNeon.withValues(alpha: 0.3) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSel ? AppColors.primaryNeon : Colors.transparent),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final provider = Provider.of<MoodProvider>(context, listen: false);
                  provider.addCustomActivity(nameCtrl.text.trim(), selectedEmoji);
                  setState(() {
                    _selectedActivities.add(nameCtrl.text.trim());
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final maxChars = moodProvider.maxJournalChars;
    final activities = moodProvider.activities;
    final currentMoodItem = MoodConstants.fromValue(_selectedMood);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryToEdit != null ? 'Editar Registro' : 'Nuevo Registro'),
        actions: [
          if (widget.entryToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.moodAngry),
              onPressed: _delete,
              tooltip: 'Eliminar registro',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de Fecha y Hora
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      _selectedDate.hour,
                      _selectedDate.minute,
                    );
                  });
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryNeon),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'es_MX').format(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección 1: Selección de los 8 Estados Emocionales (PDF 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentMoodItem.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: currentMoodItem.color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${currentMoodItem.emoji} ${currentMoodItem.label}',
                    style: TextStyle(
                      color: currentMoodItem.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Grid de 8 Estados
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: MoodConstants.moods.length,
              itemBuilder: (context, index) {
                final mood = MoodConstants.moods[index];
                final isSelected = mood.value == _selectedMood;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood.value;
                    });
                    _onNoteChanged();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? mood.color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? mood.color : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? mood.color : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Sección 2: Nivel de Energía (1 al 10)
            EnergySlider(
              currentEnergy: _energyLevel,
              onChanged: (val) => setState(() => _energyLevel = val),
            ),
            const SizedBox(height: 24),

            // Sección 3: Actividades del Día (PDF 1 Requisito 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '¿Qué hiciste hoy?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                TextButton.icon(
                  onPressed: _showAddCustomActivityDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities.map((act) {
                final isSelected = _selectedActivities.contains(act.name);
                return FilterChip(
                  label: Text('${act.icon} ${act.name}'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryNeon.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primaryNeon,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedActivities.add(act.name);
                      } else {
                        _selectedActivities.remove(act.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Sección 4: Salud (Sueño y Pasos - Etapa 2)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bedtime_rounded, size: 16, color: AppColors.secondaryNeon),
                            SizedBox(width: 4),
                            Text('Sueño (hrs)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (_sleepHours > 2.0) {
                                  setState(() => _sleepHours = double.parse((_sleepHours - 0.5).toStringAsFixed(1)));
                                }
                              },
                            ),
                            Text(
                              '$_sleepHours h',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                if (_sleepHours < 14.0) {
                                  setState(() => _sleepHours = double.parse((_sleepHours + 0.5).toStringAsFixed(1)));
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.primaryNeon),
                            SizedBox(width: 4),
                            Text('Pasos diarios', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (_stepsCount >= 1000) {
                                  setState(() => _stepsCount -= 500);
                                }
                              },
                            ),
                            Text(
                              '$_stepsCount',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                if (_stepsCount <= 30000) {
                                  setState(() => _stepsCount += 500);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sección 5: Diario Rápido / Reflexión (PDF 1 Requisito 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Diario rápido / Reflexión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Text(
                  '${_noteController.text.length} / $maxChars',
                  style: TextStyle(
                    fontSize: 12,
                    color: _noteController.text.length > maxChars ? AppColors.moodAngry : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: maxChars,
              buildCounter: (ctx, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
              decoration: const InputDecoration(
                hintText: '¿Qué pasó hoy? ¿Qué agradeces o qué te gustaría soltar?',
              ),
            ),

            // Feedback en vivo del Análisis de Sentimiento Local & Discrepancias (Etapa 2 IA)
            if (_currentSentiment != null) ...[
              const SizedBox(height: 12),
              if (_currentSentiment!.hasDiscrepancy) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.moodWorried.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.moodWorried.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentSentiment!.discrepancyExplanation ?? '',
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_noteController.text.length > 15) ...[
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryNeon),
                    const SizedBox(width: 6),
                    Text(
                      'Tono del texto: ${_currentSentiment!.label.toUpperCase()} (polaridad ${_currentSentiment!.score})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 32),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.entryToEdit != null ? 'Actualizar registro' : 'Guardar en mi diario',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
