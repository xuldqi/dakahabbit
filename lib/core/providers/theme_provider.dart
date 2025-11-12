import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_preferences_service.dart';
import 'app_providers.dart';
import '../../app/app_theme.dart';
import '../utils/logger.dart';

/// 主题模式枚举
enum ThemeMode {
  system,
  light,
  dark,
}

/// 主题设置数据
class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.primaryColor = const Color(0xFF4ECDC4),
    this.useMaterial3 = true,
    this.fontFamily = 'DakaHabit',
    this.fontSize = 14.0,
    this.borderRadius = 12.0,
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
  });

  /// 主题模式
  final ThemeMode mode;
  
  /// 主色调
  final Color primaryColor;
  
  /// 是否使用Material 3
  final bool useMaterial3;
  
  /// 字体家族
  final String fontFamily;
  
  /// 字体大小
  final double fontSize;
  
  /// 圆角半径
  final double borderRadius;
  
  /// 是否启用动画
  final bool enableAnimations;
  
  /// 是否启用触觉反馈
  final bool enableHapticFeedback;

  ThemeSettings copyWith({
    ThemeMode? mode,
    Color? primaryColor,
    bool? useMaterial3,
    String? fontFamily,
    double? fontSize,
    double? borderRadius,
    bool? enableAnimations,
    bool? enableHapticFeedback,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'primaryColor': primaryColor.value,
      'useMaterial3': useMaterial3,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'borderRadius': borderRadius,
      'enableAnimations': enableAnimations,
      'enableHapticFeedback': enableHapticFeedback,
    };
  }

  /// 从JSON创建
  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      mode: ThemeMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => ThemeMode.system,
      ),
      primaryColor: Color(json['primaryColor'] ?? 0xFF4ECDC4),
      useMaterial3: json['useMaterial3'] ?? true,
      fontFamily: json['fontFamily'] ?? 'DakaHabit',
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      borderRadius: (json['borderRadius'] ?? 12.0).toDouble(),
      enableAnimations: json['enableAnimations'] ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
    );
  }

  @override
  String toString() {
    return 'ThemeSettings('
           'mode: $mode, '
           'primaryColor: $primaryColor, '
           'useMaterial3: $useMaterial3, '
           'fontFamily: $fontFamily, '
           'fontSize: $fontSize, '
           'borderRadius: $borderRadius, '
           'enableAnimations: $enableAnimations, '
           'enableHapticFeedback: $enableHapticFeedback'
           ')';
  }
}

/// 主题设置Provider
final themeSettingsProvider = StateNotifierProvider<ThemeSettingsNotifier, ThemeSettings>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  return ThemeSettingsNotifier(prefsService);
});

/// 主题设置通知器
class ThemeSettingsNotifier extends StateNotifier<ThemeSettings> {
  static const String _themeSettingsKey = 'theme_settings';

  final SharedPreferencesService _prefsService;

  ThemeSettingsNotifier(this._prefsService) : super(const ThemeSettings()) {
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final jsonString = _prefsService.getString(_themeSettingsKey);
      if (jsonString != null) {
        final json = Map<String, dynamic>.from(
          Uri.splitQueryString(jsonString),
        );
        state = ThemeSettings.fromJson(json);
        Logger.debug('主题设置已加载: $state');
      }
    } catch (e, stackTrace) {
      Logger.error('加载主题设置失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final json = state.toJson();
      final jsonString = Uri(queryParameters: json.map((k, v) => MapEntry(k, v.toString()))).query;
      await _prefsService.setString(_themeSettingsKey, jsonString);
      Logger.debug('主题设置已保存: $state');
    } catch (e, stackTrace) {
      Logger.error('保存主题设置失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _saveSettings();
    Logger.info('主题模式已设置: $mode');
  }

  /// 设置主色调
  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _saveSettings();
    Logger.info('主色调已设置: $color');
  }

  /// 设置字体大小
  Future<void> setFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveSettings();
    Logger.info('字体大小已设置: $fontSize');
  }

  /// 设置圆角半径
  Future<void> setBorderRadius(double borderRadius) async {
    state = state.copyWith(borderRadius: borderRadius);
    await _saveSettings();
    Logger.info('圆角半径已设置: $borderRadius');
  }

  /// 切换Material 3
  Future<void> toggleMaterial3() async {
    state = state.copyWith(useMaterial3: !state.useMaterial3);
    await _saveSettings();
    Logger.info('Material 3 已${state.useMaterial3 ? '启用' : '禁用'}');
  }

  /// 切换动画
  Future<void> toggleAnimations() async {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
    await _saveSettings();
    Logger.info('动画已${state.enableAnimations ? '启用' : '禁用'}');
  }

  /// 切换触觉反馈
  Future<void> toggleHapticFeedback() async {
    state = state.copyWith(enableHapticFeedback: !state.enableHapticFeedback);
    await _saveSettings();
    Logger.info('触觉反馈已${state.enableHapticFeedback ? '启用' : '禁用'}');
  }

  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    state = const ThemeSettings();
    await _saveSettings();
    Logger.info('主题设置已重置为默认值');
  }
}

/// 当前主题数据Provider
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeSettingsProvider);
  return AppTheme.getThemeData(
    primaryColor: settings.primaryColor,
    isDarkMode: _isDarkMode(ref, settings.mode),
    useMaterial3: settings.useMaterial3,
    fontFamily: settings.fontFamily,
    fontSize: settings.fontSize,
    borderRadius: settings.borderRadius,
  );
});

/// 当前是否为深色模式Provider
final isDarkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(themeSettingsProvider);
  return _isDarkMode(ref, settings.mode);
});

/// 判断是否为深色模式
bool _isDarkMode(ProviderRef ref, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      // 在实际应用中，这里应该根据系统主题来判断
      // 这里暂时返回false作为默认值
      return false;
  }
}