import 'package:json_annotation/json_annotation.dart';
import 'habit.dart'; // 导入习惯相关的枚举

part 'habit_template.g.dart';

/// 模板使用统计
@JsonSerializable()
class TemplateStats {
  final int usageCount;           // 使用次数
  final int successRate;          // 成功率（百分比）
  final double averageStreak;     // 平均连击天数
  final DateTime? lastUsed;       // 最后使用时间
  
  const TemplateStats({
    this.usageCount = 0,
    this.successRate = 0,
    this.averageStreak = 0.0,
    this.lastUsed,
  });
  
  factory TemplateStats.fromJson(Map<String, dynamic> json) => _$TemplateStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateStatsToJson(this);
  
  /// 初始统计
  factory TemplateStats.initial() => const TemplateStats();
  
  /// 增加使用次数
  TemplateStats incrementUsage() {
    return TemplateStats(
      usageCount: usageCount + 1,
      successRate: successRate,
      averageStreak: averageStreak,
      lastUsed: DateTime.now(),
    );
  }
  
  /// 更新统计信息
  TemplateStats updateStats({
    int? successRate,
    double? averageStreak,
  }) {
    return TemplateStats(
      usageCount: usageCount,
      successRate: successRate ?? this.successRate,
      averageStreak: averageStreak ?? this.averageStreak,
      lastUsed: lastUsed,
    );
  }
}

/// 模板建议配置
@JsonSerializable()
class TemplateSuggestions {
  final List<String> reminderTimes;      // 建议提醒时间
  final int? targetDays;                 // 建议目标天数
  final int? targetTotal;                // 建议总目标次数
  final List<String> tips;               // 使用提示
  final Map<String, dynamic>? bestPractices; // 最佳实践
  
  const TemplateSuggestions({
    this.reminderTimes = const [],
    this.targetDays,
    this.targetTotal,
    this.tips = const [],
    this.bestPractices,
  });
  
  factory TemplateSuggestions.fromJson(Map<String, dynamic> json) => _$TemplateSuggestionsFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateSuggestionsToJson(this);
  
  /// 创建默认建议
  factory TemplateSuggestions.create({
    List<String>? reminderTimes,
    int? targetDays,
    int? targetTotal,
    List<String>? tips,
  }) {
    return TemplateSuggestions(
      reminderTimes: reminderTimes ?? [],
      targetDays: targetDays,
      targetTotal: targetTotal,
      tips: tips ?? [],
    );
  }
}

/// 习惯模板模型
@JsonSerializable()
class HabitTemplate {
  final int? id;
  final String name;
  final String description;
  final String icon;
  final HabitCategory category;
  
  // 默认设置
  final HabitCycleType defaultCycleType;
  final TimeRange? defaultTimeRange;
  final int? defaultDurationMinutes;
  final int defaultImportance;
  final HabitDifficulty defaultDifficulty;
  
  // 建议配置
  final TemplateSuggestions suggestions;
  
  // 模板属性
  final bool isPopular;                  // 是否热门
  final bool isRecommended;              // 是否推荐
  final bool isCustom;                   // 是否自定义模板
  final List<String> keywords;           // 搜索关键词
  final List<String> relatedTemplates;   // 相关模板ID
  
  // 统计信息
  final TemplateStats stats;
  
  // 排序和显示
  final int sortOrder;
  final String? color;                   // 主题色
  final String? backgroundImage;         // 背景图片
  
