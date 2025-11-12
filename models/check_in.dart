import 'package:json_annotation/json_annotation.dart';

part 'check_in.g.dart';

/// 打卡状态
enum CheckInStatus {
  @JsonValue('completed')
  completed,      // 已完成
  @JsonValue('partial')
  partial,        // 部分完成
  @JsonValue('skipped')
  skipped,        // 跳过
  @JsonValue('leave')
  leave,          // 请假
}

/// 心情状态
enum Mood {
  @JsonValue('very_happy')
  veryHappy,      // 😄 非常开心
  @JsonValue('happy')
  happy,          // 😊 开心
  @JsonValue('neutral')
  neutral,        // 😐 一般
  @JsonValue('sad')
  sad,            // 😢 难过
  @JsonValue('very_sad')
  verySad,        // 😭 非常难过
}

/// 媒体文件信息
@JsonSerializable()
class MediaFile {
  final String path;        // 文件路径
  final String type;        // 文件类型：image/video
  final int? size;          // 文件大小(字节)
  final String? caption;    // 图片说明
  final DateTime createdAt;
  
  const MediaFile({
    required this.path,
    required this.type,
    this.size,
    this.caption,
    required this.createdAt,
  });
  
  factory MediaFile.fromJson(Map<String, dynamic> json) => _$MediaFileFromJson(json);
  Map<String, dynamic> toJson() => _$MediaFileToJson(this);
  
  /// 创建图片文件
  factory MediaFile.image(String path, {String? caption}) => MediaFile(
    path: path,
    type: 'image',
    caption: caption,
    createdAt: DateTime.now(),
  );
  
  /// 创建视频文件
  factory MediaFile.video(String path, {String? caption}) => MediaFile(
    path: path,
    type: 'video',
    caption: caption,
    createdAt: DateTime.now(),
  );
  
  /// 是否为图片
  bool get isImage => type == 'image';
  
  /// 是否为视频
  bool get isVideo => type == 'video';
}

/// 打卡详细信息
@JsonSerializable()
class CheckInDetail {
  final String? note;                     // 打卡备注
  final Mood? mood;                       // 心情状态
  final int? qualityScore;                // 完成质量评分(1-5)
  final int? actualDurationMinutes;       // 实际持续时间
  final List<MediaFile> mediaFiles;       // 媒体文件
  final Map<String, dynamic>? extraData;  // 扩展数据
  
  const CheckInDetail({
    this.note,
    this.mood,
    this.qualityScore,
    this.actualDurationMinutes,
    this.mediaFiles = const [],
    this.extraData,
  });
  
  factory CheckInDetail.fromJson(Map<String, dynamic> json) => _$CheckInDetailFromJson(json);
  Map<String, dynamic> toJson() => _$CheckInDetailToJson(this);
  
  /// 创建简单打卡详情
  factory CheckInDetail.simple({String? note}) => CheckInDetail(note: note);
  
  /// 创建完整打卡详情
  factory CheckInDetail.full({
    String? note,
    Mood? mood,
    int? qualityScore,
    int? actualDurationMinutes,
    List<MediaFile>? mediaFiles,
    Map<String, dynamic>? extraData,
  }) => CheckInDetail(
    note: note,
    mood: mood,
    qualityScore: qualityScore,
    actualDurationMinutes: actualDurationMinutes,
    mediaFiles: mediaFiles ?? [],
    extraData: extraData,
  );
  
  /// 复制并更新详情
  CheckInDetail copyWith({
    String? note,
    Mood? mood,
    int? qualityScore,
    int? actualDurationMinutes,
    List<MediaFile>? mediaFiles,
    Map<String, dynamic>? extraData,
  }) {
    return CheckInDetail(
      note: note ?? this.note,
      mood: mood ?? this.mood,
      qualityScore: qualityScore ?? this.qualityScore,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      extraData: extraData ?? this.extraData,
    );
  }
  
  /// 是否有内容
  bool get hasContent => 
    note?.isNotEmpty == true ||
    mood != null ||
    qualityScore != null ||
    actualDurationMinutes != null ||
    mediaFiles.isNotEmpty;
}

/// 补卡信息
@JsonSerializable()
class MakeupInfo {
  final bool isMakeup;                    // 是否为补卡
  final DateTime? originalDate;           // 原始应打卡日期
  final String? reason;                   // 补卡原因
  final DateTime makeupDate;              // 补卡时间
  
  const MakeupInfo({
    required this.isMakeup,
    this.originalDate,
    this.reason,
    required this.makeupDate,
  });
  
  factory MakeupInfo.fromJson(Map<String, dynamic> json) => _$MakeupInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MakeupInfoToJson(this);
  
  /// 创建补卡信息
  factory MakeupInfo.makeup({
    required DateTime originalDate,
    String? reason,
  }) => MakeupInfo(
    isMakeup: true,
    originalDate: originalDate,
    reason: reason,
    makeupDate: DateTime.now(),
  );
  
