import 'package:flutter/material.dart';
import 'package:moodwave/core/constants/mood_constants.dart';

class MoodBadge extends StatelessWidget {
  final int moodValue;
  final bool showLabel;
  final double size;

  const MoodBadge({
    super.key,
    required this.moodValue,
    this.showLabel = true,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final mood = MoodConstants.fromValue(moodValue);

    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: mood.color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: mood.color, width: 2),
        ),
        child: Center(
          child: Text(
            mood.emoji,
            style: TextStyle(fontSize: size * 0.55),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mood.color.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: TextStyle(fontSize: size * 0.6)),
          const SizedBox(width: 6),
          Text(
            mood.label,
            style: TextStyle(
              color: mood.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
