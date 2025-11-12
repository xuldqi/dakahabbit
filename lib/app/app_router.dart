import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/habits/habits_page.dart';
import '../presentation/pages/habits/habit_detail_page.dart';
import '../presentation/pages/habits/create_habit_page.dart';
import '../presentation/pages/habits/edit_habit_page.dart';
import '../presentation/pages/statistics/statistics_page.dart';
import '../presentation/pages/statistics/habit_statistics_page.dart';
import '../presentation/pages/journals/journals_page.dart';
import '../presentation/pages/journals/journal_detail_page.dart';
import '../presentation/pages/journals/create_journal_page.dart';
import '../presentation/pages/journals/edit_journal_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/settings/theme_settings_page.dart';
import '../presentation/pages/settings/notification_settings_page.dart';
import '../presentation/pages/settings/privacy_settings_page.dart';
import '../presentation/pages/settings/backup_settings_page.dart';
import '../presentation/pages/settings/about_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/onboarding/welcome_page.dart';
import '../presentation/widgets/common/main_screen.dart';
import '../core/providers/onboarding_provider.dart';

/// 路由名称常量
class AppRoutes {
  static const String root = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  
  // 主导航页面
  static const String home = '/home';
  static const String habits = '/habits';
  static const String statistics = '/statistics';
  static const String journals = '/journals';
  static const String settings = '/settings';
  
  // 习惯相关页面
  static const String habitDetail = '/habit/:id';
  static const String createHabit = '/habit/create';
  static const String editHabit = '/habit/:id/edit';
  static const String habitStatistics = '/habit/:id/statistics';
  
  // 日志相关页面
  static const String journalDetail = '/journal/:id';
  static const String createJournal = '/journal/create';
  static const String editJournal = '/journal/:id/edit';
  
  // 统计相关页面
  static const String detailedStatistics = '/statistics/detailed';
  
  // 设置相关页面
  static const String themeSettings = '/settings/theme';
  static const String notificationSettings = '/settings/notifications';
  static const String privacySettings = '/settings/privacy';
  static const String backupSettings = '/settings/backup';
  static const String about = '/settings/about';
}

