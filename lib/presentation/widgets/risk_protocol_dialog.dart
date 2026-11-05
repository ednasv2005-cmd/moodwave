import 'package:flutter/material.dart';
import 'package:moodwave/core/ethics/ethics_protocol.dart';
import 'package:moodwave/core/constants/app_colors.dart';

class RiskProtocolDialog extends StatelessWidget {
  const RiskProtocolDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const RiskProtocolDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.moodSad.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.moodSad, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Estamos contigo',
              style: TextStyle(fontSize: 20, fontWeight: pwBold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: pwCrossAxisAlignmentStart,
          children: [
            const Text(
              'Notamos que estás pasando por un momento muy difícil o abrumador. '
              'Queremos recordarte que tus sentimientos son válidos y que no tienes que enfrentar esto en soledad.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: pwCrossAxisAlignmentStart,
                children: [
                  const Text(
                    'Líneas Gratuitas de Apoyo Inmediato:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ...EthicsProtocol.resources.map(
                    (res) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: pwCrossAxisAlignmentStart,
                        children: [
                          Text(
                            res.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.phone_in_talk, size: 14, color: AppColors.primaryNeon),
                              const SizedBox(width: 4),
                              SelectableText(
                                res.phone,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNeon,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${res.available})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              EthicsProtocol.disclaimer,
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.hintColor),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuar a mi registro'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNeon,
            foregroundColor: Colors.white,
          ),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

const FontWeight pwBold = FontWeight.bold;
const CrossAxisAlignment pwCrossAxisAlignmentStart = CrossAxisAlignment.start;
