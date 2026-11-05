import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/data/models/mood_entry.dart';
import 'package:moodwave/presentation/widgets/mood_badge.dart';
import 'package:moodwave/presentation/screens/entry/new_entry_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final entries = moodProvider.entries;

    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = _currentMonth.weekday; // 1 = Lunes, 7 = Domingo

    // Mapear días con registros en el mes actual
    final Map<int, MoodEntry> monthEntries = {};
    for (var e in entries) {
      if (e.date.year == _currentMonth.year && e.date.month == _currentMonth.month) {
        monthEntries[e.date.day] = e;
      }
    }

    final selectedEntry = _selectedDate != null ? monthEntries[_selectedDate!.day] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Emocional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cabecera del Mes con Flechas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _prevMonth,
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'es_MX').format(_currentMonth).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Días de la Semana: L M M J V S D
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Grid del Calendario
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: 42, // 6 semanas completas
              itemBuilder: (context, index) {
                final dayOffset = index - (firstWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox.shrink(); // Día fuera del mes
                }

                final dayNumber = dayOffset + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                final entry = monthEntries[dayNumber];
                final isSelected = _selectedDate != null &&
                    _selectedDate!.year == date.year &&
                    _selectedDate!.month == date.month &&
                    _selectedDate!.day == date.day;

                Color dayColor = Colors.transparent;
                if (entry != null) {
                  dayColor = AppColors.getMoodColor(entry.moodValue);
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryNeon.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryNeon : Colors.white.withValues(alpha: 0.06),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (entry != null)
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dayColor,
                              boxShadow: [
                                BoxShadow(
                                  color: dayColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Detalle del día seleccionado (o botón para registrarlo si está vacío)
            if (_selectedDate != null) ...[
              if (selectedEntry != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.getMoodColor(selectedEntry.moodValue).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy', 'es_MX').format(selectedEntry.date),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          MoodBadge(moodValue: selectedEntry.moodValue),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '⚡ Energía: ${selectedEntry.energyLevel}/10',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.energyAmber),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '🌙 Sueño: ${selectedEntry.sleepHours}h',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryNeon),
                          ),
                        ],
                      ),
                      if (selectedEntry.activities.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: selectedEntry.activities.map((a) => Chip(label: Text(a), padding: EdgeInsets.zero)).toList(),
                        ),
                      ],
                      if (selectedEntry.note.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '"${selectedEntry.note}"',
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NewEntryScreen(entryToEdit: selectedEntry)),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar este día'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sin registro el ${DateFormat('d MMMM yyyy', 'es_MX').format(_selectedDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewEntryScreen(initialDate: _selectedDate)),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar para esta fecha'),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
