import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../generated/l10n.dart';
import '../../../core/models/models.dart';
import '../../providers/habit_provider.dart';
import '../../providers/check_in_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../../app/app_router.dart';
import '../../../app/app_colors.dart';
import '../../widgets/feedback/check_in_celebration.dart';
import '../../widgets/empty_states/recommended_habits_widget.dart';

/// 首页
/// 展示今日行动、提醒概览、洞察和快速操作
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayHabitsProvider);
          ref.invalidate(statisticsProvider);
          ref.invalidate(achievementProgressProvider);
          ref.invalidate(checkInProvider);
          await ref.read(habitProvider.notifier).loadHabits();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: const _HomeContent(),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final isMedium = constraints.maxWidth >= 720 && !isWide;

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeHeaderCard(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _TodayActionCard(),
                        SizedBox(height: 16),
                        _TodayHabitsSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _ReminderOverviewSection(),
                        SizedBox(height: 16),
                        _InsightsSection(),
                        SizedBox(height: 16),
                        _AchievementsNudgeCard(),
                        SizedBox(height: 16),
                        _QuickActionsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        if (isMedium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeHeaderCard(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _TodayActionCard(),
                        SizedBox(height: 16),
                        _ReminderOverviewSection(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _InsightsSection(),
                        SizedBox(height: 16),
                        _AchievementsNudgeCard(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _TodayHabitsSection(),
              const SizedBox(height: 16),
              const _QuickActionsSection(),
            ],
          );
        }

        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeaderCard(),
            SizedBox(height: 16),
            _TodayActionCard(),
            SizedBox(height: 16),
            _ReminderOverviewSection(),
            SizedBox(height: 16),
            _InsightsSection(),
            SizedBox(height: 16),
            _TodayHabitsSection(),
            SizedBox(height: 16),
            _AchievementsNudgeCard(),
            SizedBox(height: 16),
            _QuickActionsSection(),
          ],
        );
      },
    );
  }
}

class _HomeHeaderCard extends ConsumerWidget {
  const _HomeHeaderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final todayStats = ref.watch(todayStatsProvider);

    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat.yMMMMEEEEd(locale).format(now);
    final greeting = _greetingForHour(now.hour);

