import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/statistics_provider.dart';
import '../../../core/models/models.dart';
import '../../../app/app_colors.dart';

/// 单个习惯统计页面
class HabitStatisticsPage extends ConsumerWidget {
  final int habitId;

  const HabitStatisticsPage({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(habitAnalysisProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯统计'),
      ),
      body: analysisAsync.when(
        data: (analysis) {
          final habit = Habit.fromJson(analysis['habit'] as Map<String, dynamic>);
          final basicStats = analysis['basicStats'] as Map<String, dynamic>? ?? {};
          final timeAnalysis = analysis['timeAnalysis'] as Map<String, dynamic>? ?? {};
          final qualityAnalysis = analysis['qualityAnalysis'] as Map<String, dynamic>? ?? {};
          final trendAnalysis = analysis['trendAnalysis'] as Map<String, dynamic>? ?? {};
          final streakCount = basicStats['streakCount'] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HabitHeader(habit: habit, streakCount: streakCount),
                const SizedBox(height: 16),
                _BasicStatsSection(basicStats: basicStats),
                const SizedBox(height: 16),
                _TrendSection(trendAnalysis: trendAnalysis),
                const SizedBox(height: 16),
                _TimeDistributionSection(timeAnalysis: timeAnalysis),
                const SizedBox(height: 16),
                _QualitySection(qualityAnalysis: qualityAnalysis),
                if ((analysis['relatedJournalsCount'] as int? ?? 0) > 0) ...[
                  const SizedBox(height: 16),
                  _RelatedJournalSection(
                    journalCount: analysis['relatedJournalsCount'] as int,
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text('加载失败：$error'),
          ),
        ),
      ),
    );
  }
}

class _HabitHeader extends StatelessWidget {
  final Habit habit;
  final int streakCount;

  const _HabitHeader({
    required this.habit,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                _mapHabitIcon(habit.icon),
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCategoryName(habit.category),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            _StreakBadge(streakCount: streakCount),
          ],
        ),
      ),
    );
  }

  IconData _mapHabitIcon(String iconName) {
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
        return '其他';
    }
  }
}

class _StreakBadge extends StatelessWidget {
  final int streakCount;

  const _StreakBadge({required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final color = streakCount >= 30
        ? AppColors.warning
        : streakCount >= 7
            ? AppColors.success
            : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: color),
          const SizedBox(width: 8),
          Text(
            '连击 $streakCount 天',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicStatsSection extends StatelessWidget {
  final Map<String, dynamic> basicStats;

  const _BasicStatsSection({required this.basicStats});

  @override
  Widget build(BuildContext context) {
    final totalCheckIns = basicStats['totalCheckIns'] as int? ?? 0;
    final streakCount = basicStats['streakCount'] as int? ?? 0;
    final maxStreak = basicStats['maxStreakCount'] as int? ?? 0;
    final daysSinceStart = basicStats['daysSinceStart'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '关键指标',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: '总打卡次数',
                    value: '$totalCheckIns',
                    icon: Icons.fact_check,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    title: '当前连击',
                    value: '$streakCount 天',
                    icon: Icons.local_fire_department,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: '最长连击',
                    value: '$maxStreak 天',
                    icon: Icons.emoji_events,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    title: '坚持天数',
                    value: '$daysSinceStart 天',
                    icon: Icons.calendar_today,
                    color: AppColors.info,
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

class _TrendSection extends StatelessWidget {
  final Map<String, dynamic> trendAnalysis;

  const _TrendSection({required this.trendAnalysis});

  @override
  Widget build(BuildContext context) {
    final weeklyData = trendAnalysis['weeklyData'] as Map<String, dynamic>? ?? {};
    if (weeklyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = weeklyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = entries.isEmpty
        ? 1.0
        : entries.map((e) => (e.value as num).toDouble()).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近4周趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue == 0 ? 1 : maxValue * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${entries[group.x.toInt()].key}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} 次',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            entries[index].key.replaceAll('week', '第') + '周',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (item.value as num).toDouble(),
                          color: AppColors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeDistributionSection extends StatelessWidget {
  final Map<String, dynamic> timeAnalysis;

  const _TimeDistributionSection({required this.timeAnalysis});

  @override
  Widget build(BuildContext context) {
    final hourly = Map<String, int>.from(timeAnalysis['hourlyDistribution'] as Map? ?? {});
    final weekly = Map<String, int>.from(timeAnalysis['weeklyDistribution'] as Map? ?? {});

    if (hourly.isEmpty && weekly.isEmpty) {
      return const SizedBox.shrink();
    }

    final preferredTime = timeAnalysis['preferredTime'] as int?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '时间分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (preferredTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '最常打卡时间：$preferredTime:00',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (hourly.isNotEmpty) ...[
              const Text('按小时分布'),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: hourly.values.isEmpty
                        ? 1
                        : hourly.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) {
                            final hour = value.toInt();
                            if (hour % 3 != 0) return const SizedBox.shrink();
                            return Text('$hour');
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(24, (index) {
                      final count = hourly['$index'] ?? 0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: AppColors.info,
                            width: 6,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
            if (weekly.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('按星期分布'),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: weekly.values.isEmpty
                        ? 1
                        : weekly.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                            final index = value.toInt();
                            if (index < 0 || index >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(days[index]);
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (index) {
                      final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                      final count = weekly[days[index]] ?? 0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: AppColors.warning,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QualitySection extends StatelessWidget {
  final Map<String, dynamic> qualityAnalysis;

  const _QualitySection({required this.qualityAnalysis});

  @override
  Widget build(BuildContext context) {
    final hasData = qualityAnalysis['hasQualityData'] as bool? ?? false;
    if (!hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '质量分析',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('暂无质量评分数据，尝试在打卡时记录完成质量吧！'),
            ],
          ),
        ),
      );
    }

    final averageQuality = (qualityAnalysis['averageQuality'] as num?)?.toDouble() ?? 0.0;
    final trend = (qualityAnalysis['qualityTrend'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '质量分析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: AppColors.habit),
                const SizedBox(width: 8),
                Text(
                  '平均质量评分：${averageQuality.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (trend.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 5,
                    backgroundColor: AppColors.habit.withOpacity(0.05),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) return const SizedBox.shrink();
                            return Text(value.toInt().toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: trend.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.habit,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.habit.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RelatedJournalSection extends StatelessWidget {
  final int journalCount;

  const _RelatedJournalSection({required this.journalCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book, color: AppColors.info),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '相关日志',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '共有 $journalCount 篇日志与此习惯关联。继续记录，让习惯更有意义！',
                    style: TextStyle(color: Colors.grey[600]),
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

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
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
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}