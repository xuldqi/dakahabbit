import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../providers/habit_provider.dart';

/// 统计分析页面
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _OverallStatsCard(),
            SizedBox(height: 16),
            _WeeklyChartCard(),
            SizedBox(height: 16),
            _AchievementsCard(),
          ],
        ),
      ),
    );
  }
}

class _OverallStatsCard extends ConsumerWidget {
  const _OverallStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final habitState = ref.watch(habitProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('整体统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: '活跃习惯',
                          value: '${habitState.habits.length}',
                          icon: Icons.track_changes,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: '本周完成率',
                          value: '${(stats['weeklyCompletionRate'] * 100).round()}%',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: '今日完成',
                          value: '${stats['todayCompletions']}',
                          icon: Icons.check_circle,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: '本月完成率',
                          value: '${(stats['monthlyCompletionRate'] * 100).round()}%',
                          icon: Icons.calendar_month,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加载失败: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChartCard extends ConsumerWidget {
  const _WeeklyChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStats = ref.watch(habitCategoryStatsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('习惯分类分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            categoryStats.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return const Text('暂无数据');
                }
                return Column(
                  children: stats.entries.map((entry) {
                    final categoryName = _getCategoryName(entry.key);
                    final count = entry.value;
                    final percentage = stats.values.fold(0, (a, b) => a + b) > 0
                        ? (count / stats.values.fold(0, (a, b) => a + b) * 100).round()
                        : 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(categoryName),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearProgressIndicator(
                              value: stats.values.fold(0, (a, b) => a + b) > 0
                                  ? count / stats.values.fold(0, (a, b) => a + b)
                                  : 0.0,
                            ),
                          ),
                          Expanded(
                            child: Text('$count ($percentage%)', textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加载失败: $error'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCategoryName(String category) {
    switch (category) {
      case 'health': return '健康';
      case 'exercise': return '运动';
      case 'study': return '学习';
      case 'work': return '工作';
      case 'life': return '生活';
      default: return category;
    }
  }
}

class _AchievementsCard extends ConsumerWidget {
  const _AchievementsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    
    // 简单的成就计算
    final totalHabits = habitState.habits.length;
    final habitsWithStreak = habitState.habits.where((h) => h.streakCount > 0).length;
    final maxStreak = habitState.habits.isNotEmpty 
        ? habitState.habits.map((h) => h.streakCount).reduce((a, b) => a > b ? a : b)
        : 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('成就概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AchievementBadge(
                  title: '习惯创建者',
                  description: '创建了$totalHabits个习惯',
                  icon: Icons.add_circle,
                  color: Colors.blue,
                  unlocked: totalHabits > 0,
                ),
                _AchievementBadge(
                  title: '坚持达人',
                  description: '最长连击${maxStreak}天',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  unlocked: maxStreak >= 3,
                ),
                _AchievementBadge(
                  title: '全面发展',
                  description: '$habitsWithStreak个习惯有连击',
                  icon: Icons.stars,
                  color: Colors.purple,
                  unlocked: habitsWithStreak >= 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _AchievementBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? color : Colors.grey[300],
          ),
          child: Icon(
            icon,
            color: unlocked ? Colors.white : Colors.grey[500],
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: unlocked ? color : Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}