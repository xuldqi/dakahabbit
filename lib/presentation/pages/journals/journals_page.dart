import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/journal_provider.dart';
import '../../../core/models/models.dart';
import '../../widgets/journal_search_delegate.dart';
import 'create_journal_page.dart';
import 'journal_detail_page.dart';

/// 日志管理页面
class JournalsPage extends ConsumerStatefulWidget {
  const JournalsPage({super.key});

  @override
  ConsumerState<JournalsPage> createState() => _JournalsPageState();
}

class _JournalsPageState extends ConsumerState<JournalsPage> {
  @override
  void initState() {
    super.initState();
    // 页面初始化时刷新数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journalProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: JournalSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: journalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        journalState.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(journalProvider.notifier).refresh(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(journalProvider.notifier).refresh(),
                  child: journalState.journals.isEmpty
                      ? const Center(
                          child: Text('还没有日志，点击右下角按钮创建第一篇日志'),
                        )
                      : ListView.builder(
                          itemCount: journalState.journals.length,
                          itemBuilder: (context, index) {
                            final journal = journalState.journals[index];
                            return _JournalListItem(journal: journal);
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateJournalPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 日志列表项
class _JournalListItem extends ConsumerWidget {
  final Journal journal;
  
  const _JournalListItem({required this.journal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          journal.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              journal.getContentPreview(maxLength: 80),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  journal.date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  journal.getTypeDescription(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (journal.isFavorite) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.red,
                  ),
                ],
                if (journal.isPinned) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'favorite':
                await ref.read(journalProvider.notifier).toggleFavorite(journal.id!);
                break;
              case 'pin':
                await ref.read(journalProvider.notifier).togglePin(journal.id!);
                break;
              case 'delete':
                _showDeleteDialog(context, ref, journal);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(journal.isFavorite ? Icons.favorite : Icons.favorite_border),
                  const SizedBox(width: 8),
                  Text(journal.isFavorite ? '取消收藏' : '收藏'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(journal.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                  const SizedBox(width: 8),
                  Text(journal.isPinned ? '取消置顶' : '置顶'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalDetailPage(journalId: journal.id!),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Journal journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除日志「${journal.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(journalProvider.notifier).deleteJournal(journal.id!);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}