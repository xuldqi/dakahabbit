# 技术架构文档 - 打卡习惯 (DakaHabit)

## 1. 架构概览

### 1.1 整体架构
```
┌─────────────────────────────────────────────┐
│                 Presentation Layer          │
│  ┌─────────────┐ ┌─────────────┐ ┌────────┐ │
│  │    Pages    │ │   Widgets   │ │ Themes │ │
│  └─────────────┘ └─────────────┘ └────────┘ │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                Business Layer               │
│  ┌─────────────┐ ┌─────────────┐ ┌────────┐ │
│  │ Providers   │ │  Services   │ │ Models │ │
│  └─────────────┘ └─────────────┘ └────────┘ │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│                  Data Layer                 │
│  ┌─────────────┐ ┌─────────────┐ ┌────────┐ │
│  │ Repository  │ │  Database   │ │  APIs  │ │
│  └─────────────┘ └─────────────┘ └────────┘ │
└─────────────────────────────────────────────┘
```

### 1.2 技术选型

#### 前端框架
- **Flutter SDK**: 3.16.0+
- **Dart**: 3.2.0+
- **Material Design**: Material 3

#### 状态管理
- **Provider**: 主要状态管理方案
- **ChangeNotifier**: 状态通知机制
- **SharedPreferences**: 简单配置存储

#### 数据层
- **sqflite**: SQLite数据库
- **path_provider**: 文件路径获取
- **json_annotation**: JSON序列化

#### 导航路由
- **go_router**: 声明式路由管理
- **路由守卫**: 权限和状态检查

#### UI组件库
- **flutter/material.dart**: Material组件
- **flutter/cupertino.dart**: iOS风格组件
- **自定义组件**: 可爱风格组件

#### 工具库
- **intl**: 国际化和日期格式化
- **flutter_local_notifications**: 本地通知
- **image_picker**: 图片选择
- **path**: 路径操作
- **uuid**: 唯一标识符生成

#### 图表和可视化
- **fl_chart**: 图表绘制
- **自定义Canvas**: 特殊图形绘制

#### 开发工具
- **json_serializable**: 代码生成
- **build_runner**: 构建工具
- **flutter_test**: 单元测试
- **integration_test**: 集成测试

## 2. 项目结构

