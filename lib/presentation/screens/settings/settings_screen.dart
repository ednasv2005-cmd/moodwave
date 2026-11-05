import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:moodwave/presentation/providers/mood_provider.dart';
import 'package:moodwave/presentation/providers/security_provider.dart';
import 'package:moodwave/presentation/providers/theme_provider.dart';
import 'package:moodwave/core/constants/app_colors.dart';
import 'package:moodwave/core/ethics/ethics_protocol.dart';
import 'package:moodwave/presentation/widgets/risk_protocol_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showSetPinDialog(BuildContext context, SecurityProvider secProvider) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configurar PIN de 4 dígitos'),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Introduce 4 números',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (pinCtrl.text.length == 4) {
                secProvider.enablePin(pinCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN activado correctamente 🔒')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, MoodProvider moodProvider) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exportar Respaldo Cifrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tus datos se cifrarán con PBKDF2 y un flujo seguro. Introduce una contraseña para proteger el archivo:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña del respaldo'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.length >= 4) {
                Navigator.pop(ctx);
                final encryptedJson = await moodProvider.exportBackup(passCtrl.text);
                await SharePlus.instance.share(
                  ShareParams(
                    text: encryptedJson,
                    subject: 'Respaldo Cifrado MoodWave (${DateTime.now().day}_${DateTime.now().month})',
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La contraseña debe tener al menos 4 caracteres.')),
                );
              }
            },
            child: const Text('Cifrar y Compartir'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, MoodProvider moodProvider) {
    final jsonCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Respaldo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: jsonCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Pega aquí el contenido JSON cifrado',
                  hintText: '{"version":"1.0","salt":...}',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña con la que se cifró'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final count = await moodProvider.importBackup(jsonCtrl.text.trim(), passCtrl.text);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Éxito! Se restauraron $count registros.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al descifrar: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: AppColors.moodAngry,
                    ),
                  );
                }
              }
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showMaxCharsDialog(BuildContext context, MoodProvider moodProvider) {
    final chars = [140, 280, 500, 1000];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Longitud Máxima del Diario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: chars.map((c) {
            final isCurrent = moodProvider.maxJournalChars == c;
            return ListTile(
              title: Text('$c caracteres'),
              trailing: isCurrent ? const Icon(Icons.check, color: AppColors.primaryNeon) : null,
              onTap: () {
                moodProvider.updateMaxJournalChars(c);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secProvider = Provider.of<SecurityProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración & Privacidad'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Sección Seguridad y PIN (PDF 1 Requisito 7)
          _buildSectionHeader('Seguridad y Protección Local'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Bloqueo por PIN'),
                  subtitle: Text(secProvider.isPinEnabled ? 'PIN activado y protegido' : 'Desactivado'),
                  value: secProvider.isPinEnabled,
                  activeThumbColor: AppColors.primaryNeon,
                  onChanged: (val) {
                    if (val) {
                      _showSetPinDialog(context, secProvider);
                    } else {
                      secProvider.disablePin();
                    }
                  },
                ),
                if (secProvider.isPinEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Desbloqueo Biométrico / Huella'),
                    subtitle: const Text('Permitir acceso rápido con biometría'),
                    value: secProvider.isBiometricsEnabled,
                    activeThumbColor: AppColors.primaryNeon,
                    onChanged: (val) => secProvider.toggleBiometrics(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Cambiar PIN'),
                    leading: const Icon(Icons.pin_rounded, color: AppColors.primaryNeon),
                    onTap: () => _showSetPinDialog(context, secProvider),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección Preferencias de la App
          _buildSectionHeader('Preferencias del Diario'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded, color: AppColors.secondaryNeon),
                  title: const Text('Límite de caracteres en reflexión'),
                  subtitle: Text('${moodProvider.maxJournalChars} caracteres'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showMaxCharsDialog(context, moodProvider),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primaryNeon),
                  title: const Text('Modo Oscuro Cyber-Aesthetic'),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppColors.primaryNeon,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección Respaldo Cifrado (PDF 2 Nivel 2)
          _buildSectionHeader('Respaldo y Cifrado (AES-PBKDF2)'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryNeon),
                  title: const Text('Exportar Respaldo Cifrado'),
                  subtitle: const Text('Genera paquete JSON protegido con contraseña'),
                  onTap: () => _showExportDialog(context, moodProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined, color: AppColors.secondaryNeon),
                  title: const Text('Importar / Restaurar Respaldo'),
                  subtitle: const Text('Descifra y reemplaza base de datos'),
                  onTap: () => _showImportDialog(context, moodProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sección Datos de Prueba (PDF 2 Condición de Partida)
          _buildSectionHeader('Datos de Prueba para Evaluación (UPIIT)'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.science_rounded, color: AppColors.energyAmber),
              title: const Text('Generar 90 días con patrones plantados'),
              subtitle: const Text('Carga 90 registros correlacionados (Ejercicio, Trabajo, Sueño) para validar el motor analítico'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Cargar 90 días de prueba?'),
                    content: const Text(
                      'Esta acción reemplazará los registros actuales por 90 días sintéticos '
                      'diseñados con patrones plantados para demostrar las estadísticas y correlaciones.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Generar Datos')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await moodProvider.loadSyntheticDemoData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡90 días de datos sintéticos cargados con éxito! 🚀'),
                        backgroundColor: AppColors.primaryNeon,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Sección Ética y Control del Usuario (PDF 2 Reglas)
          _buildSectionHeader('Ética, Salud y Derecho al Olvido'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded, color: AppColors.primaryNeon),
                  title: const Text('Líneas de Ayuda y Recursos'),
                  subtitle: const Text('Línea de la Vida, SAPTEL y apoyo en crisis'),
                  onTap: () => RiskProtocolDialog.show(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.moodAngry),
                  title: const Text('Borrar todos mis datos ("Derecho al olvido")'),
                  subtitle: const Text('Elimina definitivamente todos los registros locales'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Borrar TODOS los datos?'),
                        content: const Text(
                          'Esta acción es irreversible y eliminará todos tus registros emocionales de la base de datos.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.moodAngry),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Borrar Todo Definitivamente'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await moodProvider.clearAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Todos los datos han sido borrados.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Aviso institucional UPIIT - IPN
          Center(
            child: Column(
              children: [
                const Text(
                  'MoodWave v2.0 • IPN UPIIT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  EthicsProtocol.disclaimer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Colors.grey,
        ),
      ),
    );
  }
}
