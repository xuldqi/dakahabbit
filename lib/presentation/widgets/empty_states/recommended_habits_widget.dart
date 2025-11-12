import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_router.dart';

/// 推荐习惯数据
class RecommendedHabit {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  const RecommendedHabit({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

/// 推荐习惯列表
class RecommendedHabitsWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onCreateHabit;

  const RecommendedHabitsWidget({
    super.key,
    this.title = '推荐习惯',
    this.subtitle,
    this.onCreateHabit,
  });

  static final List<RecommendedHabit> _recommendedHabits = [
    RecommendedHabit(
      name: '早起',
      description: '养成规律的作息习惯',
      icon: Icons.wb_sunny,
      color: AppColors.warning,
      category: 'health',
    ),
    RecommendedHabit(
      name: '喝水8杯',
      description: '保持身体水分平衡',
      icon: Icons.water_drop,
      color: AppColors.info,
      category: 'health',
    ),
    RecommendedHabit(
      name: '运动30分钟',
      description: '每天进行体育锻炼',
      icon: Icons.fitness_center,
      color: AppColors.success,
      category: 'exercise',
    ),
    RecommendedHabit(
      name: '读书30分钟',
      description: '增长知识开阔视野',
      icon: Icons.book,
      color: AppColors.habit,
      category: 'study',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedHabits.length,
            itemBuilder: (context, index) {
              final habit = _recommendedHabits[index];
              return _RecommendedHabitCard(
                habit: habit,
                onCreateHabit: onCreateHabit,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 推荐习惯卡片
class _RecommendedHabitCard extends StatelessWidget {
  final RecommendedHabit habit;
  final VoidCallback? onCreateHabit;

  const _RecommendedHabitCard({
    required this.habit,
    this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            if (onCreateHabit != null) {
              onCreateHabit!();
            } else {
              context.go('/habit/create');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    habit.icon,
                    color: habit.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  habit.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