### 2.1 目录结构
```
lib/
├── main.dart                           # 应用入口
├── app/
│   ├── app.dart                       # 应用配置
│   ├── routes/                        # 路由配置
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   └── themes/                        # 主题配置
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
├── core/                              # 核心功能
│   ├── constants/                     # 常量定义
│   │   ├── app_constants.dart
│   │   └── database_constants.dart
│   ├── utils/                         # 工具类
│   │   ├── date_utils.dart
│   │   ├── string_utils.dart
│   │   └── validation_utils.dart
│   ├── extensions/                    # 扩展方法
│   │   ├── datetime_extension.dart
│   │   └── string_extension.dart
│   └── errors/                        # 错误处理
│       ├── app_exceptions.dart
│       └── error_handler.dart
├── data/                              # 数据层
│   ├── models/                        # 数据模型
│   │   ├── habit.dart
│   │   ├── check_in.dart
│   │   ├── journal.dart
│   │   └── user_settings.dart
│   ├── repositories/                  # 数据仓库
│   │   ├── habit_repository.dart
│   │   ├── checkin_repository.dart
│   │   ├── journal_repository.dart
│   │   └── settings_repository.dart
│   ├── datasources/                   # 数据源
│   │   ├── local/
│   │   │   ├── database_helper.dart
│   │   │   └── shared_prefs_helper.dart
│   │   └── remote/ (未来扩展)
│   └── database/                      # 数据库相关
│       ├── app_database.dart
│       ├── database_migrations.dart
│       └── dao/                       # 数据访问对象
│           ├── habit_dao.dart
│           ├── checkin_dao.dart
│           └── journal_dao.dart
├── presentation/                      # 表现层
│   ├── pages/                         # 页面
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   ├── habits/
│   │   │   ├── habits_page.dart
│   │   │   ├── habit_detail_page.dart
│   │   │   ├── create_habit_page.dart
│   │   │   └── widgets/
│   │   ├── statistics/
│   │   │   ├── statistics_page.dart
│   │   │   └── widgets/
│   │   ├── journals/
│   │   │   ├── journals_page.dart
│   │   │   ├── journal_detail_page.dart
│   │   │   ├── create_journal_page.dart
│   │   │   └── widgets/
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       └── widgets/
│   ├── widgets/                       # 通用组件
│   │   ├── common/
│   │   │   ├── app_bar.dart
│   │   │   ├── bottom_nav_bar.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── empty_widget.dart
│   │   ├── habit/
│   │   │   ├── habit_card.dart
│   │   │   ├── habit_list_item.dart
│   │   │   └── checkin_button.dart
│   │   ├── chart/
│   │   │   ├── progress_chart.dart
│   │   │   ├── calendar_heatmap.dart
│   │   │   └── trend_chart.dart
│   │   └── form/
│   │       ├── custom_text_field.dart
│   │       ├── time_picker.dart
│   │       └── icon_selector.dart
│   └── providers/                     # 状态管理
│       ├── habit_provider.dart
│       ├── checkin_provider.dart
│       ├── journal_provider.dart
│       ├── statistics_provider.dart
│       ├── theme_provider.dart
│       └── settings_provider.dart
├── business/                          # 业务逻辑层
│   ├── services/                      # 业务服务
│   │   ├── habit_service.dart
│   │   ├── checkin_service.dart
│   │   ├── journal_service.dart
│   │   ├── statistics_service.dart
│   │   ├── notification_service.dart
│   │   └── backup_service.dart
│   ├── usecases/                      # 用例
│   │   ├── habit_usecases.dart
│   │   ├── checkin_usecases.dart
│   │   └── statistics_usecases.dart
│   └── validators/                    # 数据验证
│       ├── habit_validator.dart
│       └── journal_validator.dart
└── generated/                         # 生成的代码
    ├── intl/                         # 国际化文件
    └── json/                         # JSON序列化代码

assets/
├── images/                           # 图片资源
│   ├── icons/                       # 习惯图标
│   ├── illustrations/               # 插图
│   └── achievements/                # 成就徽章
├── fonts/                           # 字体文件
└── data/                            # 静态数据
    └── habit_templates.json         # 习惯模板

test/
├── unit/                            # 单元测试
├── widget/                          # Widget测试
└── integration/                     # 集成测试
```

## 3. 核心模块设计

### 3.1 数据模型层 (Models)

#### Habit Model
```dart
@JsonSerializable()
class Habit {
  final int? id;
  final String name;
  final String? description;
  final String icon;
  final HabitCategory category;
  final int importance;
  final HabitDifficulty difficulty;
  
  // 时间设置
  final HabitCycleType cycleType;
  final Map<String, dynamic>? cycleConfig;
  final TimeOfDay? timeRangeStart;
  final TimeOfDay? timeRangeEnd;
  final int? durationMinutes;
  
  // 目标设置
  final int? targetDays;
  final int? targetTotal;
  
  // 状态
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  
  // 提醒设置
  final bool reminderEnabled;
  final List<TimeOfDay> reminderTimes;
  
  // 统计数据
  final int totalCheckins;
  final int streakCount;
  final int maxStreak;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Habit({...});
  
  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);
}
```

#### CheckIn Model
```dart
@JsonSerializable()
class CheckIn {
  final int? id;
  final int habitId;
  final DateTime checkDate;
  final TimeOfDay checkTime;
  final CheckInStatus status;
  
  // 详细信息
  final String? note;
  final Mood? mood;
  final int? qualityScore;
  final int? durationMinutes;
  
  // 媒体
  final List<String> photos;
  
  // 补卡信息
  final bool isMakeup;
  final DateTime? makeupOriginalDate;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  CheckIn({...});
  
  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
  Map<String, dynamic> toJson() => _$CheckInToJson(this);
}
```

### 3.2 仓库层 (Repository)

