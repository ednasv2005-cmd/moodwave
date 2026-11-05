import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/domain/pdf/pdf_report_generator.dart';
import 'package:moodwave/core/constants/app_colors.dart';

class PdfReportScreen extends StatelessWidget {
  const PdfReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final entries = moodProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte PDF MoodWave'),
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text('Registra al menos un día para generar tu reporte.'),
            )
          : PdfPreview(
              build: (format) => PdfReportGenerator.generateMonthlyReport(entries),
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'Reporte_MoodWave_${DateTime.now().month}_${DateTime.now().year}.pdf',
              previewPageMargin: const EdgeInsets.all(16),
              loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
            ),
    );
  }
}
