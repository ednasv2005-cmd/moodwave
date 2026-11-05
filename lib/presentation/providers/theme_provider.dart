import 'package:flutter/material.dart';
import '../../data/datasources/preference_helper.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferenceHelper _prefHelper;
  late bool _isDarkMode;

  ThemeProvider(this._prefHelper) {
    _isDarkMode = _prefHelper.isDarkMode;
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefHelper.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}

