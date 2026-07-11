import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/app_flavor_config.dart';



abstract class StorageKeys {
  StorageKeys();

  static const String token = "AUTH_TOKEN";
  static const String firstName  = "FIRSTNAME";
  static const String lastName = "LASTNAME";


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
      _prefs.setInt(key, value);
    } else if (value is String) {
      _prefs.setString(key, value);
    } else if (value is bool) {
      _prefs.setBool(key, value);
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

}





