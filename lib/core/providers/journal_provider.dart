import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/journal_service.dart';
import '../services/service_locator.dart';
import '../utils/logger.dart';

/// 日志状态
class JournalState {
  final List<Journal> journals;
  final List<Journal> todayJournals;
  final List<Journal> favoriteJournals;
  final List<Journal> pinnedJournals;
  final List<String> allTags;
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? error;

  const JournalState({
    this.journals = const [],
    this.todayJournals = const [],
    this.favoriteJournals = const [],
    this.pinnedJournals = const [],
    this.allTags = const [],
    this.stats = const {},
    this.isLoading = false,
    this.error,
  });

  JournalState copyWith({
    List<Journal>? journals,
    List<Journal>? todayJournals,
    List<Journal>? favoriteJournals,
    List<Journal>? pinnedJournals,
    List<String>? allTags,
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return JournalState(
      journals: journals ?? this.journals,
      todayJournals: todayJournals ?? this.todayJournals,
      favoriteJournals: favoriteJournals ?? this.favoriteJournals,
      pinnedJournals: pinnedJournals ?? this.pinnedJournals,
      allTags: allTags ?? this.allTags,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 日志提供者
class JournalNotifier extends StateNotifier<JournalState> {
  final JournalService _journalService;

  JournalNotifier(this._journalService) : super(const JournalState()) {
    _initialize();
  }

  /// 初始化
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await Future.wait([
        loadAllJournals(),
        loadTodayJournals(),
        loadAllTags(),
        loadStats(),
      ]);
      
      state = state.copyWith(isLoading: false);
      Logger.info('日志提供者初始化完成');
      
    } catch (e, stackTrace) {
      Logger.error('日志提供者初始化失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: '初始化失败: $e');
    }
  }

  /// 刷新所有数据
  Future<void> refresh() async {
    await _initialize();
  }

  /// 加载所有日志
  Future<void> loadAllJournals({int? limit, int? offset}) async {
    try {
      final journals = await _journalService.getAllJournals(
        limit: limit,
        offset: offset,
      );
      
      state = state.copyWith(
        journals: offset == 0 || offset == null ? journals : [...state.journals, ...journals],
      );
      
    } catch (e, stackTrace) {
      Logger.error('加载所有日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '加载日志失败: $e');
    }
  }

  /// 加载今天的日志
  Future<void> loadTodayJournals() async {
    try {
      final todayJournals = await _journalService.getTodayJournals();
      state = state.copyWith(todayJournals: todayJournals);
    } catch (e, stackTrace) {
      Logger.error('加载今天日志失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 加载收藏的日志
  Future<void> loadFavoriteJournals() async {
    try {
      final favoriteJournals = await _journalService.getFavoriteJournals();
      state = state.copyWith(favoriteJournals: favoriteJournals);
    } catch (e, stackTrace) {
      Logger.error('加载收藏日志失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 加载置顶的日志
  Future<void> loadPinnedJournals() async {
    try {
      final pinnedJournals = await _journalService.getPinnedJournals();
      state = state.copyWith(pinnedJournals: pinnedJournals);
    } catch (e, stackTrace) {
      Logger.error('加载置顶日志失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 加载所有标签
  Future<void> loadAllTags() async {
    try {
      final allTags = await _journalService.getAllTags();
      state = state.copyWith(allTags: allTags);
    } catch (e, stackTrace) {
      Logger.error('加载所有标签失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 加载统计数据
  Future<void> loadStats() async {
    try {
      final stats = await _journalService.getJournalStats();
      state = state.copyWith(stats: stats);
    } catch (e, stackTrace) {
      Logger.error('加载统计数据失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 创建日志
  Future<Journal?> createJournal({
    required String title,
    required String content,
    DateTime? date,
    JournalType type = JournalType.daily,
    List<String>? tags,
    MoodType? mood,
    int? moodScore,
    String? weather,
    List<String>? photos,
    bool isPrivate = false,
    bool isFavorite = false,
    bool isPinned = false,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final journal = await _journalService.createJournal(
        title: title,
        content: content,
        date: date,
        type: type,
        tags: tags,
        mood: mood,
        moodScore: moodScore,
        weather: weather,
        photos: photos,
        isPrivate: isPrivate,
        isFavorite: isFavorite,
        isPinned: isPinned,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData,
      );

      // 刷新相关数据
      await Future.wait([
        loadAllJournals(),
        loadTodayJournals(),
        loadAllTags(),
        loadStats(),
      ]);

      return journal;

    } catch (e, stackTrace) {
      Logger.error('创建日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '创建日志失败: $e');
      return null;
    }
  }

  /// 创建习惯相关日志
  Future<Journal?> createHabitJournal({
    required String title,
    required String content,
    required DateTime date,
    List<String>? tags,
    MoodType? mood,
    int? moodScore,
    String? weather,
    List<String>? photos,
    bool isPrivate = false,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final journal = await _journalService.createHabitJournal(
        title: title,
        content: content,
        date: date,
        tags: tags,
        mood: mood,
        moodScore: moodScore,
        weather: weather,
        photos: photos,
        isPrivate: isPrivate,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData,
      );

      // 刷新相关数据
      await Future.wait([
        loadAllJournals(),
        loadTodayJournals(),
        loadAllTags(),
        loadStats(),
      ]);

      return journal;

    } catch (e, stackTrace) {
      Logger.error('创建习惯日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '创建习惯日志失败: $e');
      return null;
    }
  }

  /// 更新日志
  Future<Journal?> updateJournal(
    int journalId, {
    String? title,
    String? content,
    DateTime? date,
    JournalType? type,
    List<String>? tags,
    MoodType? mood,
    int? moodScore,
    String? weather,
    List<String>? photos,
    bool? isPrivate,
    bool? isFavorite,
    bool? isPinned,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final updatedJournal = await _journalService.updateJournal(
        journalId,
        title: title,
        content: content,
        date: date,
        type: type,
        tags: tags,
        mood: mood,
        moodScore: moodScore,
        weather: weather,
        photos: photos,
        isPrivate: isPrivate,
        isFavorite: isFavorite,
        isPinned: isPinned,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData,
      );

      // 刷新相关数据
      await Future.wait([
        loadAllJournals(),
        loadTodayJournals(),
        if (isFavorite == true || 
            state.favoriteJournals.any((j) => j.id == journalId)) 
          loadFavoriteJournals(),
        if (isPinned == true || 
            state.pinnedJournals.any((j) => j.id == journalId)) 
          loadPinnedJournals(),
        loadAllTags(),
        loadStats(),
      ]);

      return updatedJournal;

    } catch (e, stackTrace) {
      Logger.error('更新日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '更新日志失败: $e');
      return null;
    }
  }

  /// 删除日志
  Future<bool> deleteJournal(int journalId) async {
    try {
      final success = await _journalService.deleteJournal(journalId);
      
      if (success) {
        // 刷新相关数据
        await Future.wait([
          loadAllJournals(),
          loadTodayJournals(),
          loadFavoriteJournals(),
          loadPinnedJournals(),
          loadStats(),
        ]);
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('删除日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '删除日志失败: $e');
      return false;
    }
  }

  /// 恢复日志
  Future<bool> restoreJournal(int journalId) async {
    try {
      final success = await _journalService.restoreJournal(journalId);
      
      if (success) {
        // 刷新相关数据
        await loadAllJournals();
        await loadStats();
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('恢复日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '恢复日志失败: $e');
      return false;
    }
  }

  /// 切换收藏状态
  Future<Journal?> toggleFavorite(int journalId) async {
    try {
      final updatedJournal = await _journalService.toggleFavorite(journalId);
      
      // 刷新相关数据
      await Future.wait([
        loadAllJournals(),
        loadFavoriteJournals(),
        loadStats(),
      ]);

      return updatedJournal;

    } catch (e, stackTrace) {
      Logger.error('切换收藏状态失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '切换收藏状态失败: $e');
      return null;
    }
  }

  /// 切换置顶状态
  Future<Journal?> togglePin(int journalId) async {
    try {
      final updatedJournal = await _journalService.togglePin(journalId);
      
      // 刷新相关数据
      await Future.wait([
        loadAllJournals(),
        loadPinnedJournals(),
      ]);

      return updatedJournal;

    } catch (e, stackTrace) {
      Logger.error('切换置顶状态失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '切换置顶状态失败: $e');
      return null;
    }
  }

  /// 搜索日志
  Future<List<Journal>> searchJournals(String keyword) async {
    try {
      return await _journalService.searchJournals(keyword);
    } catch (e, stackTrace) {
      Logger.error('搜索日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '搜索日志失败: $e');
      return [];
    }
  }

  /// 根据标签获取日志
  Future<List<Journal>> getJournalsByTag(String tag) async {
    try {
      return await _journalService.getJournalsByTag(tag);
    } catch (e, stackTrace) {
      Logger.error('根据标签获取日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '根据标签获取日志失败: $e');
      return [];
    }
  }

  /// 根据日期获取日志
  Future<List<Journal>> getJournalsByDate(DateTime date) async {
    try {
      return await _journalService.getJournalsByDate(date);
    } catch (e, stackTrace) {
      Logger.error('根据日期获取日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '根据日期获取日志失败: $e');
      return [];
    }
  }

  /// 根据类型获取日志
  Future<List<Journal>> getJournalsByType(JournalType type) async {
    try {
      return await _journalService.getJournalsByType(type);
    } catch (e, stackTrace) {
      Logger.error('根据类型获取日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '根据类型获取日志失败: $e');
      return [];
    }
  }

  /// 创建习惯-日志关联
  Future<HabitJournalRelation?> createHabitJournalRelation({
    required int habitId,
    required int journalId,
    String relationType = 'general',
    String? relationNote,
    double weight = 1.0,
    bool isAutoGenerated = false,
    bool isConfirmed = true,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      return await _journalService.createHabitJournalRelation(
        habitId: habitId,
        journalId: journalId,
        relationType: relationType,
        relationNote: relationNote,
        weight: weight,
        isAutoGenerated: isAutoGenerated,
        isConfirmed: isConfirmed,
        tags: tags,
        extraData: extraData,
      );
    } catch (e, stackTrace) {
      Logger.error('创建习惯-日志关联失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '创建关联失败: $e');
      return null;
    }
  }

  /// 删除习惯-日志关联
  Future<bool> deleteHabitJournalRelation(int relationId) async {
    try {
      return await _journalService.deleteHabitJournalRelation(relationId);
    } catch (e, stackTrace) {
      Logger.error('删除习惯-日志关联失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '删除关联失败: $e');
      return false;
    }
  }

  /// 获取习惯关联的日志
  Future<List<Journal>> getJournalsByHabit(int habitId) async {
    try {
      return await _journalService.getJournalsByHabit(habitId);
    } catch (e, stackTrace) {
      Logger.error('获取习惯关联日志失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '获取习惯关联日志失败: $e');
      return [];
    }
  }

  /// 获取日志关联的习惯
  Future<List<Habit>> getHabitsByJournal(int journalId) async {
    try {
      return await _journalService.getHabitsByJournal(journalId);
    } catch (e, stackTrace) {
      Logger.error('获取日志关联习惯失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '获取日志关联习惯失败: $e');
      return [];
    }
  }

  /// 自动创建关联
  Future<List<HabitJournalRelation>> autoCreateRelations(int journalId) async {
    try {
      return await _journalService.autoCreateRelations(journalId);
    } catch (e, stackTrace) {
      Logger.error('自动创建关联失败', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '自动创建关联失败: $e');
      return [];
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 日志提供者
final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final journalService = ServiceLocator.get<JournalService>();
  return JournalNotifier(journalService);
});

/// 当前选中的日志提供者
final selectedJournalProvider = StateProvider<Journal?>((ref) => null);

/// 日志搜索关键词提供者
final journalSearchProvider = StateProvider<String>((ref) => '');

/// 日志过滤器提供者
final journalFilterProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'type': null,
  'tags': <String>[],
  'dateRange': null,
  'isFavorite': false,
  'isPinned': false,
});