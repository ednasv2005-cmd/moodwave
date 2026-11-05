import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moodwave/presentation/providers/security_provider.dart';
import 'package:moodwave/presentation/screens/home/home_dashboard_screen.dart';
import 'package:moodwave/presentation/screens/calendar/calendar_screen.dart';
import 'package:moodwave/presentation/screens/analytics/analytics_hub_screen.dart';
import 'package:moodwave/presentation/screens/ai_hub/ai_insights_screen.dart';
import 'package:moodwave/presentation/screens/reports/pdf_report_screen.dart';
import 'package:moodwave/presentation/screens/settings/settings_screen.dart';
import 'package:moodwave/presentation/screens/auth/pin_lock_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    CalendarScreen(),
    AnalyticsHubScreen(),
    AiInsightsScreen(),
    PdfReportScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final secProvider = Provider.of<SecurityProvider>(context, listen: false);
      secProvider.checkAutoLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, secProvider, _) {
        if (secProvider.isLocked) {
          return PinLockScreen(
            onUnlocked: () {
              // Desbloqueado
            },
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                secProvider.recordUserActivity();
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendario',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.insights_rounded),
                  label: 'Análisis',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'IA',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  activeIcon: Icon(Icons.picture_as_pdf_rounded),
                  label: 'Reporte',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Ajustes',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