    final totalHabits = todayHabitsAsync.maybeWhen(
      data: (habits) => habits.length,
      orElse: () => 0,
    );
    final completed = todayStats['completed'] ?? 0;
    final pending = max(totalHabits - completed, 0);
    final progress = totalHabits > 0 ? completed / totalHabits : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日还剩',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pending 个习惯',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (totalHabits > 0)
                      Text(
                        '完成 $completed / $totalHabits',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      )
                    else
                      Text(
                        '创建首个习惯，开启旅程',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: totalHabits > 0 ? progress : 0.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayActionCard extends ConsumerWidget {
  const _TodayActionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);
    final checkInState = ref.watch(checkInProvider);

    return todayHabitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '今日行动',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '还没有习惯，先从创建一个开始吧。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/habit/create'),
                    child: const Text('创建新习惯'),
                  ),
                ],
              ),
            ),
          );
        }

        final split = _splitHabitsByCompletion(habits, checkInState);
        final pendingHabits = split.pending;
        final completedHabits = split.completed;
        final nextReminder = _findNextReminder(pendingHabits.isNotEmpty ? pendingHabits : habits);

        if (pendingHabits.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.celebration, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        '今日行动',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '太棒了！今天的习惯已经全部完成。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.achievements),
                    child: const Text('查看我的成就'),
                  ),
                ],
              ),
            ),
          );
        }

        final primaryHabit = nextReminder?.habit ?? pendingHabits.first;
        final reminderLabel = nextReminder != null
            ? _formatReminderLabel(nextReminder.scheduledTime)
            : '暂无提醒，保持专注完成今日任务';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '今日行动',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${completedHabits.length}/${habits.length} 已完成',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '优先处理：${primaryHabit.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (primaryHabit.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    primaryHabit.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.alarm, color: AppColors.primary, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reminderLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => _handleCheckIn(context, ref, primaryHabit),
                      child: const Text('立即打卡'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/habit/${primaryHabit.id}'),
                      child: const Text('查看详情'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingCard(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    '今日行动',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('加载数据时出错，请稍后重试：$error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderOverviewSection extends ConsumerWidget {
  const _ReminderOverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);

    return todayHabitsAsync.when(
      data: (habits) {
        final candidates = _generateReminderCandidates(habits);
        final upcoming = candidates.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '提醒概览',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/settings/notifications'),
                      child: const Text('管理提醒'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  const _PlaceholderMessage(
                    icon: Icons.notifications_off_outlined,
                    message: '暂无即将到来的提醒，试着为习惯添加提醒时间。',
                  )
                else
                  Column(
                    children: upcoming.map((candidate) {
                      final label = _formatReminderLabel(candidate.scheduledTime);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Icon(Icons.alarm, color: AppColors.primary),
                        ),
                        title: Text(candidate.habit.name),
                        subtitle: Text(label),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => context.go('/habit/${candidate.habit.id}'),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingCard(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('提醒数据加载失败：$error'),
        ),
      ),
    );
  }
}

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
              return Column(
                children: [
                  const _PlaceholderMessage(
                    icon: Icons.track_changes,
                    message: '还没有习惯，试试这些推荐习惯吧！',
                  ),
                  const SizedBox(height: 24),
                  RecommendedHabitsWidget(
                    title: '',
                    subtitle: '点击卡片快速创建',
                    onCreateHabit: () => context.go('/habit/create'),
                  ),
                ],
              );
            }

            return Column(
              children: habits.map((habit) => _HabitTile(habit: habit)).toList(),
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

class _HabitTile extends ConsumerWidget {
  final Habit habit;

  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCheckedIn = ref.watch(hasCheckedInProvider(habit.id!));
    final isLoading = ref.watch(checkInProvider).isLoading;
    final nextReminder = _calculateNextReminderForHabit(habit);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasCheckedIn ? AppColors.success : AppColors.primary,
          child: Icon(
            hasCheckedIn ? Icons.check : _getHabitIcon(habit.icon),
            color: Colors.white,
          ),
        ),
        title: Text(
          habit.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description?.isNotEmpty == true)
              Text(
                habit.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (nextReminder != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatReminderLabel(nextReminder),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : hasCheckedIn
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : FilledButton(
                    onPressed: () => _handleCheckIn(context, ref, habit),
                    child: const Text('打卡'),
                  ),
        onTap: () => context.go('/habit/${habit.id}'),
      ),
    );
  }

  IconData _getHabitIcon(String iconName) {
    switch (iconName) {
      case 'sunrise':
        return Icons.wb_sunny;
      case 'water_drop':
        return Icons.water_drop;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'work':
        return Icons.work;
      default:
        return Icons.track_changes;
    }
  }
}

class _InsightsSection extends ConsumerWidget {
  const _InsightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return statsAsync.when(
      data: (stats) {
        final habitsStats = stats['habits'] as Map<String, dynamic>? ?? {};
        final checkInsStats = stats['checkIns'] as Map<String, dynamic>? ?? {};
        final completionRates = checkInsStats['completionRates'] as Map<String, dynamic>? ?? {};

        final weekRate = ((completionRates['week'] as num?) ?? 0.0) * 100;
        final monthRate = ((completionRates['month'] as num?) ?? 0.0) * 100;
        final maxStreak = checkInsStats['maxStreak'] as int? ?? 0;
        final averageStreak = checkInsStats['averageStreak'] as num? ?? 0;
        final activeHabits = habitsStats['activeCount'] as int? ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      '洞察与趋势',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _InsightItem(
                      label: '本周完成率',
                      value: '${weekRate.round()}%',
                      icon: Icons.trending_up,
                      color: AppColors.primary,
                    ),
                    _InsightItem(
                      label: '本月完成率',
                      value: '${monthRate.round()}%',
                      icon: Icons.calendar_month,
                      color: AppColors.info,
                    ),
                    _InsightItem(
                      label: '最长连击',
                      value: '$maxStreak 天',
                      icon: Icons.local_fire_department,
                      color: AppColors.warning,
                    ),
                    _InsightItem(
                      label: '平均连击',
                      value: '${averageStreak.toStringAsFixed(1)} 天',
                      icon: Icons.timeline,
                      color: AppColors.habit,
                    ),
                    _InsightItem(
                      label: '活跃习惯',
                      value: '$activeHabits 个',
                      icon: Icons.track_changes,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingCard(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('洞察数据加载失败：$error'),
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InsightItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AchievementsNudgeCard extends ConsumerWidget {
  const _AchievementsNudgeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProgressProvider);

    return achievementsAsync.when(
      data: (data) {
        final achievements = List<Map<String, dynamic>>.from(data['achievements'] as List? ?? []);
        final nextAchievement = achievements.where((a) => !(a['completed'] as bool? ?? false)).toList()
          ..sort((a, b) => ((b['progress'] as num? ?? 0) - (a['progress'] as num? ?? 0)).sign.toInt());

        if (nextAchievement.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        '成就中心',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '你已经解锁了所有当前成就，太棒了！',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.achievements),
                    child: const Text('查看成就墙'),
                  ),
                ],
              ),
            ),
          );
        }

        final target = nextAchievement.first;
        final progress = (target['progress'] as num? ?? 0).toDouble().clamp(0.0, 1.0);
        final percent = (progress * 100).round();
        final title = target['title'] as String? ?? '待解锁成就';
        final description = target['description'] as String? ?? '';
        final habitName = target['habitName'] as String?;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      '成就冲刺',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (habitName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '相关习惯：$habitName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.warning,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$percent%'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.achievements),
                      child: const Text('查看详情'),
                    ),
                    const SizedBox(width: 12),
                    if (habitName != null)
                      OutlinedButton(
                        onPressed: () => context.go('/habit/${target['habit']?['id'] ?? ''}'),
                        child: const Text('前往习惯'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingCard(),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('成就数据加载失败：$error'),
        ),
      ),
    );
  }
}

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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _QuickActionCard(
              icon: Icons.add_circle_outline,
              title: '新增习惯',
              route: '/habit/create',
            ),
            _QuickActionCard(
              icon: Icons.analytics,
              title: '数据统计',
              route: AppRoutes.statistics,
            ),
            _QuickActionCard(
              icon: Icons.notifications_active,
              title: '提醒设置',
              route: '/settings/notifications',
            ),
            _QuickActionCard(
              icon: Icons.edit_note,
              title: '写日志',
              route: '/journal/create',
            ),
            _QuickActionCard(
              icon: Icons.settings,
              title: '应用设置',
              route: AppRoutes.settings,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCandidate {
  const _ReminderCandidate({
    required this.habit,
    required this.scheduledTime,
  });

  final Habit habit;
  final DateTime scheduledTime;
}

class _HabitSplitResult {
  const _HabitSplitResult({
    required this.pending,
    required this.completed,
  });

  final List<Habit> pending;
  final List<Habit> completed;
}

String _greetingForHour(int hour) {
  if (hour < 6) return '凌晨好';
  if (hour < 9) return '早上好';
  if (hour < 12) return '上午好';
  if (hour < 18) return '下午好';
  return '晚上好';
}

String _dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

_HabitSplitResult _splitHabitsByCompletion(List<Habit> habits, CheckInState state) {
  final todayKey = _dateKey(DateTime.now());
  final todayCheckIns = state.checkInsByDate[todayKey] ?? [];
  final completedIds = todayCheckIns
      .where((c) => c.status == CheckInStatus.completed || c.status == CheckInStatus.partial)
      .map((c) => c.habitId)
      .toSet();

  final pending = habits.where((habit) => !completedIds.contains(habit.id)).toList();
  final completed = habits.where((habit) => completedIds.contains(habit.id)).toList();
  return _HabitSplitResult(pending: pending, completed: completed);
}

List<_ReminderCandidate> _generateReminderCandidates(List<Habit> habits) {
  final now = DateTime.now();
  final candidates = <_ReminderCandidate>[];

  for (final habit in habits) {
    if (!habit.reminderEnabled) continue;
    for (final timeStr in habit.getReminderTimesList()) {
      final parsed = _parseTime(timeStr);
      if (parsed == null) continue;
      var scheduled = DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      candidates.add(_ReminderCandidate(habit: habit, scheduledTime: scheduled));
    }
  }

  candidates.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  return candidates;
}

_ReminderCandidate? _findNextReminder(List<Habit> habits) {
  final candidates = _generateReminderCandidates(habits);
  return candidates.isNotEmpty ? candidates.first : null;
}

DateTime? _calculateNextReminderForHabit(Habit habit) {
  final candidates = _generateReminderCandidates([habit]);
  return candidates.isNotEmpty ? candidates.first.scheduledTime : null;
}

TimeOfDay? _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatReminderLabel(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final diffDays = targetDay.difference(today).inDays;
  final timeLabel = DateFormat('HH:mm').format(dateTime);

  switch (diffDays) {
    case 0:
      return '今天 $timeLabel';
    case 1:
      return '明天 $timeLabel';
    default:
      return DateFormat('M月d日 HH:mm').format(dateTime);
  }
}

Future<void> _handleCheckIn(BuildContext context, WidgetRef ref, Habit habit) async {
  if (habit.id == null) return;

  final checkInNotifier = ref.read(checkInProvider.notifier);
  final success = await checkInNotifier.checkIn(habit.id!);

  if (success) {
    final newStreak = habit.streakCount + 1;
    await CheckInCelebration.show(
      context,
      habitName: habit.name,
      streakCount: newStreak,
    );
    ref.invalidate(todayHabitsProvider);
    await ref.read(habitProvider.notifier).loadHabits();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('打卡失败，请重试'),
        backgroundColor: Colors.red,
      ),
    );
  }
}