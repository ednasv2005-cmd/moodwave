import 'package:flutter/material.dart';
import 'package:moodwave/core/constants/app_colors.dart';

class EnergySlider extends StatelessWidget {
  final int currentEnergy;
  final ValueChanged<int> onChanged;

  const EnergySlider({
    super.key,
    required this.currentEnergy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.energyAmber, size: 22),
                const SizedBox(width: 6),
                const Text(
                  'Nivel de energía',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.energyAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.energyAmber.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$currentEnergy / 10',
                style: const TextStyle(
                  color: AppColors.energyAmber,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fila interactiva de botones numéricos (1 al 10)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) {
              final val = index + 1;
              final isSelected = val == currentEnergy;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onChanged(val),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.energyAmber
                          : AppColors.energyAmber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.energyAmber.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.energyAmber.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$val',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 Agotado', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('5 Moderado', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('10 Con todo', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
