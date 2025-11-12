import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../providers/habit_provider.dart';
import '../../../app/app_colors.dart';

/// 创建习惯页面 - 分步表单
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
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _currentStep = 0;
  String _category = 'health';
  String _icon = 'default';
  HabitImportance _importance = HabitImportance.medium;
  HabitDifficulty _difficulty = HabitDifficulty.medium;
  HabitCycleType _cycleType = HabitCycleType.daily;
  
  bool _isLoading = false;

  final List<String> _stepTitles = [
    '基本信息',
    '时间设置',
    '高级设置',
    '确认创建',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建习惯 (${_currentStep + 1}/${_stepTitles.length})'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: Column(
        children: [
          // 进度指示器
          _buildProgressIndicator(),
          
          // 表单内容
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildTimeSettingsStep(),
                  _buildAdvancedSettingsStep(),
                  _buildConfirmStep(),
                ],
              ),
            ),
          ),
          
          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: List.generate(
              _stepTitles.length,
              (index) => Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _currentStep
                            ? AppColors.primary
                            : Colors.grey[300],
                        border: Border.all(
                          color: index < _currentStep
                              ? AppColors.primary
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: index < _currentStep
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index == _currentStep
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: index <= _currentStep
                            ? AppColors.primary
                            : Colors.grey[600],
                        fontWeight: index == _currentStep
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 进度条
          LinearProgressIndicator(
            value: (_currentStep + 1) / _stepTitles.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '让我们开始创建你的习惯',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '首先，告诉我们这个习惯的基本信息',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 24),
          _buildCategoryField(),
        ],
      ),
    );
  }

  Widget _buildTimeSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置执行时间',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '选择习惯的执行频率和时间范围',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildCycleTypeField(),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '高级设置',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '设置习惯的重要性和难度等级',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildImportanceField(),
          const SizedBox(height: 24),
          _buildDifficultyField(),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '确认创建',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '请确认以下信息，确认无误后点击创建',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmItem('习惯名称', _nameController.text),
                  const Divider(),
                  if (_descriptionController.text.isNotEmpty) ...[
                    _buildConfirmItem('描述', _descriptionController.text),
                    const Divider(),
                  ],
                  _buildConfirmItem('分类', _getCategoryName(_category)),
                  const Divider(),
                  _buildConfirmItem('执行频率', _getCycleTypeName(_cycleType)),
                  const Divider(),
                  _buildConfirmItem('重要性', _getImportanceName(_importance)),
                  const Divider(),
                  _buildConfirmItem('难度', _getDifficultyName(_difficulty)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('上一步'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep > 0 ? 1 : 0,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == _stepTitles.length - 1
                            ? '创建习惯'
                            : '下一步',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // 验证第一步
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 最后一步，创建习惯
      _saveHabit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '习惯名称 *',
        hintText: '例如：每天喝水8杯',
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
        labelText: '习惯描述（可选）',
        hintText: '简单描述一下这个习惯',
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
        const Text(
          '选择分类 *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryChip('health', '健康', Icons.favorite),
            _buildCategoryChip('exercise', '运动', Icons.fitness_center),
            _buildCategoryChip('study', '学习', Icons.school),
            _buildCategoryChip('work', '工作', Icons.work),
            _buildCategoryChip('life', '生活', Icons.home),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String value, String label, IconData icon) {
    final isSelected = _category == value;
    return InkWell(
      onTap: () {
        setState(() {
          _category = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '执行频率 *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...HabitCycleType.values.map((type) => RadioListTile<HabitCycleType>(
          title: Text(_getCycleTypeName(type)),
          subtitle: Text(_getCycleTypeDescription(type)),
          value: type,
          groupValue: _cycleType,
          onChanged: (value) {
            setState(() {
              _cycleType = value!;
            });
          },
        )),
      ],
    );
  }

  Widget _buildImportanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '重要性',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...HabitImportance.values.map((importance) => RadioListTile<HabitImportance>(
          title: Text(_getImportanceName(importance)),
          value: importance,
          groupValue: _importance,
          onChanged: (value) {
            setState(() {
              _importance = value!;
            });
          },
        )),
      ],
    );
  }

  Widget _buildDifficultyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '难度',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        ...HabitDifficulty.values.map((difficulty) => RadioListTile<HabitDifficulty>(
          title: Text(_getDifficultyName(difficulty)),
          value: difficulty,
          groupValue: _difficulty,
          onChanged: (value) {
            setState(() {
              _difficulty = value!;
            });
          },
        )),
      ],
    );
  }

  String _getCategoryName(String category) {
    const names = {
      'health': '健康',
      'exercise': '运动',
      'study': '学习',
      'work': '工作',
      'life': '生活',
    };
    return names[category] ?? '其他';
  }

  String _getCycleTypeName(HabitCycleType type) {
    switch (type) {
      case HabitCycleType.daily:
        return '每天';
      case HabitCycleType.weekly:
        return '每周';
      case HabitCycleType.monthly:
        return '每月';
      case HabitCycleType.custom:
        return '自定义';
    }
  }

  String _getCycleTypeDescription(HabitCycleType type) {
    switch (type) {
      case HabitCycleType.daily:
        return '每天执行一次';
      case HabitCycleType.weekly:
        return '每周执行一次';
      case HabitCycleType.monthly:
        return '每月执行一次';
      case HabitCycleType.custom:
        return '自定义执行频率';
    }
  }

  String _getImportanceName(HabitImportance importance) {
    switch (importance) {
      case HabitImportance.veryLow:
        return '很低';
      case HabitImportance.low:
        return '低';
      case HabitImportance.medium:
        return '中等';
      case HabitImportance.high:
        return '高';
      case HabitImportance.veryHigh:
        return '很高';
    }
  }

  String _getDifficultyName(HabitDifficulty difficulty) {
    switch (difficulty) {
      case HabitDifficulty.easy:
        return '简单';
      case HabitDifficulty.medium:
        return '中等';
      case HabitDifficulty.hard:
        return '困难';
    }
  }

  Future<void> _saveHabit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habit = Habit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        icon: _icon,
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
          SnackBar(
            content: Text('习惯"${habit.name}"创建成功！'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('创建失败，请重试'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败：$e'),
            backgroundColor: AppColors.error,
          ),
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
