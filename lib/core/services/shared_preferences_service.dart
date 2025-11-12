import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// SharedPreferences服务
/// 提供简单的键值对存储功能
class SharedPreferencesService {
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('正在初始化SharedPreferences服务...');
      
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      Logger.info('SharedPreferences服务初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('SharedPreferences服务初始化失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// 检查服务是否可用
  void _checkInitialized() {
    if (!_isInitialized || _prefs == null) {
      throw Exception('SharedPreferences服务未初始化');
    }
  }
  
  // String 操作
  
  /// 获取字符串值
  String? getString(String key) {
    _checkInitialized();
    try {
      return _prefs!.getString(key);
    } catch (e, stackTrace) {
      Logger.error('获取字符串值失败: $key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 设置字符串值
  Future<bool> setString(String key, String value) async {
    _checkInitialized();
    try {
      final result = await _prefs!.setString(key, value);
      if (result) {
        Logger.debug('设置字符串值: $key = $value');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('设置字符串值失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Bool 操作
  
  /// 获取布尔值
  bool? getBool(String key) {
    _checkInitialized();
    try {
      return _prefs!.getBool(key);
    } catch (e, stackTrace) {
      Logger.error('获取布尔值失败: $key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 设置布尔值
  Future<bool> setBool(String key, bool value) async {
    _checkInitialized();
    try {
      final result = await _prefs!.setBool(key, value);
      if (result) {
        Logger.debug('设置布尔值: $key = $value');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('设置布尔值失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Int 操作
  
  /// 获取整数值
  int? getInt(String key) {
    _checkInitialized();
    try {
      return _prefs!.getInt(key);
    } catch (e, stackTrace) {
      Logger.error('获取整数值失败: $key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 设置整数值
  Future<bool> setInt(String key, int value) async {
    _checkInitialized();
    try {
      final result = await _prefs!.setInt(key, value);
      if (result) {
        Logger.debug('设置整数值: $key = $value');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('设置整数值失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Double 操作
  
  /// 获取浮点数值
  double? getDouble(String key) {
    _checkInitialized();
    try {
      return _prefs!.getDouble(key);
    } catch (e, stackTrace) {
      Logger.error('获取浮点数值失败: $key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 设置浮点数值
  Future<bool> setDouble(String key, double value) async {
    _checkInitialized();
    try {
      final result = await _prefs!.setDouble(key, value);
      if (result) {
        Logger.debug('设置浮点数值: $key = $value');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('设置浮点数值失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // StringList 操作
  
  /// 获取字符串列表
  List<String>? getStringList(String key) {
    _checkInitialized();
    try {
      return _prefs!.getStringList(key);
    } catch (e, stackTrace) {
      Logger.error('获取字符串列表失败: $key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 设置字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    _checkInitialized();
    try {
      final result = await _prefs!.setStringList(key, value);
      if (result) {
        Logger.debug('设置字符串列表: $key = $value');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('设置字符串列表失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // 通用操作
  
  /// 检查键是否存在
  bool containsKey(String key) {
    _checkInitialized();
    try {
      return _prefs!.containsKey(key);
    } catch (e, stackTrace) {
      Logger.error('检查键是否存在失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 删除键
  Future<bool> remove(String key) async {
    _checkInitialized();
    try {
      final result = await _prefs!.remove(key);
      if (result) {
        Logger.debug('删除键: $key');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('删除键失败: $key', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 获取所有键
  Set<String> getKeys() {
    _checkInitialized();
    try {
      return _prefs!.getKeys();
    } catch (e, stackTrace) {
      Logger.error('获取所有键失败', error: e, stackTrace: stackTrace);
      return <String>{};
    }
  }
  
  /// 清除所有数据
  Future<bool> clear() async {
    _checkInitialized();
    try {
      final result = await _prefs!.clear();
      if (result) {
        Logger.info('清除所有SharedPreferences数据');
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('清除所有数据失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 重新加载数据
  Future<void> reload() async {
    _checkInitialized();
    try {
      await _prefs!.reload();
      Logger.debug('重新加载SharedPreferences数据');
    } catch (e, stackTrace) {
      Logger.error('重新加载数据失败', error: e, stackTrace: stackTrace);
    }
  }
  
  // 便捷方法
  
  /// 获取带默认值的字符串
  String getStringWithDefault(String key, String defaultValue) {
    return getString(key) ?? defaultValue;
  }
  
  /// 获取带默认值的布尔值
  bool getBoolWithDefault(String key, bool defaultValue) {
    return getBool(key) ?? defaultValue;
  }
  
  /// 获取带默认值的整数值
  int getIntWithDefault(String key, int defaultValue) {
    return getInt(key) ?? defaultValue;
  }
  
  /// 获取带默认值的浮点数值
  double getDoubleWithDefault(String key, double defaultValue) {
    return getDouble(key) ?? defaultValue;
  }
  
  /// 获取带默认值的字符串列表
  List<String> getStringListWithDefault(String key, List<String> defaultValue) {
    return getStringList(key) ?? defaultValue;
  }
  
  /// 增加整数值
  Future<bool> incrementInt(String key, [int increment = 1]) async {
    final currentValue = getInt(key) ?? 0;
    return await setInt(key, currentValue + increment);
  }
  
  /// 切换布尔值
  Future<bool> toggleBool(String key, [bool? defaultValue]) async {
    final currentValue = getBool(key) ?? (defaultValue ?? false);
    return await setBool(key, !currentValue);
  }
  
  /// 批量设置
  Future<bool> setBatch(Map<String, dynamic> data) async {
    _checkInitialized();
    
    try {
      bool allSuccess = true;
      
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        
        bool success = false;
        if (value is String) {
          success = await setString(key, value);
        } else if (value is bool) {
          success = await setBool(key, value);
        } else if (value is int) {
          success = await setInt(key, value);
        } else if (value is double) {
          success = await setDouble(key, value);
        } else if (value is List<String>) {
          success = await setStringList(key, value);
        } else {
          Logger.warning('不支持的数据类型: $key = $value (${value.runtimeType})');
          success = false;
        }
        
        if (!success) {
          allSuccess = false;
          Logger.error('批量设置失败: $key = $value');
        }
      }
      
      return allSuccess;
      
    } catch (e, stackTrace) {
      Logger.error('批量设置失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 批量删除
  Future<bool> removeBatch(List<String> keys) async {
    _checkInitialized();
    
    try {
      bool allSuccess = true;
      
      for (final key in keys) {
        if (!await remove(key)) {
          allSuccess = false;
        }
      }
      
      return allSuccess;
      
    } catch (e, stackTrace) {
      Logger.error('批量删除失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 获取所有数据的快照
  Map<String, dynamic> getAllData() {
    _checkInitialized();
    
    try {
      final data = <String, dynamic>{};
      final keys = getKeys();
      
      for (final key in keys) {
        // 尝试获取不同类型的值
        final value = _prefs!.get(key);
        if (value != null) {
          data[key] = value;
        }
      }
      
      return data;
      
    } catch (e, stackTrace) {
      Logger.error('获取所有数据失败', error: e, stackTrace: stackTrace);
      return <String, dynamic>{};
    }
  }
  
  /// 打印所有数据（调试用）
  void printAllData() {
    final data = getAllData();
    Logger.debug('SharedPreferences 所有数据:');
    for (final entry in data.entries) {
      Logger.debug('  ${entry.key}: ${entry.value} (${entry.value.runtimeType})');
    }
  }
}