import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

/// 主题类型
enum ThemeType {
  @JsonValue('light')
  light,
  @JsonValue('dark')
  dark,
  @JsonValue('system')
  system,
}

/// 语言类型
enum LanguageType {
  @JsonValue('zh_CN')
  zhCN,
  @JsonValue('en_US')
  enUS,
  @JsonValue('ja_JP')
  jaJP,
}

/// 一周第一天
enum FirstDayOfWeek {
  @JsonValue(0)
  sunday,
  @JsonValue(1)
  monday,
}

/// 通知设置
@JsonSerializable()
class NotificationSettings {
  final bool enabled;                     // 是否启用通知
  final bool soundEnabled;                // 是否启用声音
  final bool vibrationEnabled;            // 是否启用震动
  final String defaultReminderTime;       // 默认提醒时间 (HH:mm)
  final List<String> quietHours;          // 免打扰时间段 ["22:00", "08:00"]
  final bool weekendEnabled;              // 周末是否启用通知
  final Map<String, bool> categorySettings; // 分类通知设置
  
  const NotificationSettings({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.defaultReminderTime = '09:00',
    this.quietHours = const [],
    this.weekendEnabled = true,
    this.categorySettings = const {},
  });
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);
  
  /// 默认通知设置
  factory NotificationSettings.defaultSettings() => const NotificationSettings();
  
  /// 复制并更新设置
  NotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? defaultReminderTime,
    List<String>? quietHours,
    bool? weekendEnabled,
    Map<String, bool>? categorySettings,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      quietHours: quietHours ?? this.quietHours,
      weekendEnabled: weekendEnabled ?? this.weekendEnabled,
      categorySettings: categorySettings ?? this.categorySettings,
    );
  }
  
  /// 是否在免打扰时间内
  bool isInQuietHours(DateTime time) {
    if (quietHours.length < 2) return false;
    
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final startTime = quietHours[0];
    final endTime = quietHours[1];
    
    // 如果结束时间小于开始时间，说明跨越了午夜
    if (endTime.compareTo(startTime) < 0) {
      return timeStr.compareTo(startTime) >= 0 || timeStr.compareTo(endTime) < 0;
    } else {
      return timeStr.compareTo(startTime) >= 0 && timeStr.compareTo(endTime) < 0;
    }
  }
}

/// 备份设置
@JsonSerializable()
class BackupSettings {
  final bool autoBackupEnabled;           // 是否启用自动备份
  final int autoBackupInterval;           // 自动备份间隔（天）
  final String? lastBackupTime;          // 最后备份时间
  final bool cloudBackupEnabled;          // 是否启用云备份
  final String? cloudProvider;           // 云服务提供商
  final int maxBackupCount;              // 最大备份数量
  final bool compressBackup;             // 是否压缩备份文件
  
  const BackupSettings({
    this.autoBackupEnabled = true,
    this.autoBackupInterval = 7,
    this.lastBackupTime,
    this.cloudBackupEnabled = false,
    this.cloudProvider,
    this.maxBackupCount = 10,
    this.compressBackup = true,
  });
  
  factory BackupSettings.fromJson(Map<String, dynamic> json) => _$BackupSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BackupSettingsToJson(this);
  
  /// 默认备份设置
  factory BackupSettings.defaultSettings() => const BackupSettings();
  
  /// 复制并更新设置
  BackupSettings copyWith({
    bool? autoBackupEnabled,
    int? autoBackupInterval,
    String? lastBackupTime,
    bool? cloudBackupEnabled,
    String? cloudProvider,
    int? maxBackupCount,
    bool? compressBackup,
  }) {
    return BackupSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupInterval: autoBackupInterval ?? this.autoBackupInterval,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      cloudProvider: cloudProvider ?? this.cloudProvider,
      maxBackupCount: maxBackupCount ?? this.maxBackupCount,
      compressBackup: compressBackup ?? this.compressBackup,
    );
  }
  
  /// 是否需要备份
  bool get needsBackup {
    if (!autoBackupEnabled) return false;
    if (lastBackupTime == null) return true;
    
    final lastBackup = DateTime.tryParse(lastBackupTime!);
    if (lastBackup == null) return true;
    
    final daysSinceBackup = DateTime.now().difference(lastBackup).inDays;
    return daysSinceBackup >= autoBackupInterval;
  }
}

