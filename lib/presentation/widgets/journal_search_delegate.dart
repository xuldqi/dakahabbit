import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/providers/journal_provider.dart';

/// 日志搜索代理
class JournalSearchDelegate extends SearchDelegate<Journal?> {
  JournalSearchDelegate()
      : super(
          searchFieldLabel: '搜索日志标题或内容',
          keyboardType: TextInputType.text,
        );

  @override
  String get searchFieldLabel => '搜索日志标题或内容';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('请输入搜索关键词'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        return FutureBuilder<List<Journal>>(
          future: ref.read(journalProvider.notifier).searchJournals(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('搜索失败: ${snapshot.error}'),
              );
            }

            final journals = snapshot.data ?? [];

            if (journals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '没有找到相关日志',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '尝试使用其他关键词',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final journal = journals[index];
                return _SearchResultItem(
                  journal: journal,
                  query: query,
                  onTap: () => close(context, journal),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Consumer(
        builder: (context, ref, child) {
          final journalState = ref.watch(journalProvider);
          final recentJournals = journalState.journals.take(5).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (journalState.allTags.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '热门标签',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: journalState.allTags.take(10).map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          query = tag;
                          showResults(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (recentJournals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '最近的日志',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...recentJournals.map((journal) {
                  return ListTile(
                    title: Text(
                      journal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      journal.getContentPreview(maxLength: 50),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: const Icon(Icons.history),
                    onTap: () => close(context, journal),
                  );
                }).toList(),
              ],
            ],
          );
        },
      );
    }

    // 实时搜索建议
    return Consumer(
      builder: (context, ref, child) {
        if (query.length < 2) {
          return const Center(
            child: Text('请至少输入2个字符'),
          );
        }

        return FutureBuilder<List<Journal>>(
          future: ref.read(journalProvider.notifier).searchJournals(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final journals = snapshot.data ?? [];
            final suggestions = journals.take(5).toList();

            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final journal = suggestions[index];
                return ListTile(
                  title: Text(
                    journal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    journal.getContentPreview(maxLength: 50),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(Icons.article),
                  onTap: () => close(context, journal),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 搜索结果项
class _SearchResultItem extends StatelessWidget {
  final Journal journal;
  final String query;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.journal,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          journal.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              journal.getContentPreview(maxLength: 100),
              maxLines: 3,
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
        leading: CircleAvatar(
          child: Text(
            journal.title.isNotEmpty ? journal.title[0] : '日',
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}