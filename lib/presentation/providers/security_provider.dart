import 'package:flutter/material.dart';
import '../../data/datasources/preference_helper.dart';

class SecurityProvider extends ChangeNotifier {
  final PreferenceHelper _prefHelper;

  bool _isLocked = false;
  DateTime _lastActiveTime = DateTime.now();

  SecurityProvider(this._prefHelper) {
    if (_prefHelper.isPinEnabled && _prefHelper.pinCode != null) {
      _isLocked = true;
    }
  }

  bool get isLocked => _isLocked;
  bool get isPinEnabled => _prefHelper.isPinEnabled && _prefHelper.pinCode != null;
  bool get isBiometricsEnabled => _prefHelper.isBiometricsEnabled;
  int get autoLockSeconds => _prefHelper.autoLockDurationSeconds;

  bool verifyPin(String inputPin) {
    final storedPin = _prefHelper.pinCode;
    if (storedPin == inputPin) {
      _isLocked = false;
      _lastActiveTime = DateTime.now();
      notifyListeners();
      return true;
    }
    return false;
  }

  void unlock() {
    _isLocked = false;
    _lastActiveTime = DateTime.now();
    notifyListeners();
  }

  void lock() {
    if (isPinEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<void> enablePin(String newPin) async {
    await _prefHelper.setPinCode(newPin);
    await _prefHelper.setPinEnabled(true);
    _isLocked = false;
    notifyListeners();
  }

  Future<void> disablePin() async {
    await _prefHelper.removePin();
    await _prefHelper.setPinEnabled(false);
    _isLocked = false;
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    await _prefHelper.setBiometricsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setAutoLockSeconds(int seconds) async {
    await _prefHelper.setAutoLockDurationSeconds(seconds);
    notifyListeners();
  }

  void recordUserActivity() {
    _lastActiveTime = DateTime.now();
  }

  void checkAutoLock() {
    if (!isPinEnabled || _isLocked) return;
    final timeout = autoLockSeconds;
    if (timeout <= 0) return; // 0 o negativo = nunca

    final elapsed = DateTime.now().difference(_lastActiveTime).inSeconds;
    if (elapsed >= timeout) {
      _isLocked = true;
      notifyListeners();
    }
  }
}

