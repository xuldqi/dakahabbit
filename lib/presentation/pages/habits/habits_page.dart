import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../providers/habit_provider.dart';
import '../../providers/check_in_provider.dart';
import '../../widgets/feedback/check_in_celebration.dart';
import '../../widgets/empty_states/recommended_habits_widget.dart';

/// 习惯管理页面
class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(habitProvider.notifier).loadHabits(),
        child: Column(
          children: [
            _buildCategoryTabs(),
            if (_searchQuery.isNotEmpty) _buildSearchBar(),
            Expanded(
              child: _buildHabitsList(habitState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/habit/create'),
        tooltip: '创建习惯',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('all', '全部'),
          const SizedBox(width: 8),
          _buildCategoryChip('health', '健康'),
          const SizedBox(width: 8),
          _buildCategoryChip('exercise', '运动'),
          const SizedBox(width: 8),
          _buildCategoryChip('study', '学习'),
          const SizedBox(width: 8),
          _buildCategoryChip('life', '生活'),
          const SizedBox(width: 8),
          _buildCategoryChip('work', '工作'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索习惯...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildHabitsList(HabitState habitState) {
    if (habitState.isLoading && habitState.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (habitState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载习惯失败',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              habitState.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(habitProvider.notifier).loadHabits(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final filteredHabits = _filterHabits(habitState.habits);

    if (filteredHabits.isEmpty) {
      if (_searchQuery.isNotEmpty || _selectedCategory != 'all') {
        // 搜索或筛选无结果
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '没有找到符合条件的习惯',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '尝试调整筛选条件或搜索关键词',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      // 空状态 - 显示推荐习惯
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.track_changes,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有习惯',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '试试这些推荐习惯，开始你的习惯养成之旅',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            RecommendedHabitsWidget(
              title: '推荐习惯',
              subtitle: '点击卡片快速创建',
              onCreateHabit: () => context.go('/habit/create'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        return _HabitCard(habit: habit);
      },
    );
  }

  List<Habit> _filterHabits(List<Habit> habits) {
    var filteredHabits = habits;

    // 按分类筛选
    if (_selectedCategory != 'all') {
      filteredHabits = filteredHabits.where((habit) => 
        habit.category == _selectedCategory
      ).toList();
    }

    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      filteredHabits = filteredHabits.where((habit) =>
        habit.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (habit.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return filteredHabits;
  }

  void _showSearch() {
    setState(() {
      _searchQuery = _searchQuery.isEmpty ? 'search' : '';
    });
  }
}

/// 习惯卡片
class _HabitCard extends ConsumerWidget {
  final Habit habit;

  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCheckedIn = ref.watch(hasCheckedInProvider(habit.id!));
    final isLoading = ref.watch(checkInProvider).isLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/habit/${habit.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: hasCheckedIn 
                        ? Colors.green 
                        : Theme.of(context).primaryColor,
                    child: Icon(
                      hasCheckedIn ? Icons.check : _getHabitIcon(habit.icon),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (habit.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            habit.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLoading) 
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasCheckedIn)
                    const Icon(Icons.check_circle, color: Colors.green, size: 28)
                  else
                    ElevatedButton(
                      onPressed: () => _checkIn(context, ref, habit),
                      child: const Text('打卡'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: _getCategoryName(habit.category),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.trending_up,
                    label: '${habit.streakCount}天',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.star,
                    label: _getImportanceName(habit.importance),
                    color: Colors.purple,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showMoreOptions(context, ref, habit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _checkIn(BuildContext context, WidgetRef ref, Habit habit) async {
    final checkInNotifier = ref.read(checkInProvider.notifier);
    final success = await checkInNotifier.checkIn(habit.id!);
    
    if (success) {
      final newStreak = (habit.streakCount) + 1;
      await CheckInCelebration.show(
        context,
        habitName: habit.name,
        streakCount: newStreak,
      );
      ref.read(habitProvider.notifier).loadHabits();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('打卡失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑习惯'),
              onTap: () {
                Navigator.pop(context);
                context.go('/habit/${habit.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('查看统计'),
              onTap: () {
                Navigator.pop(context);
                context.go('/habit/${habit.id}/statistics');
              },
            ),
            ListTile(
              leading: Icon(
                habit.isActive ? Icons.pause_circle : Icons.play_circle,
              ),
              title: Text(habit.isActive ? '暂停习惯' : '恢复习惯'),
              onTap: () {
                Navigator.pop(context);
                ref.read(habitProvider.notifier).toggleHabitActive(habit.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除习惯', style: TextStyle(color: Colors.red)),
              onTap: () => _deleteHabit(context, ref, habit),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHabit(BuildContext context, WidgetRef ref, Habit habit) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除习惯"${habit.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(habitProvider.notifier).deleteHabit(habit.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('习惯已删除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('删除失败，请重试'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getHabitIcon(String iconName) {
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
      case 'life':
        return '生活';
      case 'work':
        return '工作';
      default:
        return '其他';
    }
  }

  String _getImportanceName(HabitImportance importance) {
    switch (importance) {
      case HabitImportance.low:
        return '低';
      case HabitImportance.medium:
        return '中';
      case HabitImportance.high:
        return '高';
      case HabitImportance.veryHigh:
        return '很高';
      case HabitImportance.veryLow:
        return '很低';
    }
  }
}