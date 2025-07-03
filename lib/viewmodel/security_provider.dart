import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/preferences_service.dart';
import '../utils/app_constants.dart';

class SecurityProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isSecurityEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isAuthenticated = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  
  SecurityProvider() {
    _loadSecuritySettings();
    _checkBiometricSupport();
  }
  
  // Getters
  bool get isSecurityEnabled => _isSecurityEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get canCheckBiometrics => _canCheckBiometrics;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  String? get userPin => _prefs.userPin;
  
  bool get hasFingerprintSupport => _availableBiometrics.contains(BiometricType.fingerprint);
  bool get hasFaceSupport => _availableBiometrics.contains(BiometricType.face);
  bool get hasStrongBiometrics => _availableBiometrics.contains(BiometricType.strong);
  
  void _loadSecuritySettings() {
    _isSecurityEnabled = _prefs.isSecurityEnabled;
    _isBiometricEnabled = _prefs.isBiometricEnabled;
    notifyListeners();
  }
  
  Future<void> _checkBiometricSupport() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      _availableBiometrics = await _localAuth.getAvailableBiometrics();
    } catch (e) {
      _canCheckBiometrics = false;
      _availableBiometrics = [];
    }
    notifyListeners();
  }
  
  Future<bool> enableSecurity(String pin) async {
    if (pin.length < AppConstants.minPinLength || pin.length > AppConstants.maxPinLength) {
      return false;
    }
    
    try {
      await _prefs.setUserPin(pin);
      await _prefs.setSecurityEnabled(true);
      _isSecurityEnabled = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> disableSecurity() async {
    await _prefs.setSecurityEnabled(false);
    await _prefs.removeUserPin();
    await _prefs.setBiometricEnabled(false);
    
    _isSecurityEnabled = false;
    _isBiometricEnabled = false;
    _isAuthenticated = false;
    
    notifyListeners();
  }
  
  Future<bool> changePin(String currentPin, String newPin) async {
    if (userPin != currentPin) {
      return false;
    }
    
    if (newPin.length < AppConstants.minPinLength || newPin.length > AppConstants.maxPinLength) {
      return false;
    }
    
    try {
      await _prefs.setUserPin(newPin);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> verifyPin(String pin) async {
    final storedPin = userPin;
    if (storedPin == null) return false;
    
    final isValid = storedPin == pin;
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    
    return isValid;
  }
  
  Future<bool> enableBiometric() async {
    if (!_canCheckBiometrics || _availableBiometrics.isEmpty) {
      return false;
    }
    
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for Budget Tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (isAuthenticated) {
        await _prefs.setBiometricEnabled(true);
        _isBiometricEnabled = true;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> disableBiometric() async {
    await _prefs.setBiometricEnabled(false);
    _isBiometricEnabled = false;
    notifyListeners();
  }
  
  Future<bool> authenticateWithBiometric() async {
    if (!_isBiometricEnabled || !_canCheckBiometrics) {
      return false;
    }
    
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Budget Tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (isAuthenticated) {
        _isAuthenticated = true;
        notifyListeners();
      }
      
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> authenticate({String? pin}) async {
    // Try biometric first if enabled
    if (_isBiometricEnabled && _canCheckBiometrics) {
      final biometricResult = await authenticateWithBiometric();
      if (biometricResult) {
        return true;
      }
    }
    
    // Fall back to PIN if provided
    if (pin != null) {
      return await verifyPin(pin);
    }
    
    return false;
  }
  
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
  
  String getBiometricTypeString() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.strong)) {
      return 'Biometric';
    } else {
      return 'Biometric';
    }
  }
  
  IconData getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }
  
  Future<void> refreshBiometricSupport() async {
    await _checkBiometricSupport();
  }
  
  bool isValidPin(String pin) {
    return pin.length >= AppConstants.minPinLength && 
           pin.length <= AppConstants.maxPinLength &&
           RegExp(r'^\d+$').hasMatch(pin);
  }
}