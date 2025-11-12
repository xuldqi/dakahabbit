import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/journal_service.dart';
import '../../../core/services/service_locator.dart';
import 'edit_journal_page.dart';

/// 日志详情页面
class JournalDetailPage extends ConsumerStatefulWidget {
  final int journalId;

  const JournalDetailPage({
    super.key,
    required this.journalId,
  });

  @override
  ConsumerState<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends ConsumerState<JournalDetailPage> {
  Journal? _journal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  Future<void> _loadJournal() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final journalService = ServiceLocator.get<JournalService>();
      final journal = await journalService.getJournalById(widget.journalId);
      
      if (journal != null && mounted) {
        setState(() {
          _journal = journal;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志不存在')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEditPage() async {
    if (_journal == null) return;

    final result = await Navigator.push<Journal>(
      context,
      MaterialPageRoute(
        builder: (context) => EditJournalPage(journalId: widget.journalId),
      ),
    );

    // 如果编辑成功，刷新详情页面
    if (result != null) {
      setState(() {
        _journal = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('日志详情'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_journal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('日志详情'),
        ),
        body: const Center(
          child: Text('日志不存在'),
        ),
      );
    }

    final journal = _journal!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('日志详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditPage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日志标题
            Text(
              journal.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 日志元信息
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  journal.date,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.category,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  journal.getTypeDescription(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 状态标签
            Row(
              children: [
                if (journal.isFavorite)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('收藏', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                if (journal.isPinned)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin, size: 14, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text('置顶', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12)),
                      ],
                    ),
                  ),
                if (journal.isPrivate)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('私密', style: TextStyle(color: Colors.orange, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 心情信息
            if (journal.mood != null || journal.moodScore != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.mood,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  if (journal.mood != null) ...[
                    Text(
                      journal.getMoodType()?.emoji ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (journal.moodScore != null) ...[
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < journal.moodScore!
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      journal.getMoodScoreDescription(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 标签
            if (journal.getTagsList().isNotEmpty) ...[
              Text(
                '标签',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: journal.getTagsList().map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // 日志内容
            Text(
              '内容',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                journal.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // 日志统计信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '统计信息',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 16,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: 8),
                      Text('字数: ${journal.wordCount}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: 8),
                      Text('创建时间: ${journal.createdAt?.toString().substring(0, 19) ?? '未知'}'),
                    ],
                  ),
                  if (journal.updatedAt != journal.createdAt) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.update,
                          size: 16,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(width: 8),
                        Text('更新时间: ${journal.updatedAt?.toString().substring(0, 19) ?? '未知'}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}