#### Habit Repository
```dart
abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<List<Habit>> getActiveHabits();
  Future<Habit?> getHabitById(int id);
  Future<int> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);
  Future<List<Habit>> getHabitsForDate(DateTime date);
  Future<List<Habit>> searchHabits(String query);
}

class HabitRepositoryImpl implements HabitRepository {
  final HabitDao _habitDao;
  
  HabitRepositoryImpl(this._habitDao);
  
  @override
  Future<List<Habit>> getAllHabits() async {
    final habitsData = await _habitDao.getAllHabits();
    return habitsData.map((data) => Habit.fromJson(data)).toList();
  }
  
  // 其他方法实现...
}
```

### 3.3 服务层 (Services)

#### Habit Service
```dart
class HabitService {
  final HabitRepository _habitRepository;
  final CheckInRepository _checkInRepository;
  final NotificationService _notificationService;
  
  HabitService(this._habitRepository, this._checkInRepository, this._notificationService);
  
  Future<List<Habit>> getTodayHabits() async {
    final today = DateTime.now();
    return await _habitRepository.getHabitsForDate(today);
  }
  
  Future<bool> checkInHabit(int habitId, {
    String? note,
    Mood? mood,
    int? qualityScore,
    List<String>? photos,
  }) async {
    // 检查是否已经打卡
    final existingCheckIn = await _checkInRepository.getCheckInByHabitAndDate(
      habitId, 
      DateTime.now()
    );
    
    if (existingCheckIn != null) {
      throw HabitAlreadyCheckedInException();
    }
    
    // 创建打卡记录
    final checkIn = CheckIn(
      habitId: habitId,
      checkDate: DateTime.now(),
      checkTime: TimeOfDay.now(),
      status: CheckInStatus.completed,
      note: note,
      mood: mood,
      qualityScore: qualityScore,
      photos: photos ?? [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _checkInRepository.createCheckIn(checkIn);
    
    // 更新习惯统计
    await _updateHabitStats(habitId);
    
    return true;
  }
  
  Future<void> _updateHabitStats(int habitId) async {
    // 计算连续打卡天数
    final streak = await _calculateStreak(habitId);
    
    // 更新习惯统计数据
    final habit = await _habitRepository.getHabitById(habitId);
    if (habit != null) {
      final updatedHabit = habit.copyWith(
        totalCheckins: habit.totalCheckins + 1,
        streakCount: streak.current,
        maxStreak: math.max(habit.maxStreak, streak.current),
        updatedAt: DateTime.now(),
      );
      await _habitRepository.updateHabit(updatedHabit);
    }
  }
}
```

### 3.4 状态管理层 (Providers)

