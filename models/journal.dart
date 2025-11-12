import 'package:json_annotation/json_annotation.dart';
import 'check_in.dart'; // 导入Mood枚举

part 'journal.g.dart';

/// 日志类型
enum JournalType {
  @JsonValue('daily')
  daily,          // 日常记录
  @JsonValue('reflection')
  reflection,     // 反思总结
  @JsonValue('goal')
  goal,           // 目标相关
  @JsonValue('milestone')
  milestone,      // 里程碑
  @JsonValue('other')
  other,          // 其他
}

/// 日志标签
@JsonSerializable()
class JournalTag {
  final String name;
  final String color;   // 标签颜色（十六进制）
  
  const JournalTag({
    required this.name,
    required this.color,
  });
  
  factory JournalTag.fromJson(Map<String, dynamic> json) => _$JournalTagFromJson(json);
  Map<String, dynamic> toJson() => _$JournalTagToJson(this);
  
  /// 预设标签
  static const List<JournalTag> defaultTags = [
    JournalTag(name: '感悟', color: '#FF6B9D'),
    JournalTag(name: '成长', color: '#4ECDC4'),
    JournalTag(name: '挑战', color: '#FFD93D'),
    JournalTag(name: '进步', color: '#6BCF7F'),
    JournalTag(name: '困难', color: '#FF6B6B'),
    JournalTag(name: '快乐', color: '#4DABF7'),
    JournalTag(name: '思考', color: '#9775FA'),
    JournalTag(name: '计划', color: '#FFA8A8'),
  ];
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalTag &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// 日志媒体文件
@JsonSerializable()
class JournalMedia {
  final String path;         // 文件路径
  final String type;         // 类型：image/video/audio
  final String? caption;     // 说明文字
  final int? size;          // 文件大小
  final String? thumbnail;   // 缩略图路径（视频用）
  final DateTime createdAt;
  
  const JournalMedia({
    required this.path,
    required this.type,
    this.caption,
    this.size,
    this.thumbnail,
    required this.createdAt,
  });
  
  factory JournalMedia.fromJson(Map<String, dynamic> json) => _$JournalMediaFromJson(json);
  Map<String, dynamic> toJson() => _$JournalMediaToJson(this);
  
  /// 创建图片媒体
  factory JournalMedia.image(String path, {String? caption}) => JournalMedia(
    path: path,
    type: 'image',
    caption: caption,
    createdAt: DateTime.now(),
  );
  
  /// 创建视频媒体
  factory JournalMedia.video(String path, {String? caption, String? thumbnail}) => JournalMedia(
    path: path,
    type: 'video',
    caption: caption,
    thumbnail: thumbnail,
    createdAt: DateTime.now(),
  );
  
  /// 创建音频媒体
  factory JournalMedia.audio(String path, {String? caption}) => JournalMedia(
    path: path,
    type: 'audio',
    caption: caption,
    createdAt: DateTime.now(),
  );
  
  /// 是否为图片
  bool get isImage => type == 'image';
  
  /// 是否为视频
  bool get isVideo => type == 'video';
  
  /// 是否为音频
  bool get isAudio => type == 'audio';
}

/// 日志统计信息
@JsonSerializable()
class JournalStats {
  final int wordCount;        // 字数统计
  final int mediaCount;       // 媒体文件数量
  final int habitCount;       // 关联习惯数量
  final Duration? writingTime; // 写作时间（可选）
  
  const JournalStats({
    this.wordCount = 0,
    this.mediaCount = 0,
    this.habitCount = 0,
    this.writingTime,
  });
  
  factory JournalStats.fromJson(Map<String, dynamic> json) => _$JournalStatsFromJson(json);
  Map<String, dynamic> toJson() => _$JournalStatsToJson(this);
  
  /// 创建统计信息
  factory JournalStats.calculate({
    required String content,
    required List<JournalMedia> mediaFiles,
    required int habitCount,
    Duration? writingTime,
  }) {
    return JournalStats(
      wordCount: content.length,
      mediaCount: mediaFiles.length,
      habitCount: habitCount,
      writingTime: writingTime,
    );
  }
  
  /// 复制并更新统计信息
  JournalStats copyWith({
    int? wordCount,
    int? mediaCount,
    int? habitCount,
    Duration? writingTime,
  }) {
    return JournalStats(
      wordCount: wordCount ?? this.wordCount,
      mediaCount: mediaCount ?? this.mediaCount,
      habitCount: habitCount ?? this.habitCount,
      writingTime: writingTime ?? this.writingTime,
    );
  }
}

/// 日志模型
@JsonSerializable()
class Journal {
  final int? id;
  final String title;
  final String content;
  final DateTime date;              // 日志日期（可以不同于创建日期）
  
  // 分类和标签
  final JournalType type;
  final List<JournalTag> tags;
  
  // 情感信息
  final Mood? mood;
  final int? moodScore;             // 心情评分(1-5)
  final String? weather;            // 天气情况
  
  // 媒体文件
  final List<JournalMedia> mediaFiles;
  
  // 统计信息
  final JournalStats stats;
  
  // 状态和设置
  final bool isPrivate;             // 是否私密
  final bool isDeleted;
  final bool isFavorite;            // 是否收藏
  final bool isPinned;              // 是否置顶
  
  // 地理位置信息（可选）
  final double? latitude;
  final double? longitude;
  final String? locationName;
  
