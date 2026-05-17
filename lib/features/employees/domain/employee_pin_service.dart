import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmployeePinService {
  EmployeePinService._();

  static const _pinHashKey = 'employee_pin_hash';
  static const _saltKey = 'employee_pin_salt';
  static const _defaultPin = '1234';

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  static String _getStoredSalt(Box<dynamic> settingsBox) {
    var salt = settingsBox.get(_saltKey) as String?;
    if (salt == null) {
      salt = _generateSalt();
      settingsBox.put(_saltKey, salt);
    }
    return salt;
  }

  static Future<bool> verifyPin(
    Box<dynamic> settingsBox,
    String pin,
  ) async {
    final salt = _getStoredSalt(settingsBox);
    final storedHash = settingsBox.get(_pinHashKey) as String?;

    if (storedHash == null) {
      final defaultHash = _hashPin(_defaultPin, salt);
      await settingsBox.put(_pinHashKey, defaultHash);
      return pin == _defaultPin;
    }

    return _hashPin(pin, salt) == storedHash;
  }

  static Future<bool> changePin(
    Box<dynamic> settingsBox,
    String currentPin,
    String newPin,
  ) async {
    final verified = await verifyPin(settingsBox, currentPin);
    if (!verified) return false;

    final salt = _generateSalt();
    final newHash = _hashPin(newPin, salt);

    await settingsBox.put(_saltKey, salt);
    await settingsBox.put(_pinHashKey, newHash);
    return true;
  }
}