  /// 创建正常打卡信息
  factory MakeupInfo.normal() => MakeupInfo(
    isMakeup: false,
    makeupDate: DateTime.now(),
  );
}

/// 打卡记录模型
@JsonSerializable()
class CheckIn {
  final int? id;
  final int habitId;
  final DateTime checkDate;            // 打卡日期（YYYY-MM-DD）
  final DateTime checkTime;            // 具体打卡时间
  final CheckInStatus status;
  
  // 详细信息
  final CheckInDetail detail;
  
  // 补卡信息
  final MakeupInfo makeupInfo;
  
  // 地理位置信息（可选）
  final double? latitude;
  final double? longitude;
  final String? locationName;
  
  // 时间戳
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const CheckIn({
    this.id,
    required this.habitId,
    required this.checkDate,
    required this.checkTime,
    required this.status,
    required this.detail,
    required this.makeupInfo,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
  Map<String, dynamic> toJson() => _$CheckInToJson(this);
  
  /// 创建新打卡记录
  factory CheckIn.create({
    required int habitId,
    DateTime? checkDate,
    DateTime? checkTime,
    CheckInStatus status = CheckInStatus.completed,
    CheckInDetail? detail,
    MakeupInfo? makeupInfo,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    final now = DateTime.now();
    final date = checkDate ?? now;
    return CheckIn(
      habitId: habitId,
      checkDate: DateTime(date.year, date.month, date.day), // 只保留日期部分
      checkTime: checkTime ?? now,
      status: status,
      detail: detail ?? CheckInDetail.simple(),
      makeupInfo: makeupInfo ?? MakeupInfo.normal(),
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 创建补卡记录
  factory CheckIn.makeup({
    required int habitId,
    required DateTime originalDate,
    String? reason,
    CheckInDetail? detail,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    final now = DateTime.now();
    return CheckIn(
      habitId: habitId,
      checkDate: DateTime(originalDate.year, originalDate.month, originalDate.day),
      checkTime: now,
      status: CheckInStatus.completed,
      detail: detail ?? CheckInDetail.simple(note: reason),
      makeupInfo: MakeupInfo.makeup(originalDate: originalDate, reason: reason),
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// 复制并更新打卡记录
  CheckIn copyWith({
    int? id,
    int? habitId,
    DateTime? checkDate,
    DateTime? checkTime,
    CheckInStatus? status,
    CheckInDetail? detail,
    MakeupInfo? makeupInfo,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      checkDate: checkDate ?? this.checkDate,
      checkTime: checkTime ?? this.checkTime,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      makeupInfo: makeupInfo ?? this.makeupInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// 获取状态描述
  String get statusText {
    switch (status) {
      case CheckInStatus.completed:
        return '已完成';
      case CheckInStatus.partial:
        return '部分完成';
      case CheckInStatus.skipped:
        return '跳过';
      case CheckInStatus.leave:
        return '请假';
    }
  }
  
  /// 获取心情描述
  String? get moodText {
    if (detail.mood == null) return null;
    switch (detail.mood!) {
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
    if (detail.mood == null) return null;
    switch (detail.mood!) {
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
  
  /// 是否为成功的打卡（已完成或部分完成）
  bool get isSuccessful => status == CheckInStatus.completed || status == CheckInStatus.partial;
  
  /// 是否为当天的打卡
  bool get isToday {
    final today = DateTime.now();
    return checkDate.year == today.year &&
           checkDate.month == today.month &&
           checkDate.day == today.day;
  }
  
  /// 是否可以编辑（一般允许当天或最近几天的记录编辑）
  bool canEdit({int maxDaysAgo = 7}) {
    final now = DateTime.now();
    final daysDiff = now.difference(checkDate).inDays;
    return daysDiff <= maxDaysAgo;
  }
  
  /// 是否可以删除
  bool canDelete({int maxDaysAgo = 30}) {
    final now = DateTime.now();
    final daysDiff = now.difference(checkDate).inDays;
    return daysDiff <= maxDaysAgo;
  }
  
  /// 格式化检查日期
  String get formattedCheckDate {
    return '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
  }
  
  /// 格式化检查时间
  String get formattedCheckTime {
    return '${checkTime.hour.toString().padLeft(2, '0')}:${checkTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取打卡天数（相对于今天）
  String get relativeDay {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDateOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);
    
    final difference = todayDate.difference(checkDateOnly).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference == 2) {
      return '前天';
    } else if (difference > 0) {
      return '$difference天前';
    } else if (difference == -1) {
      return '明天';
    } else if (difference == -2) {
      return '后天';
    } else {
      return '${-difference}天后';
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckIn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          checkDate == other.checkDate;

  @override
  int get hashCode => id.hashCode ^ habitId.hashCode ^ checkDate.hashCode;
  
  @override
  String toString() {
    return 'CheckIn{id: $id, habitId: $habitId, checkDate: $formattedCheckDate, status: $status}';
  }
}