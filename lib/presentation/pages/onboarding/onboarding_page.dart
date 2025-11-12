import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_colors.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/providers/app_providers.dart';

/// 引导页面
/// 多页滑动引导，介绍核心功能
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.track_changes,
      title: '创建你的习惯',
      description: '轻松创建和管理你的日常习惯，设置提醒和目标，让好习惯成为生活的一部分',
      color: AppColors.primaryColor,
    ),
    OnboardingPageData(
      icon: Icons.check_circle,
      title: '每日打卡',
      description: '简单的一键打卡，记录你的每一次坚持。连续打卡获得成就，让坚持变得更有趣',
      color: Colors.green,
    ),
    OnboardingPageData(
      icon: Icons.analytics,
      title: '查看统计',
      description: '清晰的数据可视化，了解你的进步轨迹。看到自己的成长，更有动力继续坚持',
      color: Colors.orange,
    ),
    OnboardingPageData(
      icon: Icons.book,
      title: '记录日志',
      description: '记录习惯执行的心得和感受，让习惯养成更有意义。回顾过去，展望未来',
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    try {
      final prefsService = ref.read(sharedPreferencesServiceProvider);
      await prefsService.setBool('onboarding_completed', true);
      // 刷新首次启动状态
      ref.invalidate(onboardingCompletedProvider);
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // 即使失败也继续导航
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage >= index
                            ? AppColors.primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(
                    data: _pages[index],
                    isLastPage: index == _pages.length - 1,
                    onGetStarted: _completeOnboarding,
                  );
                },
              ),
            ),
            
            // 底部导航
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 跳过按钮（仅在非最后一页显示）
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('跳过'),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // 下一步/开始按钮
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? '下一步' : '开始使用',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 引导页面数据模型
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// 引导页面内容组件
class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPageData data;
  final bool isLastPage;
  final VoidCallback onGetStarted;

  const _OnboardingPageContent({
    required this.data,
    required this.isLastPage,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          
          // 标题
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // 描述
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
