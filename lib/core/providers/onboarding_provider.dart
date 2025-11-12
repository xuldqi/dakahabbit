import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_preferences_service.dart';
import '../utils/logger.dart';
import 'app_providers.dart';

/// 首次启动状态Provider
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  try {
    final prefsService = ref.watch(sharedPreferencesServiceProvider);
    final completed = prefsService.getBool('onboarding_completed') ?? false;
    Logger.info('首次启动检查: ${completed ? "已完成" : "未完成"}');
    return completed;
  } catch (e, stackTrace) {
    Logger.error('检查首次启动状态失败', error: e, stackTrace: stackTrace);
    return false;
  }
});