  // 扩展数据
  final Map<String, dynamic>? extraData;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Journal({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.type = JournalType.daily,
    this.tags = const [],
    this.mood,
    this.moodScore,
    this.weather,
    this.mediaFiles = const [],
    required this.stats,
    this.isPrivate = false,
    this.isDeleted = false,
    this.isFavorite = false,
    this.isPinned = false,
    this.latitude,
    this.longitude,
    this.locationName,
    this.extraData,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);
  Map<String, dynamic> toJson() => _$JournalToJson(this);
  
  /// 创建新日志
  factory Journal.create({
    required String title,
    required String content,
    DateTime? date,
    JournalType type = JournalType.daily,
    List<JournalTag>? tags,
    Mood? mood,
    int? moodScore,
    String? weather,
    List<JournalMedia>? mediaFiles,
    bool isPrivate = false,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) {
    final now = DateTime.now();
    final journalDate = date ?? now;
    final media = mediaFiles ?? [];
    final journalTags = tags ?? <JournalTag>[];
    
    return Journal(
      title: title,
      content: content,
      date: DateTime(journalDate.year, journalDate.month, journalDate.day),
      type: type,
      tags: journalTags,
      mood: mood,
      moodScore: moodScore,
      weather: weather,
      mediaFiles: media,
      stats: JournalStats.calculate(
        content: content,
        mediaFiles: media,
        habitCount: 0, // 初始为0，后续会更新
      ),
      isPrivate: isPrivate,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      extraData: extraData,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 复制并更新日志
  Journal copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    JournalType? type,
    List<JournalTag>? tags,
    Mood? mood,
    int? moodScore,
    String? weather,
    List<JournalMedia>? mediaFiles,
    JournalStats? stats,
    bool? isPrivate,
    bool? isDeleted,
    bool? isFavorite,
    bool? isPinned,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
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
      mediaFiles: mediaFiles ?? this.mediaFiles,
      stats: stats ?? this.stats,
      isPrivate: isPrivate ?? this.isPrivate,
      isDeleted: isDeleted ?? this.isDeleted,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 获取类型描述
  String get typeText {
    switch (type) {
      case JournalType.daily:
        return '日常记录';
      case JournalType.reflection:
        return '反思总结';
      case JournalType.goal:
        return '目标相关';
      case JournalType.milestone:
        return '里程碑';
      case JournalType.other:
        return '其他';
    }
  }
  
  /// 获取心情描述
  String? get moodText {
    if (mood == null) return null;
    switch (mood!) {
      case Mood.veryHappy:
        return '非常开心';
      case Mood.happy:
        return '开心';
      case Mood.neutral:
        return '一般';
      case Mood.sad:
        return '难过';
      case Mood.verySad:
        return '非常难过';
    }
  }
  
  /// 获取心情表情
  String? get moodEmoji {
    if (mood == null) return null;
    switch (mood!) {
      case Mood.veryHappy:
        return '😄';
      case Mood.happy:
        return '😊';
      case Mood.neutral:
        return '😐';
      case Mood.sad:
        return '😢';
      case Mood.verySad:
        return '😭';
    }
  }
  
  /// 获取内容预览（限制字数）
  String getContentPreview({int maxLength = 100}) {
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }
  
  /// 是否为今天的日志
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
  
  /// 是否为昨天的日志
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
  
  /// 获取相对日期
  String get relativeDate {
    if (isToday) return '今天';
    if (isYesterday) return '昨天';
    
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference > 0) {
      if (difference <= 7) {
        return '$difference天前';
      } else if (difference <= 30) {
        final weeks = (difference / 7).floor();
        return '$weeks周前';
      } else if (difference <= 365) {
        final months = (difference / 30).floor();
        return '$months个月前';
      } else {
        final years = (difference / 365).floor();
        return '$years年前';
      }
    } else if (difference < 0) {
      final futureDays = -difference;
      if (futureDays == 1) return '明天';
      if (futureDays == 2) return '后天';
      return '$futureDays天后';
    }
    
    return '今天';
  }
  
  /// 格式化日期
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 格式化创建时间
  String get formattedCreatedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  /// 搜索匹配
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    
    // 搜索标题
    if (title.toLowerCase().contains(lowerQuery)) return true;
    
    // 搜索内容
    if (content.toLowerCase().contains(lowerQuery)) return true;
    
    // 搜索标签
    for (final tag in tags) {
      if (tag.name.toLowerCase().contains(lowerQuery)) return true;
    }
    
    // 搜索位置
    if (locationName?.toLowerCase().contains(lowerQuery) == true) return true;
    
    return false;
  }
  
  /// 是否包含特定标签
  bool hasTag(String tagName) {
    return tags.any((tag) => tag.name.toLowerCase() == tagName.toLowerCase());
  }
  
  /// 是否包含媒体文件
  bool get hasMedia => mediaFiles.isNotEmpty;
  
  /// 是否包含图片
  bool get hasImages => mediaFiles.any((media) => media.isImage);
  
  /// 是否包含视频
  bool get hasVideos => mediaFiles.any((media) => media.isVideo);
  
  /// 是否可以编辑（例如：创建后一周内可编辑）
  bool canEdit({int maxDaysAgo = 7}) {
    final now = DateTime.now();
    final daysDiff = now.difference(createdAt).inDays;
    return daysDiff <= maxDaysAgo;
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Journal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ date.hashCode;
  
  @override
  String toString() {
    return 'Journal{id: $id, title: $title, date: $formattedDate, type: $type}';
  }
}