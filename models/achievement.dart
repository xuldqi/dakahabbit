import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

/// 成就类型
enum AchievementType {
  @JsonValue('streak')
  streak,           // 连续打卡
  @JsonValue('total')
  total,            // 总打卡次数
  @JsonValue('habit_count')
  habitCount,       // 习惯数量
  @JsonValue('perfect_week')
  perfectWeek,      // 完美一周
  @JsonValue('perfect_month')
  perfectMonth,     // 完美一月
  @JsonValue('early_bird')
  earlyBird,        // 早起达人
  @JsonValue('night_owl')
  nightOwl,         // 夜猫子
  @JsonValue('consistency')
  consistency,      // 坚持不懈
  @JsonValue('milestone')
  milestone,        // 里程碑
  @JsonValue('special')
  special,          // 特殊成就
  @JsonValue('seasonal')
  seasonal,         // 季节性成就
  @JsonValue('challenge')
  challenge,        // 挑战成就
}

/// 成就稀有度
enum AchievementRarity {
  @JsonValue('common')
  common,           // 普通
  @JsonValue('rare')
  rare,             // 稀有
  @JsonValue('epic')
  epic,             // 史诗
  @JsonValue('legendary')
  legendary,        // 传说
}

/// 成就条件
@JsonSerializable()
class AchievementCondition {
  final AchievementType type;
  final int targetValue;              // 目标值
  final String? habitId;              // 特定习惯ID（可选）
  final String? category;             // 习惯分类（可选）
  final int? timeWindowDays;          // 时间窗口（天）
  final Map<String, dynamic>? extraConditions; // 额外条件
  
  const AchievementCondition({
    required this.type,
    required this.targetValue,
    this.habitId,
    this.category,
    this.timeWindowDays,
    this.extraConditions,
  });
  
  factory AchievementCondition.fromJson(Map<String, dynamic> json) => _$AchievementConditionFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementConditionToJson(this);
  
  /// 创建连续打卡条件
  factory AchievementCondition.streak(int days, {String? habitId}) => AchievementCondition(
    type: AchievementType.streak,
    targetValue: days,
    habitId: habitId,
  );
  
  /// 创建总次数条件
  factory AchievementCondition.total(int count, {String? habitId, String? category}) => AchievementCondition(
    type: AchievementType.total,
    targetValue: count,
    habitId: habitId,
    category: category,
  );
  
  /// 创建完美周条件
  factory AchievementCondition.perfectWeek({String? category}) => AchievementCondition(
    type: AchievementType.perfectWeek,
    targetValue: 1,
    category: category,
    timeWindowDays: 7,
  );
  
  /// 创建完美月条件
  factory AchievementCondition.perfectMonth({String? category}) => AchievementCondition(
    type: AchievementType.perfectMonth,
    targetValue: 1,
    category: category,
    timeWindowDays: 30,
  );
}

/// 成就奖励
@JsonSerializable()
class AchievementReward {
  final int points;                   // 积分奖励
  final String? badge;                // 徽章图标
  final String? title;                // 称号
  final Map<String, dynamic>? unlocks; // 解锁内容
  
  const AchievementReward({
    this.points = 0,
    this.badge,
    this.title,
    this.unlocks,
  });
  
  factory AchievementReward.fromJson(Map<String, dynamic> json) => _$AchievementRewardFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementRewardToJson(this);
  
  /// 创建基础奖励
  factory AchievementReward.basic(int points, {String? badge}) => AchievementReward(
    points: points,
    badge: badge,
  );
  
  /// 创建高级奖励
  factory AchievementReward.premium(int points, String badge, String title, {Map<String, dynamic>? unlocks}) => AchievementReward(
    points: points,
    badge: badge,
    title: title,
    unlocks: unlocks,
  );
}