/// 隐私设置
@JsonSerializable()
class PrivacySettings {
  final bool analyticsEnabled;            // 是否启用分析
  final bool crashReportingEnabled;       // 是否启用崩溃报告
  final bool usageStatsEnabled;          // 是否启用使用统计
  final bool locationTrackingEnabled;     // 是否启用位置跟踪
  final bool biometricAuthEnabled;        // 是否启用生物识别认证
  final String? passcode;                // 应用密码
  final int autoLockTimeout;             // 自动锁定超时（分钟）
  
  const PrivacySettings({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.usageStatsEnabled = true,
    this.locationTrackingEnabled = false,
    this.biometricAuthEnabled = false,
    this.passcode,
    this.autoLockTimeout = 5,
  });
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);
  
  /// 默认隐私设置
  factory PrivacySettings.defaultSettings() => const PrivacySettings();
  
  /// 复制并更新设置
  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? usageStatsEnabled,
    bool? locationTrackingEnabled,
    bool? biometricAuthEnabled,
    String? passcode,
    int? autoLockTimeout,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      usageStatsEnabled: usageStatsEnabled ?? this.usageStatsEnabled,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      passcode: passcode ?? this.passcode,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    );
  }
  
  /// 是否启用了应用锁
  bool get isAppLockEnabled => biometricAuthEnabled || passcode != null;
}

/// 用户设置模型
@JsonSerializable()
class UserSettings {
  // 基本设置
  final ThemeType theme;
  final LanguageType language;
  final FirstDayOfWeek firstDayOfWeek;
  final String dateFormat;               // 日期格式
  final String timeFormat;               // 时间格式 (12h/24h)
  
  // 通知设置
  final NotificationSettings notificationSettings;
  
  // 备份设置
  final BackupSettings backupSettings;
  
  // 隐私设置
  final PrivacySettings privacySettings;
  
  // 显示设置
  final bool showCompletedHabits;         // 是否显示已完成的习惯
  final bool showHabitStats;             // 是否显示习惯统计
  final int maxRecentJournals;           // 最大显示的最近日志数量
  final bool showWeekendInCalendar;      // 日历是否显示周末
  final bool enableHapticFeedback;       // 是否启用触觉反馈
  
  // 行为设置
  final bool autoAddTodayHabits;         // 是否自动添加今日习惯到日志
  final bool askBeforeDelete;            // 删除前是否确认
  final bool enableQuickCheckin;         // 是否启用快速打卡
  final int streakResetHours;           // 连击重置时间（小时）
  
  // 扩展设置
  final Map<String, dynamic> customSettings;
  
  // 时间戳
  final DateTime updatedAt;
  
  const UserSettings({
    this.theme = ThemeType.system,
    this.language = LanguageType.zhCN,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
    this.dateFormat = 'yyyy-MM-dd',
    this.timeFormat = '24h',
    required this.notificationSettings,
    required this.backupSettings,
    required this.privacySettings,
    this.showCompletedHabits = true,
    this.showHabitStats = true,
    this.maxRecentJournals = 10,
    this.showWeekendInCalendar = true,
    this.enableHapticFeedback = true,
    this.autoAddTodayHabits = false,
    this.askBeforeDelete = true,
    this.enableQuickCheckin = true,
    this.streakResetHours = 6,
    this.customSettings = const {},
    required this.updatedAt,
  });
  
  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
  