/// 路由配置Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // 初始路由
    initialLocation: AppRoutes.root,
    
    // 调试日志
    debugLogDiagnostics: true,
    
    // 路由守卫
    redirect: (context, state) {
      // 检查首次启动
      final onboardingCompleted = ref.read(onboardingCompletedProvider);
      
      // 如果正在访问欢迎页或引导页，不需要重定向
      if (state.uri.path == AppRoutes.welcome || 
          state.uri.path == AppRoutes.onboarding) {
        return null;
      }
      
      // 如果首次启动未完成，重定向到欢迎页
      // 注意：这里使用异步检查，实际应该使用 FutureProvider 或 StreamProvider
      // 为了简化，我们让欢迎页和引导页可以正常访问，其他页面会检查
      return null;
    },
    
    // 错误处理
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('页面不存在')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '找不到页面',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? '未知错误',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.root),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      );
    },
    
    // 路由定义
    routes: [
      // 根路由 - 检查首次启动
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) {
          return _InitialRouteHandler();
        },
      ),
      
      // 欢迎页面
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      
      // 引导页面
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // 主导航Shell路由
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // 首页
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) {
              return _buildPageWithTransition(
                context,
                state,
                const HomePage(),
              );
            },
          ),
          
          // 习惯页面
          GoRoute(
            path: AppRoutes.habits,
            name: 'habits',
            pageBuilder: (context, state) {
              return _buildPageWithTransition(
                context,
                state,
                const HabitsPage(),
              );
            },
          ),
          
          // 统计页面
          GoRoute(
            path: AppRoutes.statistics,
            name: 'statistics',
            pageBuilder: (context, state) {
              return _buildPageWithTransition(
                context,
                state,
                const StatisticsPage(),
              );
            },
          ),
          
          // 日志页面
          GoRoute(
            path: AppRoutes.journals,
            name: 'journals',
            pageBuilder: (context, state) {
              return _buildPageWithTransition(
                context,
                state,
                const JournalsPage(),
              );
            },
          ),
          
          // 设置页面
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) {
              return _buildPageWithTransition(
                context,
                state,
                const SettingsPage(),
              );
            },
          ),
        ],
      ),
      
      // 创建习惯页面（必须在 /habit/:id 之前）
      GoRoute(
        path: '/habit/create',
        name: 'createHabit',
        builder: (context, state) {
          final templateId = state.uri.queryParameters['template'];
          return CreateHabitPage(templateId: templateId);
        },
      ),
      
      // 习惯详情页面
      GoRoute(
        path: '/habit/:id',
        name: 'habitDetail',
        builder: (context, state) {
          final habitId = int.parse(state.pathParameters['id']!);
          return HabitDetailPage(habitId: habitId);
        },
      ),
      
      // 编辑习惯页面
      GoRoute(
        path: '/habit/:id/edit',
        name: 'editHabit',
        builder: (context, state) {
          final habitId = int.parse(state.pathParameters['id']!);
          return EditHabitPage(habitId: habitId);
        },
      ),
      
      // 习惯统计页面
      GoRoute(
        path: '/habit/:id/statistics',
        name: 'habitStatistics',
        builder: (context, state) {
          final habitId = int.parse(state.pathParameters['id']!);
          return HabitStatisticsPage(habitId: habitId);
        },
      ),
      
      // 日志详情页面
      GoRoute(
        path: '/journal/:id',
        name: 'journalDetail',
        builder: (context, state) {
          final journalId = int.parse(state.pathParameters['id']!);
          return JournalDetailPage(journalId: journalId);
        },
      ),
      
      // 创建日志页面
      GoRoute(
        path: '/journal/create',
        name: 'createJournal',
        builder: (context, state) {
          final habitIds = state.uri.queryParameters['habits']?.split(',');
          final date = state.uri.queryParameters['date'];
          return CreateJournalPage(
            relatedHabitIds: habitIds?.map(int.parse).toList(),
            initialDate: date != null ? DateTime.parse(date) : null,
          );
        },
      ),
      
      // 编辑日志页面
      GoRoute(
        path: '/journal/:id/edit',
        name: 'editJournal',
        builder: (context, state) {
          final journalId = int.parse(state.pathParameters['id']!);
          return EditJournalPage(journalId: journalId);
        },
      ),
      
      // 设置子页面
      GoRoute(
        path: '/settings/theme',
        name: 'themeSettings',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      
      GoRoute(
        path: '/settings/notifications',
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      
      GoRoute(
        path: '/settings/privacy',
        name: 'privacySettings',
        builder: (context, state) => const PrivacySettingsPage(),
      ),
      
      GoRoute(
        path: '/settings/backup',
        name: 'backupSettings',
        builder: (context, state) => const BackupSettingsPage(),
      ),
      
      GoRoute(
        path: '/settings/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
});

/// 构建带有过渡动画的页面
Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 使用淡入淡出过渡
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// 路由扩展方法
extension AppRouterExtension on GoRouter {
  /// 导航到首页
  void goHome() => go(AppRoutes.home);
  
  /// 导航到习惯页面
  void goHabits() => go(AppRoutes.habits);
  
  /// 导航到统计页面  
  void goStatistics() => go(AppRoutes.statistics);
  
  /// 导航到日志页面
  void goJournals() => go(AppRoutes.journals);
  
  /// 导航到设置页面
  void goSettings() => go(AppRoutes.settings);
  
  /// 导航到习惯详情页面
  void goHabitDetail(int habitId) => go('/habit/$habitId');
  
  /// 导航到创建习惯页面
  void goCreateHabit({String? templateId}) {
    final uri = Uri(
      path: '/habit/create',
      queryParameters: templateId != null ? {'template': templateId} : null,
    );
    go(uri.toString());
  }
  
  /// 导航到编辑习惯页面
  void goEditHabit(int habitId) => go('/habit/$habitId/edit');
  
  /// 导航到习惯统计页面
  void goHabitStatistics(int habitId) => go('/habit/$habitId/statistics');
  
  /// 导航到日志详情页面
  void goJournalDetail(int journalId) => go('/journal/$journalId');
  
  /// 导航到创建日志页面
  void goCreateJournal({
    List<int>? relatedHabitIds,
    DateTime? initialDate,
  }) {
    final queryParameters = <String, String>{};
    if (relatedHabitIds != null && relatedHabitIds.isNotEmpty) {
      queryParameters['habits'] = relatedHabitIds.join(',');
    }
    if (initialDate != null) {
      queryParameters['date'] = initialDate.toIso8601String();
    }
    
    final uri = Uri(
      path: '/journal/create',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    go(uri.toString());
  }
  
  /// 导航到编辑日志页面
  void goEditJournal(int journalId) => go('/journal/$journalId/edit');
}

/// 初始路由处理器
/// 检查首次启动状态并重定向到相应页面
class _InitialRouteHandler extends ConsumerWidget {
  const _InitialRouteHandler();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompletedAsync = ref.watch(onboardingCompletedProvider);
    
    return onboardingCompletedAsync.when(
      data: (completed) {
        // 使用 WidgetsBinding 确保导航在下一帧执行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (completed) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.welcome);
          }
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) {
        // 出错时默认跳转到主页
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.home);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// GoRouter状态扩展
extension GoRouterStateExtension on GoRouterState {
  /// 获取路径参数
  String? getPathParameter(String name) => pathParameters[name];
  
  /// 获取查询参数
  String? getQueryParameter(String name) => uri.queryParameters[name];
  
  /// 获取查询参数列表
  List<String>? getQueryParameterList(String name) {
    final value = uri.queryParameters[name];
    return value?.split(',');
  }
  
  /// 检查是否为主导航页面
  bool get isMainPage {
    final location = uri.toString();
    return location == AppRoutes.home ||
           location == AppRoutes.habits ||
           location == AppRoutes.statistics ||
           location == AppRoutes.journals ||
           location == AppRoutes.settings;
  }
  
  /// 获取当前主导航索引
  int get currentMainPageIndex {
    final location = uri.toString();
    switch (location) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.habits:
        return 1;
      case AppRoutes.statistics:
        return 2;
      case AppRoutes.journals:
        return 3;
      case AppRoutes.settings:
        return 4;
      default:
        return 0;
    }
  }
}