import 'dart:convert';

import 'enums.dart';

/// 成就数据模型
class Achievement {
  const Achievement({
    this.id,
    required this.name,
    this.description,
    this.icon,
    required this.type,
    this.rarity = AchievementRarity.common,
    required this.conditionType,
    required this.conditionTargetValue,
    this.conditionHabitId,
    this.conditionCategory,
    this.conditionTimeWindow,
    this.conditionExtra,
    this.rewardPoints = 0,
    this.rewardBadge,
    this.rewardTitle,
    this.rewardUnlocks,
    this.color,
    this.animation,
    this.isHidden = false,
    this.isRepeatable = false,
    this.groupName,
    this.sortOrder = 0,
    this.earnedCount = 0,
    this.firstEarnedDate,
    this.lastEarnedDate,
    this.extraData,
    this.createdAt,
    this.updatedAt,
  });

  /// 成就ID
  final int? id;

  /// 成就名称
  final String name;

  /// 成就描述
  final String? description;

  /// 图标
  final String? icon;

  /// 成就类型
  final String type;

  /// 稀有度
  final AchievementRarity rarity;

  /// 条件类型
  final AchievementConditionType conditionType;

  /// 条件目标值
  final int conditionTargetValue;

  /// 条件习惯ID（特定习惯相关的成就）
  final String? conditionHabitId;

  /// 条件分类（分类相关的成就）
  final String? conditionCategory;

  /// 条件时间窗口（小时）
  final int? conditionTimeWindow;

  /// 条件额外数据（JSON字符串）
  final String? conditionExtra;

  /// 奖励积分
  final int rewardPoints;

  /// 奖励徽章
  final String? rewardBadge;

  /// 奖励称号
  final String? rewardTitle;

  /// 奖励解锁内容
  final String? rewardUnlocks;

  /// 颜色
  final String? color;

  /// 动画
  final String? animation;

  /// 是否隐藏
  final bool isHidden;

  /// 是否可重复获得
  final bool isRepeatable;

  /// 分组名称
  final String? groupName;

  /// 排序顺序
  final int sortOrder;

  /// 获得次数
  final int earnedCount;

  /// 首次获得日期
  final DateTime? firstEarnedDate;

  /// 最后获得日期
  final DateTime? lastEarnedDate;

