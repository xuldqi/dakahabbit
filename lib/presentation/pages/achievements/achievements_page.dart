import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../../app/app_colors.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('成就中心'),
      ),
      body: achievementsAsync.when(
        data: (data) {
          final achievements = List<Map<String, dynamic>>.from(data['achievements'] as List? ?? []);
          final completed = data['completed'] as int? ?? 0;
          final total = data['total'] as int? ?? achievements.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AchievementSummary(completed: completed, total: total),
                const SizedBox(height: 16),
                ...achievements.map((achievement) => _AchievementItem(achievement: achievement)).toList(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text('加载成就信息失败：$error'),
          ),
        ),
      ),
    );
  }
}

class _AchievementSummary extends StatelessWidget {
  final int completed;
  final int total;

  const _AchievementSummary({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final completionRate = total == 0 ? 0.0 : completed / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成就概览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completed / $total',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '已解锁的成就',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: Colors.grey[200],
                        color: AppColors.primary,
                        minHeight: 12,
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(completionRate * 100).round()}%'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const _AchievementItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final completed = achievement['completed'] as bool? ?? false;
    final progress = (achievement['progress'] as num?)?.toDouble() ?? 0.0;
    final title = achievement['title'] as String? ?? '';
    final description = achievement['description'] as String? ?? '';
    final habitName = achievement['habitName'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? AppColors.success.withOpacity(0.1) : Colors.grey[200],
                  ),
                  child: Icon(
                    completed ? Icons.emoji_events : Icons.lock,
                    color: completed ? AppColors.success : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (habitName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '相关习惯：$habitName',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: completed ? AppColors.success : AppColors.primary,
              minHeight: 10,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(progress * 100).round()}%'),
            ),
          ],
        ),
      ),
    );
  }
}