/// 获得的成就记录
@JsonSerializable()
class EarnedAchievement {
  final int? id;
  final int achievementId;
  final int? habitId;                 // 关联的习惯ID
  final DateTime earnedDate;
  final int earnedValue;              // 获得时的数值
  final String? context;              // 获得时的上下文信息
  final AchievementReward reward;
  final bool isNotified;              // 是否已通知用户
  
  const EarnedAchievement({
    this.id,
    required this.achievementId,
    this.habitId,
    required this.earnedDate,
    required this.earnedValue,
    this.context,
    required this.reward,
    this.isNotified = false,
  });
  
  factory EarnedAchievement.fromJson(Map<String, dynamic> json) => _$EarnedAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$EarnedAchievementToJson(this);
  
  /// 创建获得的成就
  factory EarnedAchievement.create({
    required int achievementId,
    int? habitId,
    required int earnedValue,
    String? context,
    required AchievementReward reward,
  }) => EarnedAchievement(
    achievementId: achievementId,
    habitId: habitId,
    earnedDate: DateTime.now(),
    earnedValue: earnedValue,
    context: context,
    reward: reward,
  );
  
  /// 复制并更新记录
  EarnedAchievement copyWith({
    int? id,
    int? achievementId,
    int? habitId,
    DateTime? earnedDate,
    int? earnedValue,
    String? context,
    AchievementReward? reward,
    bool? isNotified,
  }) {
    return EarnedAchievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      habitId: habitId ?? this.habitId,
      earnedDate: earnedDate ?? this.earnedDate,
      earnedValue: earnedValue ?? this.earnedValue,
      context: context ?? this.context,
      reward: reward ?? this.reward,
      isNotified: isNotified ?? this.isNotified,
    );
  }
  
  /// 标记为已通知
  EarnedAchievement markAsNotified() => copyWith(isNotified: true);
}

/// 成就定义模型
@JsonSerializable()
class Achievement {
  final int? id;
  final String name;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  
  // 条件和奖励
  final AchievementCondition condition;
  final AchievementReward reward;
  
  // 显示属性
  final String? color;                // 主题色
  final String? animation;            // 动画效果
  final bool isHidden;                // 是否隐藏（用户达成前不显示）
  final bool isRepeatable;            // 是否可重复获得
  
  // 分组和排序
  final String? group;                // 成就组
  final int sortOrder;                // 排序顺序
  
  // 统计信息
  final int earnedCount;              // 获得次数
  final DateTime? firstEarnedDate;    // 首次获得日期
  final DateTime? lastEarnedDate;     // 最后获得日期
  
