import 'dart:convert';

import 'enums.dart';

/// 日志数据模型
class Journal {
  const Journal({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.type = JournalType.daily,
    this.tags,
    this.mood,
    this.moodScore,
    this.weather,
    this.photos,
    this.wordCount = 0,
    this.isPrivate = false,
    this.isDeleted = false,
    this.isFavorite = false,
    this.isPinned = false,
    this.latitude,
    this.longitude,
    this.locationName,
    this.extraData,
    this.createdAt,
    this.updatedAt,
  });

  /// 日志ID
  final int? id;

  /// 日志标题
  final String title;

  /// 日志内容
  final String content;

  /// 日志日期 (YYYY-MM-DD格式)
  final String date;

  /// 日志类型
  final JournalType type;

  /// 标签列表（JSON字符串）
  final String? tags;

  /// 心情
  final String? mood;

  /// 心情评分 (1-5分)
  final int? moodScore;

  /// 天气
  final String? weather;

  /// 照片列表（JSON字符串）
  final String? photos;

  /// 字数统计
  final int wordCount;

  /// 是否私密
  final bool isPrivate;

  /// 是否删除
  final bool isDeleted;

  /// 是否收藏
  final bool isFavorite;

  /// 是否置顶
  final bool isPinned;

  /// 纬度
  final double? latitude;

  /// 经度
  final double? longitude;

  /// 位置名称
  final String? locationName;

