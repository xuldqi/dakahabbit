import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/journal_provider.dart';

/// 创建日志页面
class CreateJournalPage extends ConsumerStatefulWidget {
  final List<int>? relatedHabitIds;
  final DateTime? initialDate;

  const CreateJournalPage({
    super.key,
    this.relatedHabitIds,
    this.initialDate,
  });

  @override
  ConsumerState<CreateJournalPage> createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends ConsumerState<CreateJournalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  late DateTime _selectedDate;
  JournalType _selectedType = JournalType.daily;
  MoodType? _selectedMood;
  int? _moodScore;
  bool _isPrivate = false;
  bool _isFavorite = false;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList()
          : null;

      final journal = await ref.read(journalProvider.notifier).createJournal(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        date: _selectedDate,
        type: _selectedType,
        tags: tags,
        mood: _selectedMood,
        moodScore: _moodScore,
        isPrivate: _isPrivate,
        isFavorite: _isFavorite,
        isPinned: _isPinned,
      );

      if (journal != null && mounted) {
        Navigator.of(context).pop(journal);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志创建成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建日志'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveJournal,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题输入框
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '日志标题',
                  hintText: '请输入日志标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入日志标题';
                  }
                  if (value.trim().length > 100) {
                    return '标题不能超过100个字符';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // 内容输入框
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '日志内容',
                  hintText: '记录今天的想法和感受...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入日志内容';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 日期选择
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '日期: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: const Text('选择日期'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 日志类型选择
              DropdownButtonFormField<JournalType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: '日志类型',
                  border: OutlineInputBorder(),
                ),
                items: JournalType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDescription(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 心情选择
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '心情',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...MoodType.values.map((mood) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = _selectedMood == mood ? null : mood;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedMood == mood
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),

              // 心情评分
              if (_selectedMood != null) ...[
                Text(
                  '心情评分',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final score = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _moodScore = _moodScore == score ? null : score;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Icon(
                          _moodScore != null && _moodScore! >= score
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],

              // 标签输入
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '标签',
                  hintText: '用逗号分隔多个标签，如：工作,学习,运动',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 开关选项
              SwitchListTile(
                title: const Text('私密日志'),
                subtitle: const Text('只有自己可以查看'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('收藏'),
                subtitle: const Text('添加到收藏列表'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('置顶'),
                subtitle: const Text('在日志列表中置顶显示'),
                value: _isPinned,
                onChanged: (value) {
                  setState(() {
                    _isPinned = value;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeDescription(JournalType type) {
    switch (type) {
      case JournalType.daily:
        return '日常';
      case JournalType.habit:
        return '习惯相关';
      case JournalType.reflection:
        return '反思';
      case JournalType.goal:
        return '目标';
      case JournalType.achievement:
        return '成就';
    }
  }
}