  // 扩展数据
  final Map<String, dynamic>? extraData;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Achievement({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    this.rarity = AchievementRarity.common,
    required this.condition,
    required this.reward,
    this.color,
    this.animation,
    this.isHidden = false,
    this.isRepeatable = false,
    this.group,
    this.sortOrder = 0,
    this.earnedCount = 0,
    this.firstEarnedDate,
    this.lastEarnedDate,
    this.extraData,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
  
  /// 创建新成就
  factory Achievement.create({
    required String name,
    required String description,
    required String icon,
    required AchievementType type,
    AchievementRarity rarity = AchievementRarity.common,
    required AchievementCondition condition,
    required AchievementReward reward,
    String? color,
    String? animation,
    bool isHidden = false,
    bool isRepeatable = false,
    String? group,
    int sortOrder = 0,
    Map<String, dynamic>? extraData,
  }) {
    final now = DateTime.now();
    return Achievement(
      name: name,
      description: description,
      icon: icon,
      type: type,
      rarity: rarity,
      condition: condition,
      reward: reward,
      color: color,
      animation: animation,
      isHidden: isHidden,
      isRepeatable: isRepeatable,
      group: group,
      sortOrder: sortOrder,
      extraData: extraData,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 复制并更新成就
  Achievement copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    AchievementCondition? condition,
    AchievementReward? reward,
    String? color,
    String? animation,
    bool? isHidden,
    bool? isRepeatable,
    String? group,
    int? sortOrder,
    int? earnedCount,
    DateTime? firstEarnedDate,
    DateTime? lastEarnedDate,
    Map<String, dynamic>? extraData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      condition: condition ?? this.condition,
      reward: reward ?? this.reward,
      color: color ?? this.color,
      animation: animation ?? this.animation,
      isHidden: isHidden ?? this.isHidden,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      group: group ?? this.group,
      sortOrder: sortOrder ?? this.sortOrder,
      earnedCount: earnedCount ?? this.earnedCount,
      firstEarnedDate: firstEarnedDate ?? this.firstEarnedDate,
      lastEarnedDate: lastEarnedDate ?? this.lastEarnedDate,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 记录获得成就
  Achievement recordEarned() {
    final now = DateTime.now();
    return copyWith(
      earnedCount: earnedCount + 1,
      firstEarnedDate: firstEarnedDate ?? now,
      lastEarnedDate: now,
    );
  }
  
  /// 获取类型描述
  String get typeText {
    switch (type) {
      case AchievementType.streak:
        return '连续打卡';
      case AchievementType.total:
        return '累计打卡';
      case AchievementType.habitCount:
        return '习惯数量';
      case AchievementType.perfectWeek:
        return '完美一周';
      case AchievementType.perfectMonth:
        return '完美一月';
      case AchievementType.earlyBird:
        return '早起达人';
      case AchievementType.nightOwl:
        return '夜猫子';
      case AchievementType.consistency:
        return '坚持不懈';
      case AchievementType.milestone:
        return '里程碑';
      case AchievementType.special:
        return '特殊成就';
      case AchievementType.seasonal:
        return '季节成就';
      case AchievementType.challenge:
        return '挑战成就';
    }
  }
  
  /// 获取稀有度描述
  String get rarityText {
    switch (rarity) {
      case AchievementRarity.common:
        return '普通';
      case AchievementRarity.rare:
        return '稀有';
      case AchievementRarity.epic:
        return '史诗';
      case AchievementRarity.legendary:
        return '传说';
    }
  }
  
  /// 获取稀有度颜色
  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return '#9E9E9E';    // 灰色
      case AchievementRarity.rare:
        return '#2196F3';    // 蓝色
      case AchievementRarity.epic:
        return '#9C27B0';    // 紫色
      case AchievementRarity.legendary:
        return '#FF9800';    // 橙色
    }
  }
  
  /// 是否已获得
  bool get isEarned => earnedCount > 0;
  
  /// 获取进度描述
  String getProgressText(int currentValue) {
    return '$currentValue / ${condition.targetValue}';
  }
  
  /// 获取进度百分比
  double getProgressPercentage(int currentValue) {
    return (currentValue / condition.targetValue).clamp(0.0, 1.0);
  }
  
  /// 是否接近完成（80%以上）
  bool isNearCompletion(int currentValue) {
    return getProgressPercentage(currentValue) >= 0.8;
  }
  
  /// 检查是否满足条件
  bool checkCondition(Map<String, dynamic> data) {
    final currentValue = data['currentValue'] as int? ?? 0;
    return currentValue >= condition.targetValue;
  }
  
  /// 格式化获得时间
  String? get formattedFirstEarnedDate {
    if (firstEarnedDate == null) return null;
    final date = firstEarnedDate!;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
  
  @override
  String toString() {
    return 'Achievement{id: $id, name: $name, type: $type, rarity: $rarity, earned: $isEarned}';
  }
}

/// 预设成就数据
class DefaultAchievements {
  static final List<Achievement> achievements = [
    // 连续打卡成就
    Achievement.create(
      name: '初出茅庐',
      description: '连续打卡3天',
      icon: 'star',
      type: AchievementType.streak,
      condition: AchievementCondition.streak(3),
      reward: AchievementReward.basic(10, badge: 'star_bronze'),
      color: '#4CAF50',
      group: '连续打卡',
    ),
    
    Achievement.create(
      name: '渐入佳境',
      description: '连续打卡7天',
      icon: 'star_half',
      type: AchievementType.streak,
      condition: AchievementCondition.streak(7),
      reward: AchievementReward.basic(25, badge: 'star_silver'),
      color: '#2196F3',
      group: '连续打卡',
    ),
    
    Achievement.create(
      name: '坚持不懈',
      description: '连续打卡30天',
      icon: 'stars',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      condition: AchievementCondition.streak(30),
      reward: AchievementReward.premium(100, 'star_gold', '坚持达人'),
      color: '#FF9800',
      group: '连续打卡',
    ),
    
    Achievement.create(
      name: '百日筑梦',
      description: '连续打卡100天',
      icon: 'diamond',
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      condition: AchievementCondition.streak(100),
      reward: AchievementReward.premium(500, 'diamond', '百日传说'),
      color: '#9C27B0',
      group: '连续打卡',
    ),
    
    // 总次数成就
    Achievement.create(
      name: '初学者',
      description: '累计打卡10次',
      icon: 'check_circle',
      type: AchievementType.total,
      condition: AchievementCondition.total(10),
      reward: AchievementReward.basic(5),
      color: '#4CAF50',
      group: '累计打卡',
    ),
    
    Achievement.create(
      name: '实践者',
      description: '累计打卡50次',
      icon: 'verified',
      type: AchievementType.total,
      condition: AchievementCondition.total(50),
      reward: AchievementReward.basic(20),
      color: '#2196F3',
      group: '累计打卡',
    ),
    
    Achievement.create(
      name: '专业户',
      description: '累计打卡200次',
      icon: 'workspace_premium',
      type: AchievementType.total,
      rarity: AchievementRarity.rare,
      condition: AchievementCondition.total(200),
      reward: AchievementReward.premium(80, 'crown', '打卡专家'),
      color: '#FF9800',
      group: '累计打卡',
    ),
    
    // 完美周/月成就
    Achievement.create(
      name: '完美一周',
      description: '一周内完成所有习惯打卡',
      icon: 'calendar_view_week',
      type: AchievementType.perfectWeek,
      rarity: AchievementRarity.rare,
      condition: AchievementCondition.perfectWeek(),
      reward: AchievementReward.premium(50, 'trophy', '周冠军'),
      color: '#FF5722',
      isRepeatable: true,
      group: '完美表现',
    ),
    
    Achievement.create(
      name: '完美一月',
      description: '一个月内完成所有习惯打卡',
      icon: 'calendar_month',
      type: AchievementType.perfectMonth,
      rarity: AchievementRarity.epic,
      condition: AchievementCondition.perfectMonth(),
      reward: AchievementReward.premium(200, 'trophy_gold', '月度传说'),
      color: '#E91E63',
      isRepeatable: true,
      group: '完美表现',
    ),
    
    // 特殊成就
    Achievement.create(
      name: '早起鸟儿',
      description: '在早上6点前完成打卡10次',
      icon: 'wb_sunny',
      type: AchievementType.earlyBird,
      rarity: AchievementRarity.rare,
      condition: AchievementCondition(
        type: AchievementType.earlyBird,
        targetValue: 10,
        extraConditions: {'timeBefore': '06:00'},
      ),
      reward: AchievementReward.premium(60, 'sunny', '早起达人'),
      color: '#FFD54F',
      group: '生活方式',
    ),
    
    Achievement.create(
      name: '夜猫子',
      description: '在晚上10点后完成打卡20次',
      icon: 'nightlight',
      type: AchievementType.nightOwl,
      condition: AchievementCondition(
        type: AchievementType.nightOwl,
        targetValue: 20,
        extraConditions: {'timeAfter': '22:00'},
      ),
      reward: AchievementReward.premium(40, 'moon', '夜行者'),
      color: '#7986CB',
      group: '生活方式',
    ),
  ];
}