  /// 额外数据（JSON字符串）
  final String? extraData;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 复制成就并修改部分属性
  Achievement copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    String? type,
    AchievementRarity? rarity,
    AchievementConditionType? conditionType,
    int? conditionTargetValue,
    String? conditionHabitId,
    String? conditionCategory,
    int? conditionTimeWindow,
    String? conditionExtra,
    int? rewardPoints,
    String? rewardBadge,
    String? rewardTitle,
    String? rewardUnlocks,
    String? color,
    String? animation,
    bool? isHidden,
    bool? isRepeatable,
    String? groupName,
    int? sortOrder,
    int? earnedCount,
    DateTime? firstEarnedDate,
    DateTime? lastEarnedDate,
    String? extraData,
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
      conditionType: conditionType ?? this.conditionType,
      conditionTargetValue: conditionTargetValue ?? this.conditionTargetValue,
      conditionHabitId: conditionHabitId ?? this.conditionHabitId,
      conditionCategory: conditionCategory ?? this.conditionCategory,
      conditionTimeWindow: conditionTimeWindow ?? this.conditionTimeWindow,
      conditionExtra: conditionExtra ?? this.conditionExtra,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardBadge: rewardBadge ?? this.rewardBadge,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardUnlocks: rewardUnlocks ?? this.rewardUnlocks,
      color: color ?? this.color,
      animation: animation ?? this.animation,
      isHidden: isHidden ?? this.isHidden,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      groupName: groupName ?? this.groupName,
      sortOrder: sortOrder ?? this.sortOrder,
      earnedCount: earnedCount ?? this.earnedCount,
      firstEarnedDate: firstEarnedDate ?? this.firstEarnedDate,
      lastEarnedDate: lastEarnedDate ?? this.lastEarnedDate,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 从数据库Map创建成就对象
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      type: map['type'] as String,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == (map['rarity'] as String? ?? 'common'),
        orElse: () => AchievementRarity.common,
      ),
      conditionType: AchievementConditionType.values.firstWhere(
        (e) => e.name == (map['condition_type'] as String),
        orElse: () => AchievementConditionType.streak,
      ),
      conditionTargetValue: map['condition_target_value'] as int,
      conditionHabitId: map['condition_habit_id'] as String?,
      conditionCategory: map['condition_category'] as String?,
      conditionTimeWindow: map['condition_time_window'] as int?,
      conditionExtra: map['condition_extra'] as String?,
      rewardPoints: map['reward_points'] as int? ?? 0,
      rewardBadge: map['reward_badge'] as String?,
      rewardTitle: map['reward_title'] as String?,
      rewardUnlocks: map['reward_unlocks'] as String?,
      color: map['color'] as String?,
      animation: map['animation'] as String?,
      isHidden: (map['is_hidden'] as int? ?? 0) == 1,
      isRepeatable: (map['is_repeatable'] as int? ?? 0) == 1,
      groupName: map['group_name'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      earnedCount: map['earned_count'] as int? ?? 0,
      firstEarnedDate: map['first_earned_date'] != null 
          ? DateTime.parse(map['first_earned_date'] as String)
          : null,
      lastEarnedDate: map['last_earned_date'] != null 
          ? DateTime.parse(map['last_earned_date'] as String)
          : null,
      extraData: map['extra_data'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'rarity': rarity.name,
      'condition_type': conditionType.name,
      'condition_target_value': conditionTargetValue,
      'condition_habit_id': conditionHabitId,
      'condition_category': conditionCategory,
      'condition_time_window': conditionTimeWindow,
      'condition_extra': conditionExtra,
      'reward_points': rewardPoints,
      'reward_badge': rewardBadge,
      'reward_title': rewardTitle,
      'reward_unlocks': rewardUnlocks,
      'color': color,
      'animation': animation,
      'is_hidden': isHidden ? 1 : 0,
      'is_repeatable': isRepeatable ? 1 : 0,
      'group_name': groupName,
      'sort_order': sortOrder,
      'earned_count': earnedCount,
      'first_earned_date': firstEarnedDate?.toIso8601String(),
      'last_earned_date': lastEarnedDate?.toIso8601String(),
      'extra_data': extraData,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'rarity': rarity.name,
      'conditionType': conditionType.name,
      'conditionTargetValue': conditionTargetValue,
      'conditionHabitId': conditionHabitId,
      'conditionCategory': conditionCategory,
      'conditionTimeWindow': conditionTimeWindow,
      'conditionExtra': conditionExtra != null ? jsonDecode(conditionExtra!) : null,
      'rewardPoints': rewardPoints,
      'rewardBadge': rewardBadge,
      'rewardTitle': rewardTitle,
      'rewardUnlocks': rewardUnlocks,
      'color': color,
      'animation': animation,
      'isHidden': isHidden,
      'isRepeatable': isRepeatable,
      'groupName': groupName,
      'sortOrder': sortOrder,
      'earnedCount': earnedCount,
      'firstEarnedDate': firstEarnedDate?.toIso8601String(),
      'lastEarnedDate': lastEarnedDate?.toIso8601String(),
      'extraData': extraData != null ? jsonDecode(extraData!) : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON创建成就对象
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == (json['rarity'] as String? ?? 'common'),
        orElse: () => AchievementRarity.common,
      ),
      conditionType: AchievementConditionType.values.firstWhere(
        (e) => e.name == (json['conditionType'] as String),
        orElse: () => AchievementConditionType.streak,
      ),
      conditionTargetValue: json['conditionTargetValue'] as int,
      conditionHabitId: json['conditionHabitId'] as String?,
      conditionCategory: json['conditionCategory'] as String?,
      conditionTimeWindow: json['conditionTimeWindow'] as int?,
      conditionExtra: json['conditionExtra'] != null 
          ? jsonEncode(json['conditionExtra'])
          : null,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      rewardBadge: json['rewardBadge'] as String?,
      rewardTitle: json['rewardTitle'] as String?,
      rewardUnlocks: json['rewardUnlocks'] as String?,
      color: json['color'] as String?,
      animation: json['animation'] as String?,
      isHidden: json['isHidden'] as bool? ?? false,
      isRepeatable: json['isRepeatable'] as bool? ?? false,
      groupName: json['groupName'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      earnedCount: json['earnedCount'] as int? ?? 0,
      firstEarnedDate: json['firstEarnedDate'] != null 
          ? DateTime.parse(json['firstEarnedDate'] as String)
          : null,
      lastEarnedDate: json['lastEarnedDate'] != null 
          ? DateTime.parse(json['lastEarnedDate'] as String)
          : null,
      extraData: json['extraData'] != null 
          ? jsonEncode(json['extraData'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 解析条件额外数据
  Map<String, dynamic>? getConditionExtraMap() {
    if (conditionExtra == null || conditionExtra!.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(conditionExtra!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 设置条件额外数据
  String? setConditionExtraMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    
    return jsonEncode(data);
  }

  /// 解析额外数据
  Map<String, dynamic>? getExtraDataMap() {
    if (extraData == null || extraData!.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(extraData!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 设置额外数据
  String? setExtraDataMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }
    
    return jsonEncode(data);
  }

  /// 是否已获得
  bool get isEarned => earnedCount > 0;

  /// 获取稀有度的文字描述
  String getRarityDescription() {
    switch (rarity) {
      case AchievementRarity.common:
        return '普通';
      case AchievementRarity.uncommon:
        return '少见';
      case AchievementRarity.rare:
        return '稀有';
      case AchievementRarity.epic:
        return '史诗';
      case AchievementRarity.legendary:
        return '传说';
    }
  }

  /// 获取条件类型的文字描述
  String getConditionTypeDescription() {
    switch (conditionType) {
      case AchievementConditionType.streak:
        return '连续打卡';
      case AchievementConditionType.totalCheckIns:
        return '总打卡次数';
      case AchievementConditionType.specificHabit:
        return '完成特定习惯';
      case AchievementConditionType.categoryCompletion:
        return '完成某类习惯';
      case AchievementConditionType.timeWindow:
        return '在时间窗口内完成';
    }
  }

  /// 获取完整的条件描述
  String getFullConditionDescription() {
    final typeDesc = getConditionTypeDescription();
    
    switch (conditionType) {
      case AchievementConditionType.streak:
        return '$typeDesc $conditionTargetValue 天';
      case AchievementConditionType.totalCheckIns:
        return '$typeDesc $conditionTargetValue 次';
      case AchievementConditionType.specificHabit:
        return '$typeDesc（ID: $conditionHabitId）$conditionTargetValue 次';
      case AchievementConditionType.categoryCompletion:
        return '完成 $conditionCategory 类习惯 $conditionTargetValue 次';
      case AchievementConditionType.timeWindow:
        final windowHours = conditionTimeWindow ?? 24;
        return '在 $windowHours 小时内$typeDesc $conditionTargetValue 次';
    }
  }

  /// 获取稀有度对应的颜色
  String getRarityColor() {
    if (color != null && color!.isNotEmpty) {
      return color!;
    }
    
    switch (rarity) {
      case AchievementRarity.common:
        return '#9E9E9E'; // 灰色
      case AchievementRarity.uncommon:
        return '#4CAF50'; // 绿色
      case AchievementRarity.rare:
        return '#2196F3'; // 蓝色
      case AchievementRarity.epic:
        return '#9C27B0'; // 紫色
      case AchievementRarity.legendary:
        return '#FF9800'; // 橙色
    }
  }

  /// 检查是否满足获得条件
  bool checkCondition({
    required int currentStreak,
    required int totalCheckIns,
    required Map<int, int> habitCheckIns,
    required Map<String, int> categoryCheckIns,
    int? timeWindowCheckIns,
  }) {
    switch (conditionType) {
      case AchievementConditionType.streak:
        return currentStreak >= conditionTargetValue;
        
      case AchievementConditionType.totalCheckIns:
        return totalCheckIns >= conditionTargetValue;
        
      case AchievementConditionType.specificHabit:
        if (conditionHabitId == null) return false;
        final habitId = int.tryParse(conditionHabitId!);
        if (habitId == null) return false;
        return (habitCheckIns[habitId] ?? 0) >= conditionTargetValue;
        
      case AchievementConditionType.categoryCompletion:
        if (conditionCategory == null) return false;
        return (categoryCheckIns[conditionCategory!] ?? 0) >= conditionTargetValue;
        
      case AchievementConditionType.timeWindow:
        return (timeWindowCheckIns ?? 0) >= conditionTargetValue;
    }
  }

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, type: $type, '
           'rarity: $rarity, conditionType: $conditionType, '
           'conditionTargetValue: $conditionTargetValue, '
           'earnedCount: $earnedCount, isEarned: $isEarned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Achievement &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.conditionType == conditionType;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, type, conditionType);
  }
}