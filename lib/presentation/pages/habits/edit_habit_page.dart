import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 编辑习惯页面
class EditHabitPage extends ConsumerWidget {
  final int habitId;

  const EditHabitPage({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑习惯'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 保存更改
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: const Center(
        child: Text('编辑习惯页面 - 开发中'),
      ),
    );
  }
}