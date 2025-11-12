import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 习惯详情页面
class HabitDetailPage extends ConsumerWidget {
  final int habitId;

  const HabitDetailPage({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 导航到编辑页面
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('习惯详情页面 - 开发中'),
      ),
    );
  }
}