  /// 额外数据（JSON字符串）
  final String? extraData;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 复制日志并修改部分属性
  Journal copyWith({
    int? id,
    String? title,
    String? content,
    String? date,
    JournalType? type,
    String? tags,
    String? mood,
    int? moodScore,
    String? weather,
    String? photos,
    int? wordCount,
    bool? isPrivate,
    bool? isDeleted,
    bool? isFavorite,
    bool? isPinned,
    double? latitude,
    double? longitude,
    String? locationName,
    String? extraData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Journal(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      weather: weather ?? this.weather,
      photos: photos ?? this.photos,
      wordCount: wordCount ?? this.wordCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isDeleted: isDeleted ?? this.isDeleted,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 从数据库Map创建日志对象
  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
      type: JournalType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'daily'),
        orElse: () => JournalType.daily,
      ),
      tags: map['tags'] as String?,
      mood: map['mood'] as String?,
      moodScore: map['mood_score'] as int?,
      weather: map['weather'] as String?,
      photos: map['photos'] as String?,
      wordCount: map['word_count'] as int? ?? 0,
      isPrivate: (map['is_private'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['location_name'] as String?,
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
      'title': title,
      'content': content,
      'date': date,
      'type': type.name,
      'tags': tags,
      'mood': mood,
      'mood_score': moodScore,
      'weather': weather,
      'photos': photos,
      'word_count': wordCount,
      'is_private': isPrivate ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'extra_data': extraData,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'type': type.name,
      'tags': tags != null ? jsonDecode(tags!) : null,
      'mood': mood,
      'moodScore': moodScore,
      'weather': weather,
      'photos': photos != null ? jsonDecode(photos!) : null,
      'wordCount': wordCount,
      'isPrivate': isPrivate,
      'isDeleted': isDeleted,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'extraData': extraData != null ? jsonDecode(extraData!) : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON创建日志对象
  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      type: JournalType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'daily'),
        orElse: () => JournalType.daily,
      ),
      tags: json['tags'] != null 
          ? jsonEncode(json['tags'])
          : null,
      mood: json['mood'] as String?,
      moodScore: json['moodScore'] as int?,
      weather: json['weather'] as String?,
      photos: json['photos'] != null 
          ? jsonEncode(json['photos'])
          : null,
      wordCount: json['wordCount'] as int? ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
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

  /// 解析标签列表
  List<String> getTagsList() {
    if (tags == null || tags!.isEmpty) {
      return [];
    }
    
    try {
      final decoded = jsonDecode(tags!) as List;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// 设置标签列表
  String? setTagsList(List<String> tagList) {
    if (tagList.isEmpty) {
      return null;
    }
    
    return jsonEncode(tagList);
  }

  /// 解析照片列表
  List<String> getPhotosList() {
    if (photos == null || photos!.isEmpty) {
      return [];
    }
    
    try {
      final decoded = jsonDecode(photos!) as List;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// 设置照片列表
  String? setPhotosList(List<String> photoList) {
    if (photoList.isEmpty) {
      return null;
    }
    
    return jsonEncode(photoList);
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

  /// 获取心情类型
  MoodType? getMoodType() {
    return MoodType.fromName(mood);
  }

  /// 设置心情类型
  String? setMoodType(MoodType? moodType) {
    return moodType?.name;
  }

  /// 获取日志的完整日期时间
  DateTime getJournalDate() {
    return DateTime.parse(date);
  }

  /// 计算字数
  int calculateWordCount() {
    if (content.isEmpty) return 0;
    
    // 简单的字数统计（去除空格和换行符）
    final cleanContent = content.replaceAll(RegExp(r'\s+'), '');
    return cleanContent.length;
  }

  /// 创建今天的日志
  factory Journal.forToday({
    required String title,
    required String content,
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
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final contentToUse = content.trim();
    
    return Journal(
      title: title.trim(),
      content: contentToUse,
      date: _formatDate(today),
      type: type,
      tags: tags != null && tags.isNotEmpty ? jsonEncode(tags) : null,
      mood: mood?.name,
      moodScore: moodScore,
      weather: weather,
      photos: photos != null && photos.isNotEmpty ? jsonEncode(photos) : null,
      wordCount: contentToUse.replaceAll(RegExp(r'\s+'), '').length,
      isPrivate: isPrivate,
      isFavorite: isFavorite,
      isPinned: isPinned,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      extraData: extraData != null && extraData.isNotEmpty 
          ? jsonEncode(extraData) 
          : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建习惯相关的日志
  factory Journal.forHabit({
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
  }) {
    final contentToUse = content.trim();
    
    return Journal(
      title: title.trim(),
      content: contentToUse,
      date: _formatDate(date),
      type: JournalType.habit,
      tags: tags != null && tags.isNotEmpty ? jsonEncode(tags) : null,
      mood: mood?.name,
      moodScore: moodScore,
      weather: weather,
      photos: photos != null && photos.isNotEmpty ? jsonEncode(photos) : null,
      wordCount: contentToUse.replaceAll(RegExp(r'\s+'), '').length,
      isPrivate: isPrivate,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      extraData: extraData != null && extraData.isNotEmpty 
          ? jsonEncode(extraData) 
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 格式化日期为YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// 判断是否是今天的日志
  bool isToday() {
    final now = DateTime.now();
    final today = _formatDate(now);
    return date == today;
  }

  /// 判断是否包含指定标签
  bool hasTag(String tag) {
    final tagList = getTagsList();
    return tagList.contains(tag);
  }

  /// 添加标签
  Journal addTag(String tag) {
    final tagList = getTagsList();
    if (!tagList.contains(tag)) {
      tagList.add(tag);
    }
    return copyWith(tags: setTagsList(tagList));
  }

  /// 移除标签
  Journal removeTag(String tag) {
    final tagList = getTagsList();
    tagList.remove(tag);
    return copyWith(tags: setTagsList(tagList));
  }

  /// 获取内容预览（前100个字符）
  String getContentPreview({int maxLength = 100}) {
    if (content.length <= maxLength) {
      return content;
    }
    
    return '${content.substring(0, maxLength)}...';
  }

  /// 获取类型的文字描述
  String getTypeDescription() {
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

  /// 获取心情评分的文字描述
  String getMoodScoreDescription() {
    if (moodScore == null) return '未评分';
    
    switch (moodScore!) {
      case 5:
        return '非常好';
      case 4:
        return '很好';
      case 3:
        return '一般';
      case 2:
        return '不太好';
      case 1:
        return '很差';
      default:
        return '未知';
    }
  }

  @override
  String toString() {
    return 'Journal(id: $id, title: $title, date: $date, type: $type, '
           'wordCount: $wordCount, isFavorite: $isFavorite, '
           'isPinned: $isPinned, isPrivate: $isPrivate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Journal &&
        other.id == id &&
        other.title == title &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, date, type);
  }

  /// 格式化日期显示
  static String formatDate(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final inputDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      
      if (inputDate == today) {
        return '今天';
      } else if (inputDate == today.subtract(const Duration(days: 1))) {
        return '昨天';
      } else if (inputDate == today.subtract(const Duration(days: 2))) {
        return '前天';
      } else {
        return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTime.toString();
    }
  }
}