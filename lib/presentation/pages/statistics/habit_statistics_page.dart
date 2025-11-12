import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 单个习惯统计页面
class HabitStatisticsPage extends ConsumerWidget {
  final int habitId;

  const HabitStatisticsPage({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯统计'),
      ),
      body: const Center(
        child: Text('习惯统计页面 - 开发中'),
      ),
    );
  }
}