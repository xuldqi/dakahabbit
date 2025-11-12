import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/statistics_provider.dart';
import '../../providers/habit_provider.dart';
import '../../../app/app_colors.dart';

/// 统计分析页面
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  String _selectedPeriod = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            const _OverallStatsCard(),
            const SizedBox(height: 16),
            _TrendChartCard(period: _selectedPeriod),
            const SizedBox(height: 16),
            const _WeeklyChartCard(),
            const SizedBox(height: 16),
            const _AchievementsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: _PeriodChip(
                label: '本周',
                value: 'week',
                selected: _selectedPeriod == 'week',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPeriod = 'week';
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PeriodChip(
                label: '本月',
                value: 'month',
                selected: _selectedPeriod == 'month',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPeriod = 'month';
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PeriodChip(
                label: '本年',
                value: 'year',
                selected: _selectedPeriod == 'year',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPeriod = 'year';
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : Colors.grey[700],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
            const Text(
              '整体统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) {
                final weeklyRate = (stats['weeklyCompletionRate'] as num? ?? 0).toDouble();
                final monthlyRate = (stats['monthlyCompletionRate'] as num? ?? 0).toDouble();
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: '活跃习惯',
                          value: '${habitState.habits.length}',
                          icon: Icons.track_changes,
                          color: AppColors.primary,
                        ),
                        _StatCard(
                          title: '本周完成率',
                          value: '${(weeklyRate * 100).round()}%',
                          icon: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: '今日完成',
                          value: '${stats['todayCompletions'] ?? 0}',
                          icon: Icons.check_circle,
                          color: AppColors.warning,
                        ),
                        _StatCard(
                          title: '本月完成率',
                          value: '${(monthlyRate * 100).round()}%',
                          icon: Icons.calendar_month,
                          color: AppColors.habit,
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

/// 趋势图表卡片
class _TrendChartCard extends ConsumerWidget {
  final String period;

  const _TrendChartCard({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    
    // 生成模拟数据（实际应该从服务获取）
    final chartData = _generateChartData(period, habitState.habits.length);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '完成趋势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getPeriodLabel(period),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return _getBottomTitle(value, meta, period);
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  minX: 0,
                  maxX: chartData.length - 1.toDouble(),
                  minY: 0,
                  maxY: chartData.isEmpty
                      ? 10
                      : (chartData.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateChartData(String period, int habitCount) {
    // 根据周期生成模拟数据
    final days = period == 'week' ? 7 : period == 'month' ? 30 : 365;
    final data = <double>[];
    
    for (int i = 0; i < days; i++) {
      // 模拟数据：基于习惯数量生成随机完成数
      final base = habitCount * 0.6;
      final variation = (i % 7) * 0.2; // 周末可能不同
      data.add((base + variation + (i * 0.1)).clamp(0, habitCount.toDouble()));
    }
    
    return data;
  }

  Widget _getBottomTitle(double value, TitleMeta meta, String period) {
    if (value.toInt() >= meta.max.toInt()) {
      return const Text('');
    }
    
    if (period == 'week') {
      const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final index = value.toInt();
      if (index >= 0 && index < days.length) {
        return Text(
          days[index],
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        );
      }
    } else if (period == 'month') {
      // 显示每5天的日期
      if (value.toInt() % 5 == 0) {
        return Text(
          '${value.toInt() + 1}日',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        );
      }
    }
    
    return const Text('');
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week':
        return '最近7天';
      case 'month':
        return '最近30天';
      case 'year':
        return '最近一年';
      default:
        return '';
    }
  }
}

class _WeeklyChartCard extends ConsumerWidget {
  const _WeeklyChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStats = ref.watch(habitCategoryStatsProvider);
    final habitState = ref.watch(habitProvider);
    
    // 计算分类统计
    final categoryCounts = <String, int>{};
    for (final habit in habitState.habits) {
      categoryCounts[habit.category] = (categoryCounts[habit.category] ?? 0) + 1;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '习惯分类分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (categoryCounts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('暂无数据'),
                ),
              )
            else ...[
              // 饼图
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _generatePieChartSections(categoryCounts),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 图例
              ...categoryCounts.entries.map((entry) {
                final categoryName = _getCategoryName(entry.key);
                final count = entry.value;
                final total = categoryCounts.values.fold(0, (a, b) => a + b);
                final percentage = total > 0 ? (count / total * 100).round() : 0;
                final color = _getCategoryColor(entry.key);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(categoryName),
                      ),
                      Text(
                        '$count ($percentage%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(Map<String, int> categoryCounts) {
    final total = categoryCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];
    
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.habit,
      AppColors.info,
    ];
    
    int colorIndex = 0;
    return categoryCounts.entries.map((entry) {
      final value = entry.value / total;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        value: value,
        color: color,
        title: '${(value * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
  
  String _getCategoryName(String category) {
    switch (category) {
      case 'health':
        return '健康';
      case 'exercise':
        return '运动';
      case 'study':
        return '学习';
      case 'work':
        return '工作';
      case 'life':
        return '生活';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return AppColors.primary;
      case 'exercise':
        return AppColors.success;
      case 'study':
        return AppColors.habit;
      case 'work':
        return AppColors.info;
      case 'life':
        return AppColors.warning;
      default:
        return Colors.grey;
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
            const Text(
              '成就概览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AchievementBadge(
                  title: '习惯创建者',
                  description: '创建了$totalHabits个习惯',
                  icon: Icons.add_circle,
                  color: AppColors.primary,
                  unlocked: totalHabits > 0,
                ),
                _AchievementBadge(
                  title: '坚持达人',
                  description: '最长连击${maxStreak}天',
                  icon: Icons.local_fire_department,
                  color: AppColors.warning,
                  unlocked: maxStreak >= 3,
                ),
                _AchievementBadge(
                  title: '全面发展',
                  description: '$habitsWithStreak个习惯有连击',
                  icon: Icons.stars,
                  color: AppColors.habit,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? color : Colors.grey[300],
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
