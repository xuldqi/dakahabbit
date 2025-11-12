import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../providers/habit_provider.dart';

/// 创建习惯页面
class CreateHabitPage extends ConsumerStatefulWidget {
  final String? templateId;

  const CreateHabitPage({
    super.key,
    this.templateId,
  });

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends ConsumerState<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _category = 'health';
  HabitImportance _importance = HabitImportance.medium;
  HabitDifficulty _difficulty = HabitDifficulty.medium;
  HabitCycleType _cycleType = HabitCycleType.daily;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建习惯'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
            child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildCategoryField(),
              const SizedBox(height: 16),
              _buildImportanceField(),
              const SizedBox(height: 16),
              _buildDifficultyField(),
              const SizedBox(height: 16),
              _buildCycleTypeField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  child: _isLoading 
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('正在创建...'),
                        ],
                      )
                    : const Text('创建习惯'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '习惯名称 *',
        hintText: '输入习惯名称',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.track_changes),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入习惯名称';
        }
        if (value.trim().length > 30) {
          return '习惯名称不能超过30个字符';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '习惯描述',
        hintText: '输入习惯描述（可选）',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value != null && value.length > 200) {
          return '习惯描述不能超过200个字符';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildCategoryChip('health', '健康'),
            _buildCategoryChip('exercise', '运动'),
            _buildCategoryChip('study', '学习'),
            _buildCategoryChip('work', '工作'),
            _buildCategoryChip('life', '生活'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _category == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _category = value;
          });
        }
      },
    );
  }

  Widget _buildImportanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('重要性', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<HabitImportance>(
                title: const Text('低'),
                value: HabitImportance.low,
                groupValue: _importance,
                onChanged: (value) {
                  setState(() {
                    _importance = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<HabitImportance>(
                title: const Text('中'),
                value: HabitImportance.medium,
                groupValue: _importance,
                onChanged: (value) {
                  setState(() {
                    _importance = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<HabitImportance>(
                title: const Text('高'),
                value: HabitImportance.high,
                groupValue: _importance,
                onChanged: (value) {
                  setState(() {
                    _importance = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('难度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<HabitDifficulty>(
                title: const Text('简单'),
                value: HabitDifficulty.easy,
                groupValue: _difficulty,
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<HabitDifficulty>(
                title: const Text('中等'),
                value: HabitDifficulty.medium,
                groupValue: _difficulty,
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<HabitDifficulty>(
                title: const Text('困难'),
                value: HabitDifficulty.hard,
                groupValue: _difficulty,
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCycleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('执行频率', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<HabitCycleType>(
          value: _cycleType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.schedule),
          ),
          items: const [
            DropdownMenuItem(value: HabitCycleType.daily, child: Text('每天')),
            DropdownMenuItem(value: HabitCycleType.weekly, child: Text('每周')),
            DropdownMenuItem(value: HabitCycleType.monthly, child: Text('每月')),
            DropdownMenuItem(value: HabitCycleType.custom, child: Text('自定义')),
          ],
          onChanged: (value) {
            setState(() {
              _cycleType = value!;
            });
          },
        ),
      ],
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final habit = Habit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
        category: _category,
        importance: _importance,
        difficulty: _difficulty,
        cycleType: _cycleType,
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(habitProvider.notifier).createHabit(habit);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('习惯"${habit.name}"创建成功！')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('创建失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}