/// 应用常量定义
class AppConstants {
  // 应用基本信息
  static const String appName = '打卡习惯';
  static const String appNameEn = 'DakaHabit';
  static const String appDescription = '一款可爱风格的日常习惯打卡应用';
  static const String appVersion = '1.0.0';
  
  // 开发者信息
  static const String developerName = 'DakaHabit Team';
  static const String developerEmail = 'contact@dakahabit.com';
  static const String supportEmail = 'support@dakahabit.com';
  
  // 应用链接
  static const String appStoreUrl = 'https://apps.apple.com/app/dakahabit';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.dakahabit.app';
  static const String harmonyStoreUrl = 'https://appgallery.huawei.com/app/dakahabit';
  static const String websiteUrl = 'https://dakahabit.com';
  static const String privacyPolicyUrl = 'https://dakahabit.com/privacy';
  static const String termsOfServiceUrl = 'https://dakahabit.com/terms';
  
  // UI配置
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 1.4;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // 布局配置
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;
  
  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;
  
  // 响应式断点
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // 列表配置
  static const double listItemHeight = 72.0;
  static const double compactListItemHeight = 56.0;
  static const double expandedListItemHeight = 88.0;
  
  // 图片配置
  static const double avatarSize = 40.0;
  static const double smallAvatarSize = 32.0;
  static const double largeAvatarSize = 64.0;
  
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;
  
  // 按钮配置
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  static const double largeButtonHeight = 56.0;
  
  static const double fabSize = 56.0;
  static const double miniFabSize = 40.0;
  
  // 输入框配置
  static const double textFieldHeight = 48.0;
  static const double multiLineTextFieldMinHeight = 80.0;
  
  // 导航配置
  static const double bottomNavBarHeight = 80.0;
  static const double appBarHeight = 56.0;
  
  // 卡片配置
  static const double cardMinHeight = 80.0;
  static const double cardMaxWidth = 600.0;
  
  // 间距配置
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  static const double hugeSpacing = 48.0;
  
  // 数据配置
  static const int maxHabitNameLength = 30;
  static const int maxHabitDescriptionLength = 200;
  static const int maxJournalTitleLength = 50;
  static const int maxJournalContentLength = 5000;
  static const int maxNoteLength = 500;
  
  static const int maxPhotosPerRecord = 9;
  static const int maxAudioDurationMinutes = 10;
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 缓存配置
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);
  
  static const int maxCacheItems = 1000;
  static const int maxImageCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 网络配置
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration shortNetworkTimeout = Duration(seconds: 10);
  static const Duration longNetworkTimeout = Duration(minutes: 2);
  
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // 数据库配置
  static const String databaseName = 'dakahabit.db';
  static const int databaseVersion = 1;
  static const int maxDatabaseConnections = 1;
  
  // 文件配置
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024;  // 5MB
  static const int maxAudioSize = 20 * 1024 * 1024; // 20MB
  
  static const List<String> supportedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
  ];
  
  static const List<String> supportedAudioTypes = [
    'mp3', 'wav', 'm4a', 'aac', 'ogg'
  ];
  
  // 通知配置
  static const String habitReminderChannelId = 'habit_reminders';
  static const String achievementChannelId = 'achievements';
  static const String systemChannelId = 'system_notifications';
  
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;
  
  // 统计配置
  static const int maxStatisticsDays = 365;
  static const int defaultStatisticsDays = 30;
  static const int weekDays = 7;
  static const int monthDays = 30;
  static const int yearDays = 365;
  
  // 习惯配置
  static const int minHabitDurationMinutes = 1;
  static const int maxHabitDurationMinutes = 1440; // 24小时
  static const int defaultHabitDurationMinutes = 30;
  
  static const int minTargetDays = 1;
  static const int maxTargetDays = 365;
  static const int defaultTargetDays = 30;
  
  static const int minImportance = 1;
  static const int maxImportance = 5;
  static const int defaultImportance = 3;
  
  static const int maxConcurrentHabits = 20;
  static const int maxActiveHabits = 10;
  
  // 打卡配置
  static const int maxCheckinsPerDay = 50;
  static const Duration checkInTimeBuffer = Duration(hours: 1);
  static const Duration makeupCheckInWindow = Duration(days: 7);
  
  static const int minQualityScore = 1;
  static const int maxQualityScore = 5;
  static const int defaultQualityScore = 3;
  
  // 成就配置
  static const int maxEarnedAchievements = 1000;
  static const List<int> streakMilestones = [3, 7, 15, 30, 60, 100, 200, 365];
  static const List<int> totalMilestones = [10, 50, 100, 200, 500, 1000];
  
  // 日志配置
  static const int maxJournalsPerDay = 10;
  static const int maxHabitJournalRelations = 100;
  
  // 导出配置
  static const List<String> supportedExportFormats = ['json', 'csv'];
  static const String defaultExportFormat = 'json';
  static const int maxExportRecords = 10000;
  
  // 搜索配置
  static const int minSearchLength = 2;
  static const int maxSearchResults = 100;
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  
  // 安全配置
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // 调试配置
  static const bool enableDebugLogs = true;
  static const bool enablePerformanceLogs = false;
  static const bool enableNetworkLogs = true;
  
  // 错误配置
  static const String defaultErrorMessage = '发生了未知错误';
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String permissionErrorMessage = '权限不足，请授予必要权限';
  
  // 成功消息
  static const String defaultSuccessMessage = '操作成功';
  static const String saveSuccessMessage = '保存成功';
  static const String deleteSuccessMessage = '删除成功';
  static const String updateSuccessMessage = '更新成功';
  
  // 确认消息
  static const String defaultConfirmMessage = '确定要执行此操作吗？';
  static const String deleteConfirmMessage = '确定要删除吗？删除后无法恢复';
  static const String clearDataConfirmMessage = '确定要清除所有数据吗？此操作无法撤销';
  
  // 正则表达式
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^1[3-9]\d{9}$'
  );
  
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$'
  );
  
  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'M月d日';
  static const String displayTimeFormat = 'HH:mm';
  static const String displayDateTimeFormat = 'M月d日 HH:mm';
  
  // 本地化相关
  static const String defaultLocale = 'zh_CN';
  static const List<String> supportedLocales = ['zh_CN', 'en_US'];
  
  // 主题相关
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
}