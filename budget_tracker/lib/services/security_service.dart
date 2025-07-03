import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../utils/app_constants.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // PIN Management
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPin = _hashPin(pin);
    await prefs.setString(AppConstants.keyUserPin, hashedPin);
    await prefs.setBool(AppConstants.keyPinEnabled, true);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(AppConstants.keyUserPin);
    if (storedPin == null) return false;
    
    final hashedPin = _hashPin(pin);
    return hashedPin == storedPin;
  }

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyPinEnabled) ?? false;
  }

  Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyPinEnabled, false);
    await prefs.remove(AppConstants.keyUserPin);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Biometric Authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    String reason = 'Please verify your identity to access Budget Tracker',
  }) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyBiometricEnabled) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyBiometricEnabled, enabled);
  }

  // Security Check
  Future<bool> requiresAuthentication() async {
    final pinEnabled = await isPinEnabled();
    final biometricEnabled = await isBiometricEnabled();
    return pinEnabled || biometricEnabled;
  }

  Future<bool> authenticateUser() async {
    final biometricEnabled = await isBiometricEnabled();
    final pinEnabled = await isPinEnabled();

    if (biometricEnabled && await isBiometricAvailable()) {
      return await authenticateWithBiometrics();
    } else if (pinEnabled) {
      // PIN authentication will be handled by the UI
      return false; // Return false to indicate PIN is needed
    }

    return true; // No authentication required
  }

  // Session Management
  static const String _keyLastAuthTime = 'last_auth_time';
  static const int _authTimeoutMinutes = 5;

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAuthTime = prefs.getInt(_keyLastAuthTime);
    
    if (lastAuthTime == null) return false;
    
    final lastAuth = DateTime.fromMillisecondsSinceEpoch(lastAuthTime);
    final now = DateTime.now();
    final difference = now.difference(lastAuth).inMinutes;
    
    return difference < _authTimeoutMinutes;
  }

  Future<void> updateSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastAuthTime, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastAuthTime);
  }
}