import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// 条件导入：仅在非 Web 平台导入 dart:io
import 'platform_stub.dart'
    if (dart.library.io) 'dart:io';

import '../utils/logger.dart';

/// 通知服务
/// 负责本地通知的管理和调度
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool _permissionGranted = false;
  
  /// 导航键，用于处理通知点击后的导航
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 是否有通知权限
  bool get permissionGranted => _permissionGranted;
  
  /// 设置导航键
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }
  
  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('正在初始化通知服务...');
      
      // Web 平台不支持本地通知
      if (kIsWeb) {
        Logger.info('Web 平台不支持本地通知，通知服务将不可用');
        _isInitialized = true;
        return;
      }
      
      // 初始化时区数据
      tz.initializeTimeZones();
      
      // 请求通知权限
      await _requestPermissions();
      
      // 初始化通知插件
      await _initializeNotifications();
      
      _isInitialized = true;
      Logger.info('通知服务初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('通知服务初始化失败', error: e, stackTrace: stackTrace);
      // Web 平台上不抛出异常，允许应用继续运行
      if (kIsWeb) {
        _isInitialized = true;
        Logger.info('Web 平台上通知服务初始化失败，但应用将继续运行');
        return;
      }
      rethrow;
    }
  }
  
  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // Web 平台不支持通知权限
    if (kIsWeb) {
      _permissionGranted = false;
      Logger.info('Web 平台不支持通知权限');
      return;
    }
    
    // 仅在非 Web 平台执行以下代码
    try {
      // 使用条件导入的 Platform
      if (Platform.isAndroid) {
        // Android权限请求
        final status = await Permission.notification.request();
        _permissionGranted = status == PermissionStatus.granted;
        
        if (!_permissionGranted) {
          Logger.warning('Android通知权限被拒绝');
        }
        
      } else if (Platform.isIOS) {
        // iOS权限请求
        final bool? result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        
        _permissionGranted = result ?? false;
        
        if (!_permissionGranted) {
          Logger.warning('iOS通知权限被拒绝');
        }
      }
      
      Logger.info('通知权限状态: $_permissionGranted');
    } catch (e, stackTrace) {
      Logger.error('请求通知权限失败', error: e, stackTrace: stackTrace);
      _permissionGranted = false;
    }
  }
  
  /// 初始化通知插件
  Future<void> _initializeNotifications() async {
    // Android初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS初始化设置
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // 总体初始化设置
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // 初始化插件
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }
  
  /// 处理通知点击事件
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    Logger.info('收到通知响应: ${response.payload}');
    
    // 这里可以处理通知点击后的导航逻辑
    // 例如：跳转到特定的习惯详情页面
    if (response.payload != null) {
      // 解析payload并导航
      _handleNotificationPayload(response.payload!);
    }
  }
  
  /// 处理通知载荷
  void _handleNotificationPayload(String payload) {
    try {
      // 解析payload并执行相应的操作
      Logger.debug('处理通知载荷: $payload');
      
      if (_navigatorKey?.currentState == null) {
        Logger.warning('导航器未设置或不可用，无法执行导航');
        return;
      }
      
      // 尝试解析JSON载荷
      Map<String, dynamic> payloadData;
      try {
        payloadData = jsonDecode(payload);
      } catch (e) {
        // 如果不是JSON格式，则作为简单字符串处理
        Logger.debug('载荷不是JSON格式，作为简单字符串处理: $payload');
        _handleSimplePayload(payload);
        return;
      }
      
      final String? type = payloadData['type'];
      if (type == null) {
        Logger.warning('通知载荷缺少type字段');
        return;
      }
      
      switch (type) {
        case 'habit_reminder':
          _navigateToHabitDetail(payloadData);
          break;
        case 'habit_checkin':
          _navigateToHabitCheckin(payloadData);
          break;
        case 'journal_reminder':
          _navigateToJournalCreate(payloadData);
          break;
        case 'achievement':
          _navigateToAchievements(payloadData);
          break;
        case 'statistics':
          _navigateToStatistics(payloadData);
          break;
        default:
          Logger.warning('未知的通知类型: $type');
          _navigateToHome();
      }
      
    } catch (e, stackTrace) {
      Logger.error('处理通知载荷失败', error: e, stackTrace: stackTrace);
      // 发生错误时，默认导航到首页
      _navigateToHome();
    }
  }
  
  /// 处理简单字符串载荷
  void _handleSimplePayload(String payload) {
    switch (payload) {
      case 'home':
        _navigateToHome();
        break;
      case 'habits':
        _navigateToHabits();
        break;
      case 'journals':
        _navigateToJournals();
        break;
      case 'statistics':
        _navigateToStatistics();
        break;
      default:
        Logger.debug('未知的简单载荷: $payload');
        _navigateToHome();
    }
  }
  
  /// 导航到习惯详情页
  void _navigateToHabitDetail(Map<String, dynamic> data) {
    final habitId = data['habit_id'];
    if (habitId != null) {
      Logger.info('导航到习惯详情页: $habitId');
      _navigatorKey!.currentState!.pushNamed(
        '/habit_detail',
        arguments: {'habitId': habitId},
      );
    } else {
      Logger.warning('习惯ID缺失，导航到习惯列表');
      _navigateToHabits();
    }
  }
  
  /// 导航到习惯打卡页
  void _navigateToHabitCheckin(Map<String, dynamic> data) {
    final habitId = data['habit_id'];
    if (habitId != null) {
      Logger.info('导航到习惯打卡页: $habitId');
      _navigatorKey!.currentState!.pushNamed(
        '/habit_checkin',
        arguments: {'habitId': habitId},
      );
    } else {
      Logger.warning('习惯ID缺失，导航到习惯列表');
      _navigateToHabits();
    }
  }
  
  /// 导航到创建日志页
  void _navigateToJournalCreate(Map<String, dynamic> data) {
    Logger.info('导航到创建日志页');
    _navigatorKey!.currentState!.pushNamed('/journal_create');
  }
  
  /// 导航到成就页面
  void _navigateToAchievements([Map<String, dynamic>? data]) {
    Logger.info('导航到成就页面');
    _navigatorKey!.currentState!.pushNamed('/achievements');
  }
  
  /// 导航到统计页面
  void _navigateToStatistics([Map<String, dynamic>? data]) {
    Logger.info('导航到统计页面');
    _navigatorKey!.currentState!.pushNamed('/statistics');
  }
  
  /// 导航到首页
  void _navigateToHome() {
    Logger.info('导航到首页');
    _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }
  
  /// 导航到习惯页面
  void _navigateToHabits() {
    Logger.info('导航到习惯页面');
    _navigatorKey!.currentState!.pushNamed('/habits');
  }
  
  /// 导航到日志页面
  void _navigateToJournals() {
    Logger.info('导航到日志页面');
    _navigatorKey!.currentState!.pushNamed('/journals');
  }
  
  /// 创建习惯提醒通知载荷
  String createHabitReminderPayload(int habitId) {
    return jsonEncode({
      'type': 'habit_reminder',
      'habit_id': habitId,
    });
  }
  
  /// 创建习惯打卡通知载荷
  String createHabitCheckinPayload(int habitId) {
    return jsonEncode({
      'type': 'habit_checkin',
      'habit_id': habitId,
    });
  }
  
  /// 创建日志提醒通知载荷
  String createJournalReminderPayload() {
    return jsonEncode({
      'type': 'journal_reminder',
    });
  }
  
  /// 创建成就通知载荷
  String createAchievementPayload(int achievementId) {
    return jsonEncode({
      'type': 'achievement',
      'achievement_id': achievementId,
    });
  }
  
  /// 显示习惯提醒通知
  Future<void> showHabitReminderNotification({
    required int id,
    required String habitName,
    required int habitId,
    String? customMessage,
  }) async {
    final payload = createHabitReminderPayload(habitId);
    
    await showNotification(
      id: id,
      title: '习惯提醒',
      body: customMessage ?? '该打卡「$habitName」了！',
      payload: payload,
    );
  }
  
  /// 调度习惯提醒通知
  Future<void> scheduleHabitReminderNotification({
    required int id,
    required String habitName,
    required int habitId,
    required DateTime scheduledTime,
    String? customMessage,
  }) async {
    final payload = createHabitReminderPayload(habitId);
    
    await scheduleNotification(
      id: id,
      title: '习惯提醒',
      body: customMessage ?? '该打卡「$habitName」了！',
      scheduledTime: scheduledTime,
      payload: payload,
    );
  }
  
  /// 显示成就解锁通知
  Future<void> showAchievementUnlockedNotification({
    required int id,
    required String achievementName,
    required int achievementId,
  }) async {
    final payload = createAchievementPayload(achievementId);
    
    await showNotification(
      id: id,
      title: '🎉 获得新成就！',
      body: '恭喜你获得了「$achievementName」成就！',
      payload: payload,
    );
  }
  
  /// 显示即时通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_isInitialized || !_permissionGranted) {
      Logger.warning('通知服务未初始化或无权限，跳过通知显示');
      return;
    }
    
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails ?? _getDefaultNotificationDetails(),
        payload: payload,
      );
      
      Logger.debug('显示通知: $title - $body');
      
    } catch (e, stackTrace) {
      Logger.error('显示通知失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 调度通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_isInitialized || !_permissionGranted) {
      Logger.warning('通知服务未初始化或无权限，跳过通知调度');
      return;
    }
    
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails ?? _getDefaultNotificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      Logger.debug('调度通知: $title 在 $scheduledTime');
      
    } catch (e, stackTrace) {
      Logger.error('调度通知失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 调度重复通知
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    DateTime? scheduledTime,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_isInitialized || !_permissionGranted) {
      Logger.warning('通知服务未初始化或无权限，跳过重复通知调度');
      return;
    }
    
    try {
      final time = scheduledTime ?? DateTime.now().add(const Duration(minutes: 1));
      
      await _notificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        notificationDetails ?? _getDefaultNotificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      Logger.debug('调度重复通知: $title，间隔: $repeatInterval');
      
    } catch (e, stackTrace) {
      Logger.error('调度重复通知失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 取消通知
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) {
      Logger.warning('通知服务未初始化，跳过通知取消');
      return;
    }
    
    try {
      await _notificationsPlugin.cancel(id);
      Logger.debug('取消通知: $id');
      
    } catch (e, stackTrace) {
      Logger.error('取消通知失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      Logger.warning('通知服务未初始化，跳过所有通知取消');
      return;
    }
    
    try {
      await _notificationsPlugin.cancelAll();
      Logger.info('取消所有通知');
      
    } catch (e, stackTrace) {
      Logger.error('取消所有通知失败', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      Logger.warning('通知服务未初始化');
      return [];
    }
    
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      Logger.debug('待处理通知数量: ${pending.length}');
      return pending;
      
    } catch (e, stackTrace) {
      Logger.error('获取待处理通知失败', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// 获取活跃的通知
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (!_isInitialized) {
      Logger.warning('通知服务未初始化');
      return [];
    }
    
    try {
      final active = await _notificationsPlugin.getActiveNotifications();
      Logger.debug('活跃通知数量: ${active.length}');
      return active;
      
    } catch (e, stackTrace) {
      Logger.error('获取活跃通知失败', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// 获取默认通知详情
  NotificationDetails _getDefaultNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'dakahabit_channel',
        '打卡提醒',
        channelDescription: '习惯打卡提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4ECDC4),
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'habit_reminder',
      ),
    );
  }
  
  /// 创建习惯提醒通知
  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required DateTime reminderTime,
    String? description,
  }) async {
    final payload = '{"type": "habit_reminder", "habit_id": "$habitId"}';
    
    await scheduleNotification(
      id: habitId,
      title: '习惯提醒',
      body: description ?? '该打卡 $habitName 了！',
      scheduledTime: reminderTime,
      payload: payload,
      notificationDetails: _getHabitReminderNotificationDetails(),
    );
  }
  
  /// 取消习惯提醒
  Future<void> cancelHabitReminder(int habitId) async {
    await cancelNotification(habitId);
  }
  
  /// 获取习惯提醒通知详情
  NotificationDetails _getHabitReminderNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminder_channel',
        '习惯提醒',
        channelDescription: '习惯打卡提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4ECDC4),
        enableVibration: true,
        playSound: true,
        showWhen: true,
        ongoing: false,
        autoCancel: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'complete_action',
            '立即完成',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze_action',
            '稍后提醒',
            cancelNotification: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'habit_reminder',
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }
  
  /// 创建成就解锁通知
  Future<void> showAchievementNotification({
    required String achievementName,
    required String description,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    await showNotification(
      id: id,
      title: '🎉 解锁新成就！',
      body: '$achievementName - $description',
      payload: '{"type": "achievement_unlocked"}',
      notificationDetails: _getAchievementNotificationDetails(),
    );
  }
  
  /// 获取成就通知详情
  NotificationDetails _getAchievementNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'achievement_channel',
        '成就通知',
        channelDescription: '成就解锁通知',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFFB74D),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'achievement',
      ),
    );
  }
  
  /// 重新检查权限状态
  Future<void> recheckPermissions() async {
    await _requestPermissions();
  }
  
  /// 清理服务
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        // 可以在这里清理一些资源
        Logger.info('通知服务已清理');
      } catch (e, stackTrace) {
        Logger.error('通知服务清理失败', error: e, stackTrace: stackTrace);
      }
    }
  }
}