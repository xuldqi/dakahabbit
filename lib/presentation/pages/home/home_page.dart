import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../generated/l10n.dart';
import '../../../core/models/models.dart';
import '../../providers/habit_provider.dart';
import '../../providers/check_in_provider.dart';
import '../../../app/app_router.dart';

/// 首页
/// 显示今日习惯概览和快速操作
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appName),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/habit/create'),
            tooltip: '创建习惯',
          ),
        ],
      ),
      body: const RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodayOverviewCard(),
              SizedBox(height: 16),
              _TodayHabitsSection(),
              SizedBox(height: 16),
              _QuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _onRefresh() async {
    // 刷新数据逻辑
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// 今日概览卡片
class _TodayOverviewCard extends ConsumerWidget {
  const _TodayOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final todayStats = ref.watch(todayStatsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日概览',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            todayHabitsAsync.when(
              data: (habits) {
                final totalHabits = habits.length;
                final completed = todayStats['completed'] ?? 0;
                final completionRate = totalHabits > 0 
                    ? ((completed / totalHabits) * 100).round()
                    : 0;
                    
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: '待完成',
                      value: '${totalHabits - completed}',
                      icon: Icons.pending_actions,
                    ),
                    _StatItem(
                      label: '已完成',
                      value: '$completed',
                      icon: Icons.check_circle,
                    ),
                    _StatItem(
                      label: '完成率',
                      value: '$completionRate%',
                      icon: Icons.trending_up,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: '待完成', value: '0', icon: Icons.pending_actions),
                  _StatItem(label: '已完成', value: '0', icon: Icons.check_circle),
                  _StatItem(label: '完成率', value: '0%', icon: Icons.trending_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计项目组件
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

/// 今日习惯部分
class _TodayHabitsSection extends ConsumerWidget {
  const _TodayHabitsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '今日习惯',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(AppRoutes.habits),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        todayHabitsAsync.when(
          data: (habits) {
            if (habits.isEmpty) {
              return const _PlaceholderMessage(
                icon: Icons.track_changes,
                message: '还没有习惯，点击右上角创建第一个习惯吧！',
              );
            }
            
            return Column(
              children: habits.take(3).map((habit) => 
                _HabitTile(habit: habit)
              ).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const _PlaceholderMessage(
            icon: Icons.error_outline,
            message: '加载习惯失败，请重试',
          ),
        ),
      ],
    );
  }
}

/// 习惯列表项
class _HabitTile extends ConsumerWidget {
  final Habit habit;

  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCheckedIn = ref.watch(hasCheckedInProvider(habit.id!));
    final isLoading = ref.watch(checkInProvider).isLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasCheckedIn 
              ? Colors.green
              : Theme.of(context).primaryColor,
          child: Icon(
            hasCheckedIn ? Icons.check : _getHabitIcon(habit.icon),
            color: Colors.white,
          ),
        ),
        title: Text(habit.name),
        subtitle: habit.description != null 
            ? Text(habit.description!) 
            : null,
        trailing: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : hasCheckedIn
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: () => _checkIn(context, ref, habit),
                    child: const Text('打卡'),
                  ),
        onTap: () => context.go('/habit/${habit.id}'),
      ),
    );
  }

  void _checkIn(BuildContext context, WidgetRef ref, Habit habit) async {
    final checkInNotifier = ref.read(checkInProvider.notifier);
    final success = await checkInNotifier.checkIn(habit.id!);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit.name} 打卡成功！'),
          backgroundColor: Colors.green,
        ),
      );
      // 刷新习惯数据
      ref.invalidate(todayHabitsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('打卡失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getHabitIcon(String iconName) {
    switch (iconName) {
      case 'sunrise':
        return Icons.wb_sunny;
      case 'water_drop':
        return Icons.water_drop;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.track_changes;
    }
  }
}

/// 快速操作部分
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速操作',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                title: '新增习惯',
                onTap: () => context.go('/habit/create'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.edit_note,
                title: '写日志',
                onTap: () => context.go('/journal/create'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                title: '查看统计',
                onTap: () => context.go(AppRoutes.statistics),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.settings,
                title: '应用设置',
                onTap: () => context.go(AppRoutes.settings),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 快速操作卡片
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 占位符消息组件
class _PlaceholderMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _PlaceholderMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}