import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheTool {
  static CacheTool get instance => GetIt.instance<CacheTool>();
  late final SharedPreferences _preferences;

  Future initConfig() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// 保存
  static void saveValue({required String key, required dynamic value}) {
    if (value is int) {
      instance._preferences.setInt(key, value);
    } else if (value is String) {
      instance._preferences.setString(key, value);
    } else if (value is double) {
      instance._preferences.setDouble(key, value);
    } else if (value is bool) {
      instance._preferences.setBool(key, value);
    }
  }

  static int getInt({required String key, int def = 0}) {
    return instance._preferences.getInt(key) ?? def;
  }

  static String getString({required String key, String def = ''}) {
    return instance._preferences.getString(key) ?? def;
  }

  static double getDouble({required String key, double def = 0.0}) {
    return instance._preferences.getDouble(key) ?? def;
  }

  static bool getBool({required String key, bool def = false}) {
    return instance._preferences.getBool(key) ?? def;
  }

  static Future<bool> remove({required String key}) {
    return instance._preferences.remove(key);
  }
}
