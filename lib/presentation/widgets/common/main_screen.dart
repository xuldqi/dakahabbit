import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../generated/l10n.dart';

/// 主屏幕框架组件
/// 包含底部导航栏和主内容区域
class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    
    int selectedIndex = 0;
    switch (currentLocation) {
      case AppRoutes.home:
        selectedIndex = 0;
        break;
      case AppRoutes.habits:
        selectedIndex = 1;
        break;
      case AppRoutes.statistics:
        selectedIndex = 2;
        break;
      case AppRoutes.journals:
        selectedIndex = 3;
        break;
      case AppRoutes.settings:
        selectedIndex = 4;
        break;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (index) => _onTabTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: S.of(context).home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.track_changes_outlined),
          activeIcon: const Icon(Icons.track_changes),
          label: S.of(context).habits,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics_outlined),
          activeIcon: const Icon(Icons.analytics),
          label: S.of(context).statistics,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book_outlined),
          activeIcon: const Icon(Icons.book),
          label: S.of(context).journals,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: S.of(context).settings,
        ),
      ],
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.habits);
        break;
      case 2:
        context.go(AppRoutes.statistics);
        break;
      case 3:
        context.go(AppRoutes.journals);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }
}