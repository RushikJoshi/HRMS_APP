import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _employeeIdKey = 'employee_id';
  static const String _companyCodeKey = 'company_code';
  static const String _localFaceEmbeddingKey = 'local_face_embedding';
  static const String _localFaceEmployeeIdKey = 'local_face_employee_id';
  static const String _localFaceCompanyCodeKey = 'local_face_company_code';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveEmployeeId(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeIdKey, employeeId);
  }

  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  static Future<void> saveCompanyCode(String companyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyCodeKey, companyCode);
  }

  static Future<String?> getCompanyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyCodeKey);
  }

  static Future<void> saveLocalFaceRegistration({
    required List<double> embedding,
    String? employeeId,
    String? companyCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_localFaceEmbeddingKey, jsonEncode(embedding));

    if (employeeId != null && employeeId.isNotEmpty) {
      await prefs.setString(_localFaceEmployeeIdKey, employeeId);
    } else {
      await prefs.remove(_localFaceEmployeeIdKey);
    }

    if (companyCode != null && companyCode.isNotEmpty) {
      await prefs.setString(_localFaceCompanyCodeKey, companyCode);
    } else {
      await prefs.remove(_localFaceCompanyCodeKey);
    }
  }

  static Future<List<double>?> getLocalFaceEmbedding({
    String? employeeId,
    String? companyCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedEmbedding = prefs.getString(_localFaceEmbeddingKey);

    if (encodedEmbedding == null || encodedEmbedding.isEmpty) {
      return null;
    }

    final storedEmployeeId = prefs.getString(_localFaceEmployeeIdKey);
    final storedCompanyCode = prefs.getString(_localFaceCompanyCodeKey);

    if (employeeId != null &&
        employeeId.isNotEmpty &&
        storedEmployeeId != null &&
        storedEmployeeId != employeeId) {
      return null;
    }

    if (companyCode != null &&
        companyCode.isNotEmpty &&
        storedCompanyCode != null &&
        storedCompanyCode != companyCode) {
      return null;
    }

    try {
      final decoded = jsonDecode(encodedEmbedding);
      if (decoded is! List) {
        return null;
      }

      return decoded
          .whereType<num>()
          .map((value) => value.toDouble())
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasLocalFaceRegistration({
    String? employeeId,
    String? companyCode,
  }) async {
    final embedding = await getLocalFaceEmbedding(
      employeeId: employeeId,
      companyCode: companyCode,
    );
    return embedding != null && embedding.isNotEmpty;
  }

  static Future<void> clearLocalFaceRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localFaceEmbeddingKey);
    await prefs.remove(_localFaceEmployeeIdKey);
    await prefs.remove(_localFaceCompanyCodeKey);
  }

  static Future<void> clearSession({bool keepToken = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!keepToken) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_employeeIdKey);
      await prefs.remove(_companyCodeKey);
      await clearLocalFaceRegistration();
    }
    // We do NOT remove _biometricEnabledKey as that is a device setting
  }

  static Future<void> clearAll() async {
    await clearSession(keepToken: false);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static const String _biometricEnabledKey = 'biometric_enabled';

  static Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
}

