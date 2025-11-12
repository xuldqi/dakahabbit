import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/service_locator.dart';
import '../services/database_service.dart';
import '../services/shared_preferences_service.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// 核心服务Provider
/// 提供应用核心服务的访问入口

/// 数据库服务Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return ServiceLocator.get<DatabaseService>();
});

/// SharedPreferences服务Provider
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((ref) {
  return ServiceLocator.get<SharedPreferencesService>();
});

/// 通知服务Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return ServiceLocator.get<NotificationService>();
});

/// 应用初始化状态Provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    Logger.info('开始应用初始化...');
    
    // 如果服务定位器未初始化，先初始化
    if (!ServiceLocator.isInitialized) {
      await ServiceLocator.initialize();
    }
    
    Logger.info('应用初始化完成');
    return true;
  } catch (e, stackTrace) {
    Logger.error('应用初始化失败', error: e, stackTrace: stackTrace);
    rethrow;
  }
});

/// 应用状态Provider
/// 管理应用的全局状态
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// 应用状态
enum AppLifecycleStatus {
  /// 应用启动中
  starting,
  /// 应用正在运行
  running,
  /// 应用正在停止
  stopping,
  /// 应用已停止
  stopped,
}

/// 应用状态数据
class AppState {
  const AppState({
    this.lifecycleStatus = AppLifecycleStatus.starting,
    this.isInitialized = false,
    this.hasError = false,
    this.errorMessage,
    this.lastUpdateTime,
  });

  /// 生命周期状态
  final AppLifecycleStatus lifecycleStatus;
  
  /// 是否已初始化
  final bool isInitialized;
  
  /// 是否有错误
  final bool hasError;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 最后更新时间
  final DateTime? lastUpdateTime;

  /// 复制状态
  AppState copyWith({
    AppLifecycleStatus? lifecycleStatus,
    bool? isInitialized,
    bool? hasError,
    String? errorMessage,
    DateTime? lastUpdateTime,
  }) {
    return AppState(
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      isInitialized: isInitialized ?? this.isInitialized,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  @override
  String toString() {
    return 'AppState('
           'lifecycleStatus: $lifecycleStatus, '
           'isInitialized: $isInitialized, '
           'hasError: $hasError, '
           'errorMessage: $errorMessage, '
           'lastUpdateTime: $lastUpdateTime'
           ')';
  }
}

/// 应用状态通知器
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    Logger.debug('AppStateNotifier 已创建');
  }

  /// 设置应用启动中
  void setStarting() {
    Logger.info('设置应用状态: 启动中');
    state = state.copyWith(
      lifecycleStatus: AppLifecycleStatus.starting,
      hasError: false,
      errorMessage: null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 设置应用运行中
  void setRunning() {
    Logger.info('设置应用状态: 运行中');
    state = state.copyWith(
      lifecycleStatus: AppLifecycleStatus.running,
      isInitialized: true,
      hasError: false,
      errorMessage: null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 设置应用停止中
  void setStopping() {
    Logger.info('设置应用状态: 停止中');
    state = state.copyWith(
      lifecycleStatus: AppLifecycleStatus.stopping,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 设置应用已停止
  void setStopped() {
    Logger.info('设置应用状态: 已停止');
    state = state.copyWith(
      lifecycleStatus: AppLifecycleStatus.stopped,
      isInitialized: false,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 设置错误状态
  void setError(String errorMessage) {
    Logger.error('设置应用错误状态: $errorMessage');
    state = state.copyWith(
      hasError: true,
      errorMessage: errorMessage,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 清除错误状态
  void clearError() {
    Logger.info('清除应用错误状态');
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 刷新状态
  void refresh() {
    Logger.debug('刷新应用状态');
    state = state.copyWith(
      lastUpdateTime: DateTime.now(),
    );
  }
}