  // 扩展配置
  final Map<String, dynamic>? extraConfig;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const HabitTemplate({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.defaultCycleType = HabitCycleType.daily,
    this.defaultTimeRange,
    this.defaultDurationMinutes,
    this.defaultImportance = 3,
    this.defaultDifficulty = HabitDifficulty.medium,
    required this.suggestions,
    this.isPopular = false,
    this.isRecommended = false,
    this.isCustom = false,
    this.keywords = const [],
    this.relatedTemplates = const [],
    required this.stats,
    this.sortOrder = 0,
    this.color,
    this.backgroundImage,
    this.extraConfig,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory HabitTemplate.fromJson(Map<String, dynamic> json) => _$HabitTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$HabitTemplateToJson(this);
  
  /// 创建新模板
  factory HabitTemplate.create({
    required String name,
    required String description,
    required String icon,
    required HabitCategory category,
    HabitCycleType defaultCycleType = HabitCycleType.daily,
    TimeRange? defaultTimeRange,
    int? defaultDurationMinutes,
    int defaultImportance = 3,
    HabitDifficulty defaultDifficulty = HabitDifficulty.medium,
    TemplateSuggestions? suggestions,
    bool isPopular = false,
    bool isRecommended = false,
    bool isCustom = false,
    List<String>? keywords,
    List<String>? relatedTemplates,
    int sortOrder = 0,
    String? color,
    String? backgroundImage,
    Map<String, dynamic>? extraConfig,
  }) {
    final now = DateTime.now();
    return HabitTemplate(
      name: name,
      description: description,
      icon: icon,
      category: category,
      defaultCycleType: defaultCycleType,
      defaultTimeRange: defaultTimeRange,
      defaultDurationMinutes: defaultDurationMinutes,
      defaultImportance: defaultImportance,
      defaultDifficulty: defaultDifficulty,
      suggestions: suggestions ?? TemplateSuggestions.create(),
      isPopular: isPopular,
      isRecommended: isRecommended,
      isCustom: isCustom,
      keywords: keywords ?? [],
      relatedTemplates: relatedTemplates ?? [],
      stats: TemplateStats.initial(),
      sortOrder: sortOrder,
      color: color,
      backgroundImage: backgroundImage,
      extraConfig: extraConfig,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 复制并更新模板
  HabitTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    HabitCategory? category,
    HabitCycleType? defaultCycleType,
    TimeRange? defaultTimeRange,
    int? defaultDurationMinutes,
    int? defaultImportance,
    HabitDifficulty? defaultDifficulty,
    TemplateSuggestions? suggestions,
    bool? isPopular,
    bool? isRecommended,
    bool? isCustom,
    List<String>? keywords,
    List<String>? relatedTemplates,
    TemplateStats? stats,
    int? sortOrder,
    String? color,
    String? backgroundImage,
    Map<String, dynamic>? extraConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      defaultCycleType: defaultCycleType ?? this.defaultCycleType,
      defaultTimeRange: defaultTimeRange ?? this.defaultTimeRange,
      defaultDurationMinutes: defaultDurationMinutes ?? this.defaultDurationMinutes,
      defaultImportance: defaultImportance ?? this.defaultImportance,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      suggestions: suggestions ?? this.suggestions,
      isPopular: isPopular ?? this.isPopular,
      isRecommended: isRecommended ?? this.isRecommended,
      isCustom: isCustom ?? this.isCustom,
      keywords: keywords ?? this.keywords,
      relatedTemplates: relatedTemplates ?? this.relatedTemplates,
      stats: stats ?? this.stats,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      extraConfig: extraConfig ?? this.extraConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 转换为习惯对象
  Habit toHabit({
    String? customName,
    String? customDescription,
    DateTime? startDate,
    ReminderConfig? reminderConfig,
  }) {
    return Habit.create(
      name: customName ?? name,
      description: customDescription ?? description,
      icon: icon,
      category: category,
      importance: defaultImportance,
      difficulty: defaultDifficulty,
      cycleType: defaultCycleType,
      timeRange: defaultTimeRange,
      durationMinutes: defaultDurationMinutes,
      startDate: startDate,
      targetDays: suggestions.targetDays,
      targetTotal: suggestions.targetTotal,
      reminderConfig: reminderConfig ?? ReminderConfig(
        enabled: suggestions.reminderTimes.isNotEmpty,
        times: suggestions.reminderTimes,
      ),
    );
  }
  
  /// 搜索匹配
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    
    // 搜索名称
    if (name.toLowerCase().contains(lowerQuery)) return true;
    
    // 搜索描述
    if (description.toLowerCase().contains(lowerQuery)) return true;
    
    // 搜索关键词
    for (final keyword in keywords) {
      if (keyword.toLowerCase().contains(lowerQuery)) return true;
    }
    
    return false;
  }
  
  /// 是否匹配分类
  bool matchesCategory(HabitCategory? filterCategory) {
    return filterCategory == null || category == filterCategory;
  }
  
  /// 是否匹配难度
  bool matchesDifficulty(HabitDifficulty? filterDifficulty) {
    return filterDifficulty == null || defaultDifficulty == filterDifficulty;
  }
  
  /// 获取难度描述
  String get difficultyText {
    switch (defaultDifficulty) {
      case HabitDifficulty.easy:
        return '简单';
      case HabitDifficulty.medium:
        return '中等';
      case HabitDifficulty.hard:
        return '困难';
    }
  }
  
  /// 获取分类描述
  String get categoryText {
    switch (category) {
      case HabitCategory.health:
        return '健康';
      case HabitCategory.exercise:
        return '运动';
      case HabitCategory.study:
        return '学习';
      case HabitCategory.work:
        return '工作';
      case HabitCategory.life:
        return '生活';
      case HabitCategory.social:
        return '社交';
      case HabitCategory.hobby:
        return '爱好';
      case HabitCategory.other:
        return '其他';
    }
  }
  
  /// 获取使用评级
  String get usageRating {
    final count = stats.usageCount;
    if (count >= 1000) return '超热门';
    if (count >= 500) return '热门';
    if (count >= 100) return '受欢迎';
    if (count >= 10) return '常用';
    return '新模板';
  }
  
  /// 获取成功评级
  String get successRating {
    final rate = stats.successRate;
    if (rate >= 90) return '极易坚持';
    if (rate >= 80) return '容易坚持';
    if (rate >= 70) return '中等坚持';
    if (rate >= 60) return '需要毅力';
    return '挑战性强';
  }
  
  /// 记录使用
  HabitTemplate recordUsage() {
    return copyWith(
      stats: stats.incrementUsage(),
    );
  }
  
  /// 添加关键词
  HabitTemplate addKeyword(String keyword) {
    if (keywords.contains(keyword)) return this;
    return copyWith(keywords: [...keywords, keyword]);
  }
  
  /// 移除关键词
  HabitTemplate removeKeyword(String keyword) {
    if (!keywords.contains(keyword)) return this;
    return copyWith(keywords: keywords.where((k) => k != keyword).toList());
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
  
  @override
  String toString() {
    return 'HabitTemplate{id: $id, name: $name, category: $category, isPopular: $isPopular}';
  }
}

/// 预设模板数据
class DefaultHabitTemplates {
  static final List<HabitTemplate> templates = [
    // 健康类
    HabitTemplate.create(
      name: '早起',
      description: '每天早上按时起床，养成规律的作息习惯',
      icon: 'sunrise',
      category: HabitCategory.health,
      defaultTimeRange: const TimeRange(start: '06:00', end: '08:00'),
      defaultImportance: 4,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['06:00', '06:30'],
        targetDays: 30,
        tips: ['设置固定的起床时间', '前一晚早点睡觉', '起床后立即开灯'],
      ),
      isPopular: true,
      isRecommended: true,
      keywords: ['早起', '作息', '规律', '晨间'],
      color: '#FFB74D',
    ),
    
    HabitTemplate.create(
      name: '喝水8杯',
      description: '每天喝足够的水，保持身体水分平衡',
      icon: 'water_drop',
      category: HabitCategory.health,
      defaultImportance: 3,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'],
        targetTotal: 8,
        tips: ['在办公桌放一个水杯', '用APP记录饮水量', '选择自己喜欢的杯子'],
      ),
      isPopular: true,
      keywords: ['喝水', '健康', '补水', '养生'],
      color: '#42A5F5',
    ),
    
    // 运动类
    HabitTemplate.create(
      name: '运动30分钟',
      description: '每天进行30分钟的体育锻炼',
      icon: 'fitness_center',
      category: HabitCategory.exercise,
      defaultDurationMinutes: 30,
      defaultImportance: 4,
      defaultDifficulty: HabitDifficulty.medium,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['07:00', '18:00'],
        targetDays: 21,
        tips: ['选择自己喜欢的运动', '从轻松的运动开始', '找个运动伙伴'],
      ),
      isRecommended: true,
      keywords: ['运动', '锻炼', '健身', '体育'],
      color: '#66BB6A',
    ),
    
    // 学习类
    HabitTemplate.create(
      name: '读书30分钟',
      description: '每天阅读30分钟，增长知识开阔视野',
      icon: 'book',
      category: HabitCategory.study,
      defaultDurationMinutes: 30,
      defaultImportance: 3,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['20:00', '21:00'],
        targetDays: 30,
        tips: ['选择感兴趣的书籍', '创造安静的阅读环境', '做读书笔记'],
      ),
      isPopular: true,
      keywords: ['读书', '阅读', '学习', '知识'],
      color: '#AB47BC',
    ),
    
    HabitTemplate.create(
      name: '背单词',
      description: '每天背诵英语单词，提高词汇量',
      icon: 'translate',
      category: HabitCategory.study,
      defaultImportance: 3,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['08:00', '12:00', '19:00'],
        targetTotal: 20,
        tips: ['使用间隔重复记忆法', '结合例句记忆', '及时复习'],
      ),
      keywords: ['单词', '英语', '词汇', '记忆'],
      color: '#FFA726',
    ),
    
    // 生活类
    HabitTemplate.create(
      name: '整理房间',
      description: '保持居住环境整洁有序',
      icon: 'home',
      category: HabitCategory.life,
      defaultImportance: 2,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['18:00'],
        tips: ['每天整理一个小区域', '物品用完及时归位', '定期断舍离'],
      ),
      keywords: ['整理', '清洁', '房间', '收纳'],
      color: '#8BC34A',
    ),
    
    HabitTemplate.create(
      name: '写日记',
      description: '记录每天的生活和感悟',
      icon: 'edit_note',
      category: HabitCategory.life,
      defaultImportance: 3,
      suggestions: TemplateSuggestions.create(
        reminderTimes: ['21:00'],
        tips: ['记录一天中印象深刻的事情', '写下自己的感受和思考', '不用太在意文笔'],
      ),
      keywords: ['日记', '记录', '反思', '写作'],
      color: '#FF7043',
    ),
  ];
}