#### Habit Provider
```dart
class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;
  
  List<Habit> _habits = [];
  List<Habit> _todayHabits = [];
  bool _isLoading = false;
  String? _error;
  
  HabitProvider(this._habitService);
  
  // Getters
  List<Habit> get habits => _habits;
  List<Habit> get todayHabits => _todayHabits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 加载所有习惯
  Future<void> loadHabits() async {
    _setLoading(true);
    try {
      _habits = await _habitService.getAllHabits();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载今日习惯
  Future<void> loadTodayHabits() async {
    try {
      _todayHabits = await _habitService.getTodayHabits();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // 打卡
  Future<bool> checkInHabit(int habitId, {
    String? note,
    Mood? mood,
    int? qualityScore,
    List<String>? photos,
  }) async {
    try {
      final success = await _habitService.checkInHabit(
        habitId,
        note: note,
        mood: mood,
        qualityScore: qualityScore,
        photos: photos,
      );
      
      if (success) {
        // 重新加载今日习惯以更新状态
        await loadTodayHabits();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

## 4. 路由配置

### 4.1 路由定义
```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 底部导航路由
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/habits',
          name: RouteNames.habits,
          builder: (context, state) => const HabitsPage(),
        ),
        GoRoute(
          path: '/statistics',
          name: RouteNames.statistics,
          builder: (context, state) => const StatisticsPage(),
        ),
        GoRoute(
          path: '/journals',
          name: RouteNames.journals,
          builder: (context, state) => const JournalsPage(),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    
    // 详情页面路由
    GoRoute(
      path: '/habit/:id',
      name: RouteNames.habitDetail,
      builder: (context, state) => HabitDetailPage(
        habitId: int.parse(state.pathParameters['id']!),
      ),
    ),
    
    GoRoute(
      path: '/habit/create',
      name: RouteNames.createHabit,
      builder: (context, state) => const CreateHabitPage(),
    ),
    
    GoRoute(
      path: '/journal/:id',
      name: RouteNames.journalDetail,
      builder: (context, state) => JournalDetailPage(
        journalId: int.parse(state.pathParameters['id']!),
      ),
    ),
    
    GoRoute(
      path: '/journal/create',
      name: RouteNames.createJournal,
      builder: (context, state) => const CreateJournalPage(),
    ),
  ],
);
```

## 5. 依赖注入

### 5.1 服务定位器模式
```dart
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static Future<void> setup() async {
    // 数据库
    _getIt.registerSingletonAsync<AppDatabase>(
      () => AppDatabase.create(),
    );
    await _getIt.isReady<AppDatabase>();
    
    // DAOs
    _getIt.registerLazySingleton<HabitDao>(
      () => HabitDao(_getIt<AppDatabase>()),
    );
    _getIt.registerLazySingleton<CheckInDao>(
      () => CheckInDao(_getIt<AppDatabase>()),
    );
    
    // Repositories
    _getIt.registerLazySingleton<HabitRepository>(
      () => HabitRepositoryImpl(_getIt<HabitDao>()),
    );
    _getIt.registerLazySingleton<CheckInRepository>(
      () => CheckInRepositoryImpl(_getIt<CheckInDao>()),
    );
    
    // Services
    _getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );
    _getIt.registerLazySingleton<HabitService>(
      () => HabitService(
        _getIt<HabitRepository>(),
        _getIt<CheckInRepository>(),
        _getIt<NotificationService>(),
      ),
    );
    
    // Providers
    _getIt.registerLazySingleton<HabitProvider>(
      () => HabitProvider(_getIt<HabitService>()),
    );
  }
  
  static T get<T extends Object>() => _getIt.get<T>();
}
```

## 6. 错误处理

### 6.1 异常定义
```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
}

class DatabaseException extends AppException {
  DatabaseException(String message) : super(message, code: 'DATABASE_ERROR');
}

class HabitAlreadyCheckedInException extends AppException {
  HabitAlreadyCheckedInException() 
    : super('今天已经打过卡了', code: 'ALREADY_CHECKED_IN');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}
```

### 6.2 全局错误处理器
```dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    if (error is AppException) {
      _handleAppException(error);
    } else if (error is SqliteException) {
      _handleDatabaseError(error);
    } else {
      _handleUnknownError(error, stackTrace);
    }
  }
  
  static void _handleAppException(AppException exception) {
    // 显示用户友好的错误信息
    SnackBarService.showError(exception.message);
  }
  
  static void _handleDatabaseError(SqliteException error) {
    // 记录数据库错误并显示通用错误信息
    Logger.error('Database error: ${error.toString()}');
    SnackBarService.showError('数据操作失败，请稍后重试');
  }
  
  static void _handleUnknownError(dynamic error, StackTrace stackTrace) {
    // 记录未知错误
    Logger.error('Unknown error: ${error.toString()}', stackTrace);
    SnackBarService.showError('发生未知错误，请稍后重试');
  }
}
```

## 7. 性能优化

### 7.1 懒加载策略
- 页面数据按需加载
- 图片懒加载
- 列表虚拟化

### 7.2 缓存策略
- 内存缓存热点数据
- 磁盘缓存图片资源
- 数据库查询结果缓存

### 7.3 构建优化
- 代码分割
- Tree Shaking
- 资源压缩
- 构建缓存

## 8. 测试策略

### 8.1 单元测试
- 业务逻辑测试
- 工具类测试
- 模型类测试

### 8.2 Widget测试
- UI组件测试
- 交互测试
- 状态变化测试

### 8.3 集成测试
- 端到端流程测试
- 数据库操作测试
- 页面导航测试

这个技术架构为打卡习惯应用提供了清晰的代码组织结构和开发指导，确保代码的可维护性、可测试性和可扩展性。