  /// 创建默认设置
  factory UserSettings.defaultSettings() {
    final now = DateTime.now();
    return UserSettings(
      notificationSettings: NotificationSettings.defaultSettings(),
      backupSettings: BackupSettings.defaultSettings(),
      privacySettings: PrivacySettings.defaultSettings(),
      updatedAt: now,
    );
  }
  
  /// 复制并更新设置
  UserSettings copyWith({
    ThemeType? theme,
    LanguageType? language,
    FirstDayOfWeek? firstDayOfWeek,
    String? dateFormat,
    String? timeFormat,
    NotificationSettings? notificationSettings,
    BackupSettings? backupSettings,
    PrivacySettings? privacySettings,
    bool? showCompletedHabits,
    bool? showHabitStats,
    int? maxRecentJournals,
    bool? showWeekendInCalendar,
    bool? enableHapticFeedback,
    bool? autoAddTodayHabits,
    bool? askBeforeDelete,
    bool? enableQuickCheckin,
    int? streakResetHours,
    Map<String, dynamic>? customSettings,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      backupSettings: backupSettings ?? this.backupSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      showCompletedHabits: showCompletedHabits ?? this.showCompletedHabits,
      showHabitStats: showHabitStats ?? this.showHabitStats,
      maxRecentJournals: maxRecentJournals ?? this.maxRecentJournals,
      showWeekendInCalendar: showWeekendInCalendar ?? this.showWeekendInCalendar,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      autoAddTodayHabits: autoAddTodayHabits ?? this.autoAddTodayHabits,
      askBeforeDelete: askBeforeDelete ?? this.askBeforeDelete,
      enableQuickCheckin: enableQuickCheckin ?? this.enableQuickCheckin,
      streakResetHours: streakResetHours ?? this.streakResetHours,
      customSettings: customSettings ?? this.customSettings,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 获取主题描述
  String get themeText {
    switch (theme) {
      case ThemeType.light:
        return '浅色模式';
      case ThemeType.dark:
        return '深色模式';
      case ThemeType.system:
        return '跟随系统';
    }
  }
  
  /// 获取语言描述
  String get languageText {
    switch (language) {
      case LanguageType.zhCN:
        return '中文（简体）';
      case LanguageType.enUS:
        return 'English';
      case LanguageType.jaJP:
        return '日本語';
    }
  }
  
  /// 获取一周第一天描述
  String get firstDayOfWeekText {
    switch (firstDayOfWeek) {
      case FirstDayOfWeek.sunday:
        return '周日';
      case FirstDayOfWeek.monday:
        return '周一';
    }
  }
  
  /// 是否使用12小时制
  bool get is12HourFormat => timeFormat == '12h';
  
  /// 是否使用24小时制
  bool get is24HourFormat => timeFormat == '24h';
  
  /// 获取自定义设置值
  T? getCustomSetting<T>(String key) {
    return customSettings[key] as T?;
  }
  
  /// 设置自定义设置值
  UserSettings setCustomSetting<T>(String key, T value) {
    final newCustomSettings = Map<String, dynamic>.from(customSettings);
    newCustomSettings[key] = value;
    return copyWith(customSettings: newCustomSettings);
  }
  
  /// 移除自定义设置
  UserSettings removeCustomSetting(String key) {
    final newCustomSettings = Map<String, dynamic>.from(customSettings);
    newCustomSettings.remove(key);
    return copyWith(customSettings: newCustomSettings);
  }
  
  /// 是否应该在指定时间重置连击
  bool shouldResetStreakAt(DateTime checkTime, DateTime lastCheckTime) {
    if (streakResetHours <= 0) return false;
    
    // 计算重置时间点
    final resetTime = DateTime(
      lastCheckTime.year,
      lastCheckTime.month,
      lastCheckTime.day + 1,
      streakResetHours,
    );
    
    return checkTime.isAfter(resetTime);
  }
  
  @override
  String toString() {
    return 'UserSettings{theme: $theme, language: $language, updatedAt: $updatedAt}';
  }
}