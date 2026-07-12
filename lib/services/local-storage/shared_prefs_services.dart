import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/app_flavor_config.dart';
import '../../model/team_task_res_model.dart';
import '../../model/offline_request_model.dart';

abstract class StorageKeys {
  StorageKeys();

  static const String token = "AUTH_TOKEN";
  static const String firstName  = "FIRSTNAME";
  static const String lastName = "LASTNAME";
  static const String email = "EMAIL";
  static const String tasksCache = "TASKS_CACHE";
  static const String offlineQueue = "OFFLINE_QUEUE";
  static const String themeMode = "THEME_MODE";

  dynamic valueGetter(String key);

  valueSetter(String key, dynamic value);
}

class SharedPrefsService implements StorageKeys {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  @override
  valueGetter(String key) {
    debugPrint("[$key] => ${_prefs.get(key)}");
    return _prefs.get(key);
  }

  @override
  valueSetter(String key, value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else {
      throw "undefine type";
    }
  }

  String? getBaseUrl() {
    String? baseUrl = AppFlavorConfig.shared.baseUrl;
    return baseUrl;
  }

  clearSingleData(String clearData) {
    _prefs.remove(clearData);
  }

  // --- Task Cache Methods ---
  List<TeamTaskResModel> getCachedTasks() {
    final String? cachedStr = _prefs.getString(StorageKeys.tasksCache);
    if (cachedStr == null || cachedStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(cachedStr);
      return decoded.map((json) => TeamTaskResModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error decoding cached tasks: $e");
      return [];
    }
  }

  Future<void> cacheTasks(List<TeamTaskResModel> tasks) async {
    try {
      final List<Map<String, dynamic>> rawList = tasks.map((task) => task.toJson()).toList();
      await _prefs.setString(StorageKeys.tasksCache, jsonEncode(rawList));
    } catch (e) {
      debugPrint("Error encoding cached tasks: $e");
    }
  }

  // --- Offline Queue Methods ---
  List<OfflineRequestModel> getOfflineQueue() {
    final String? queueStr = _prefs.getString(StorageKeys.offlineQueue);
    if (queueStr == null || queueStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(queueStr);
      return decoded.map((json) => OfflineRequestModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error decoding offline queue: $e");
      return [];
    }
  }

  Future<void> saveOfflineQueue(List<OfflineRequestModel> queue) async {
    try {
      final List<Map<String, dynamic>> rawList = queue.map((req) => req.toJson()).toList();
      await _prefs.setString(StorageKeys.offlineQueue, jsonEncode(rawList));
    } catch (e) {
      debugPrint("Error encoding offline queue: $e");
    }
  }

  // --- Session Storage Methods ---
  bool isLoggedIn() {
    final String? authToken = _prefs.getString(StorageKeys.token);
    return authToken != null && authToken.isNotEmpty;
  }

  Future<void> setSession(String emailVal, String tokenVal) async {
    await _prefs.setString(StorageKeys.email, emailVal);
    await _prefs.setString(StorageKeys.token, tokenVal);
  }

  Future<void> clearSession() async {
    await _prefs.remove(StorageKeys.email);
    await _prefs.remove(StorageKeys.token);
  }

  // --- Theme Mode Methods ---
  bool getIsDarkMode() {
    return _prefs.getBool(StorageKeys.themeMode) ?? true; // defaults to dark mode
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(StorageKeys.themeMode, isDark);
  }
}
