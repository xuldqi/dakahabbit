import '../models/models.dart';
import '../repositories/journal_repository.dart';
import '../repositories/habit_journal_relation_repository.dart';
import '../repositories/habit_repository.dart';
import '../utils/logger.dart';
import '../utils/time_utils.dart';

/// 日志管理服务
class JournalService {
  final JournalRepository _journalRepository;
  final HabitJournalRelationRepository _relationRepository;
  final HabitRepository _habitRepository;

  JournalService(
    this._journalRepository,
    this._relationRepository,
    this._habitRepository,
  );

  /// 创建日志
  Future<Journal> createJournal({
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
      Logger.info('创建日志: $title');

      // 验证输入参数
      _validateJournalInput(
        title: title,
        content: content,
        moodScore: moodScore,
        tags: tags,
        photos: photos,
      );

      final journal = Journal.forToday(
        title: title,
        content: content,
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

      // 如果指定了日期，使用指定日期
      final finalJournal = date != null 
          ? journal.copyWith(date: TimeUtils.formatDate(date))
          : journal;

      final createdJournal = await _journalRepository.create(finalJournal);

      Logger.info('日志创建成功: ID=${createdJournal.id}');
      return createdJournal;

    } catch (e, stackTrace) {
      Logger.error('创建日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 创建习惯相关日志
  Future<Journal> createHabitJournal({
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
      Logger.info('创建习惯相关日志: $title');

      // 验证输入参数
      _validateJournalInput(
        title: title,
        content: content,
        moodScore: moodScore,
        tags: tags,
        photos: photos,
      );

      final journal = Journal.forHabit(
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

      final createdJournal = await _journalRepository.create(journal);

      Logger.info('习惯相关日志创建成功: ID=${createdJournal.id}');
      return createdJournal;

    } catch (e, stackTrace) {
      Logger.error('创建习惯相关日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 更新日志
  Future<Journal> updateJournal(
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
      Logger.info('更新日志: ID=$journalId');

      final existingJournal = await _journalRepository.getById(journalId);
      if (existingJournal == null) {
        throw Exception('日志不存在');
      }

      // 验证更新参数
      if (title != null || content != null || moodScore != null || tags != null || photos != null) {
        _validateJournalInput(
          title: title ?? existingJournal.title,
          content: content ?? existingJournal.content,
          moodScore: moodScore ?? existingJournal.moodScore,
          tags: tags,
          photos: photos,
        );
      }

      // 重新计算字数
      final updatedContent = content ?? existingJournal.content;
      final wordCount = updatedContent.replaceAll(RegExp(r'\s+'), '').length;

      final updatedJournal = existingJournal.copyWith(
        title: title?.trim(),
        content: updatedContent.trim(),
        date: date != null ? TimeUtils.formatDate(date) : null,
        type: type,
        tags: tags != null ? existingJournal.setTagsList(tags) : null,
        mood: mood?.name,
        moodScore: moodScore,
        weather: weather,
        photos: photos != null ? existingJournal.setPhotosList(photos) : null,
        wordCount: wordCount,
        isPrivate: isPrivate,
        isFavorite: isFavorite,
        isPinned: isPinned,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        extraData: extraData != null ? existingJournal.setExtraDataMap(extraData) : null,
      );

      final result = await _journalRepository.update(updatedJournal);

      Logger.info('日志更新成功');
      return result;

    } catch (e, stackTrace) {
      Logger.error('更新日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除日志
  Future<bool> deleteJournal(int journalId) async {
    try {
      Logger.info('删除日志: ID=$journalId');

      final journal = await _journalRepository.getById(journalId);
      if (journal == null) {
        Logger.warning('要删除的日志不存在: ID=$journalId');
        return false;
      }

      // 删除相关的关联关系
      await _relationRepository.deleteByJournalId(journalId);

      final success = await _journalRepository.delete(journalId);

      if (success) {
        Logger.info('日志删除成功: ${journal.title}');
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('删除日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 恢复已删除的日志
  Future<bool> restoreJournal(int journalId) async {
    try {
      Logger.info('恢复日志: ID=$journalId');

      final success = await _journalRepository.restore(journalId);

      if (success) {
        Logger.info('日志恢复成功');
      }

      return success;

    } catch (e, stackTrace) {
      Logger.error('恢复日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志详情
  Future<Journal?> getJournalById(int journalId) async {
    try {
      return await _journalRepository.getById(journalId);
    } catch (e, stackTrace) {
      Logger.error('获取日志详情失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有日志
  Future<List<Journal>> getAllJournals({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    try {
      return await _journalRepository.getAll(
        limit: limit,
        offset: offset,
      );
    } catch (e, stackTrace) {
      Logger.error('获取所有日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取今天的日志
  Future<List<Journal>> getTodayJournals() async {
    try {
      return await _journalRepository.getTodayJournals();
    } catch (e, stackTrace) {
      Logger.error('获取今天日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取最近N天的日志
  Future<List<Journal>> getRecentJournals(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      return await _journalRepository.getByDateRange(
        startDate: TimeUtils.formatDate(startDate),
        endDate: TimeUtils.formatDate(endDate),
      );
    } catch (e, stackTrace) {
      Logger.error('获取最近日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据日期获取日志
  Future<List<Journal>> getJournalsByDate(DateTime date) async {
    try {
      final dateStr = TimeUtils.formatDate(date);
      return await _journalRepository.getByDate(dateStr);
    } catch (e, stackTrace) {
      Logger.error('根据日期获取日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据日期范围获取日志
  Future<List<Journal>> getJournalsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final startDateStr = TimeUtils.formatDate(startDate);
      final endDateStr = TimeUtils.formatDate(endDate);
      return await _journalRepository.getByDateRange(
        startDate: startDateStr,
        endDate: endDateStr,
      );
    } catch (e, stackTrace) {
      Logger.error('根据日期范围获取日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据类型获取日志
  Future<List<Journal>> getJournalsByType(JournalType type) async {
    try {
      return await _journalRepository.getByType(type);
    } catch (e, stackTrace) {
      Logger.error('根据类型获取日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 搜索日志
  Future<List<Journal>> searchJournals(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return [];
      }
      return await _journalRepository.search(keyword.trim());
    } catch (e, stackTrace) {
      Logger.error('搜索日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 根据标签获取日志
  Future<List<Journal>> getJournalsByTag(String tag) async {
    try {
      return await _journalRepository.searchByTag(tag);
    } catch (e, stackTrace) {
      Logger.error('根据标签获取日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取收藏的日志
  Future<List<Journal>> getFavoriteJournals() async {
    try {
      return await _journalRepository.getFavorites();
    } catch (e, stackTrace) {
      Logger.error('获取收藏日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取置顶的日志
  Future<List<Journal>> getPinnedJournals() async {
    try {
      return await _journalRepository.getPinned();
    } catch (e, stackTrace) {
      Logger.error('获取置顶日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换收藏状态
  Future<Journal> toggleFavorite(int journalId) async {
    try {
      Logger.info('切换日志收藏状态: ID=$journalId');
      return await _journalRepository.toggleFavorite(journalId);
    } catch (e, stackTrace) {
      Logger.error('切换日志收藏状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 切换置顶状态
  Future<Journal> togglePin(int journalId) async {
    try {
      Logger.info('切换日志置顶状态: ID=$journalId');
      return await _journalRepository.togglePinned(journalId);
    } catch (e, stackTrace) {
      Logger.error('切换日志置顶状态失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取所有标签
  Future<List<String>> getAllTags() async {
    try {
      return await _journalRepository.getAllTags();
    } catch (e, stackTrace) {
      Logger.error('获取所有标签失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 创建习惯-日志关联
  Future<HabitJournalRelation> createHabitJournalRelation({
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
      Logger.info('创建习惯-日志关联: 习惯ID=$habitId, 日志ID=$journalId');

      // 验证习惯和日志是否存在
      final habit = await _habitRepository.getById(habitId);
      if (habit == null) {
        throw Exception('习惯不存在');
      }

      final journal = await _journalRepository.getById(journalId);
      if (journal == null) {
        throw Exception('日志不存在');
      }

      // 检查关联是否已存在
      final existingRelation = await _relationRepository.getByHabitAndJournal(habitId, journalId);
      if (existingRelation != null) {
        throw Exception('该习惯和日志已经关联');
      }

      // 创建临时对象用于调用辅助方法
      final tempRelation = const HabitJournalRelation(
        habitId: 0,
        journalId: 0,
      );
      
      final relation = HabitJournalRelation(
        habitId: habitId,
        journalId: journalId,
        relationType: relationType,
        relationNote: relationNote?.trim(),
        weight: weight,
        isAutoGenerated: isAutoGenerated,
        isConfirmed: isConfirmed,
        tags: tags != null && tags.isNotEmpty 
            ? tempRelation.setTagsList(tags) 
            : null,
        extraData: extraData != null && extraData.isNotEmpty 
            ? tempRelation.setExtraDataMap(extraData) 
            : null,
        createdAt: DateTime.now(),
      );

      final createdRelation = await _relationRepository.create(relation);

      Logger.info('习惯-日志关联创建成功: ID=${createdRelation.id}');
      return createdRelation;

    } catch (e, stackTrace) {
      Logger.error('创建习惯-日志关联失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除习惯-日志关联
  Future<bool> deleteHabitJournalRelation(int relationId) async {
    try {
      Logger.info('删除习惯-日志关联: ID=$relationId');
      return await _relationRepository.delete(relationId);
    } catch (e, stackTrace) {
      Logger.error('删除习惯-日志关联失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 删除特定习惯和日志的关联
  Future<bool> deleteHabitJournalRelationByIds(int habitId, int journalId) async {
    try {
      Logger.info('删除特定习惯-日志关联: 习惯ID=$habitId, 日志ID=$journalId');
      return await _relationRepository.deleteByHabitAndJournal(habitId, journalId);
    } catch (e, stackTrace) {
      Logger.error('删除特定习惯-日志关联失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取习惯关联的日志
  Future<List<Journal>> getJournalsByHabit(int habitId) async {
    try {
      final results = await _relationRepository.getJournalsByHabit(habitId);
      
      final journals = <Journal>[];
      for (final result in results) {
        try {
          final journal = Journal.fromMap(result);
          journals.add(journal);
        } catch (e) {
          Logger.warning('解析习惯关联日志失败: $e');
        }
      }
      
      return journals;
    } catch (e, stackTrace) {
      Logger.error('获取习惯关联日志失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志关联的习惯
  Future<List<Habit>> getHabitsByJournal(int journalId) async {
    try {
      final results = await _relationRepository.getHabitsByJournal(journalId);
      
      final habits = <Habit>[];
      for (final result in results) {
        try {
          final habit = Habit.fromMap(result);
          habits.add(habit);
        } catch (e) {
          Logger.warning('解析日志关联习惯失败: $e');
        }
      }
      
      return habits;
    } catch (e, stackTrace) {
      Logger.error('获取日志关联习惯失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 自动创建习惯-日志关联
  Future<List<HabitJournalRelation>> autoCreateRelations(int journalId) async {
    try {
      Logger.info('自动创建习惯-日志关联: 日志ID=$journalId');

      final journal = await _journalRepository.getById(journalId);
      if (journal == null) {
        throw Exception('日志不存在');
      }

      // 获取所有激活的习惯
      final activeHabits = await _habitRepository.getActive();
      if (activeHabits.isEmpty) {
        return [];
      }

      final createdRelations = <HabitJournalRelation>[];
      
      // 基于关键词匹配创建关联
      for (final habit in activeHabits) {
        if (_shouldCreateAutoRelation(habit, journal)) {
          try {
            final relation = await createHabitJournalRelation(
              habitId: habit.id!,
              journalId: journalId,
              relationType: 'general',
              relationNote: '基于关键词自动关联',
              isAutoGenerated: true,
              isConfirmed: false,
            );
            createdRelations.add(relation);
          } catch (e) {
            Logger.warning('自动创建关联失败: 习惯ID=${habit.id}, 错误: $e');
          }
        }
      }

      Logger.info('自动创建习惯-日志关联完成: ${createdRelations.length}个');
      return createdRelations;

    } catch (e, stackTrace) {
      Logger.error('自动创建习惯-日志关联失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 获取日志统计信息
  Future<Map<String, dynamic>> getJournalStats() async {
    try {
      Logger.debug('获取日志统计信息');

      final basicStats = await _journalRepository.getStats();
      final relationStats = await _relationRepository.getStats();

      final stats = {
        ...basicStats,
        'relationStats': relationStats,
      };

      Logger.debug('日志统计信息获取成功');
      return stats;

    } catch (e, stackTrace) {
      Logger.error('获取日志统计信息失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 验证日志输入参数
  void _validateJournalInput({
    required String title,
    required String content,
    int? moodScore,
    List<String>? tags,
    List<String>? photos,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('日志标题不能为空');
    }

    if (title.trim().length > 200) {
      throw ArgumentError('日志标题不能超过200个字符');
    }

    if (content.trim().isEmpty) {
      throw ArgumentError('日志内容不能为空');
    }

    if (content.trim().length > 10000) {
      throw ArgumentError('日志内容不能超过10000个字符');
    }

    if (moodScore != null && (moodScore < 1 || moodScore > 5)) {
      throw ArgumentError('心情评分必须在1-5之间');
    }

    if (tags != null && tags.length > 20) {
      throw ArgumentError('标签数量不能超过20个');
    }

    if (photos != null && photos.length > 20) {
      throw ArgumentError('图片数量不能超过20张');
    }
  }

  /// 判断是否应该创建自动关联
  bool _shouldCreateAutoRelation(Habit habit, Journal journal) {
    // 检查习惯名称是否在日志标题或内容中出现
    final habitName = habit.name.toLowerCase();
    final journalTitle = journal.title.toLowerCase();
    final journalContent = journal.content.toLowerCase();

    if (journalTitle.contains(habitName) || journalContent.contains(habitName)) {
      return true;
    }

    // 检查习惯分类是否匹配日志标签
    final journalTags = journal.getTagsList();
    if (journalTags.contains(habit.category)) {
      return true;
    }

    // 检查关键词匹配
    final keywords = _getHabitKeywords(habit);
    for (final keyword in keywords) {
      if (journalTitle.contains(keyword) || journalContent.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  /// 获取习惯相关的关键词
  List<String> _getHabitKeywords(Habit habit) {
    final keywords = <String>[];
    
    // 基于习惯分类添加关键词
    switch (habit.category.toLowerCase()) {
      case 'health':
      case '健康':
        keywords.addAll(['健康', '锻炼', '运动', '身体', '饮食']);
        break;
      case 'exercise':
      case '运动':
        keywords.addAll(['运动', '锻炼', '健身', '跑步', '游泳']);
        break;
      case 'study':
      case '学习':
        keywords.addAll(['学习', '读书', '阅读', '知识', '技能']);
        break;
      case 'work':
      case '工作':
        keywords.addAll(['工作', '项目', '任务', '效率', '专业']);
        break;
      case 'life':
      case '生活':
        keywords.addAll(['生活', '日常', '家务', '整理', '休息']);
        break;
    }
    
    // 添加习惯名称的关键词
    if (habit.description != null && habit.description!.isNotEmpty) {
      final descriptionWords = habit.description!.split(RegExp(r'[，。！？\s]+'));
      keywords.addAll(descriptionWords.where((word) => word.length > 1));
    }
    
    return keywords;
  }
}