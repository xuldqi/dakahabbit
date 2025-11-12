import 'dart:convert';

import 'enums.dart';

/// 打卡记录数据模型
class CheckIn {
  const CheckIn({
    this.id,
    required this.habitId,
    required this.checkDate,
    required this.checkTime,
    this.status = CheckInStatus.completed,
    this.note,
    this.mood,
    this.qualityScore,
    this.durationMinutes,
    this.photos,
    this.isMakeup = false,
    this.makeupOriginalDate,
    this.latitude,
    this.longitude,
    this.locationName,
    this.extraData,
    this.createdAt,
    this.updatedAt,
  });

  /// 打卡记录ID
  final int? id;

  /// 关联的习惯ID
  final int habitId;

  /// 打卡日期 (YYYY-MM-DD格式)
  final String checkDate;

  /// 打卡时间 (HH:MM格式)
  final String checkTime;

  /// 打卡状态
  final CheckInStatus status;

  /// 打卡笔记
  final String? note;

  /// 心情
  final String? mood;

  /// 质量评分 (1-5分)
  final int? qualityScore;

  /// 实际用时（分钟）
  final int? durationMinutes;

  /// 照片列表（JSON字符串）
  final String? photos;

  /// 是否是补打卡
  final bool isMakeup;

  /// 原始日期（补打卡时使用）
  final String? makeupOriginalDate;

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

  /// 复制打卡记录并修改部分属性
  CheckIn copyWith({
    int? id,
    int? habitId,
    String? checkDate,
    String? checkTime,
    CheckInStatus? status,
    String? note,
    String? mood,
    int? qualityScore,
    int? durationMinutes,
    String? photos,
    bool? isMakeup,
    String? makeupOriginalDate,
    double? latitude,
    double? longitude,
    String? locationName,
    String? extraData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      checkDate: checkDate ?? this.checkDate,
      checkTime: checkTime ?? this.checkTime,
      status: status ?? this.status,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      qualityScore: qualityScore ?? this.qualityScore,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      photos: photos ?? this.photos,
      isMakeup: isMakeup ?? this.isMakeup,
      makeupOriginalDate: makeupOriginalDate ?? this.makeupOriginalDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 从数据库Map创建打卡记录对象
  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      checkDate: map['check_date'] as String,
      checkTime: map['check_time'] as String,
      status: CheckInStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'completed'),
        orElse: () => CheckInStatus.completed,
      ),
      note: map['note'] as String?,
      mood: map['mood'] as String?,
      qualityScore: map['quality_score'] as int?,
      durationMinutes: map['duration_minutes'] as int?,
      photos: map['photos'] as String?,
      isMakeup: (map['is_makeup'] as int? ?? 0) == 1,
      makeupOriginalDate: map['makeup_original_date'] as String?,
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
      'habit_id': habitId,
      'check_date': checkDate,
      'check_time': checkTime,
      'status': status.name,
      'note': note,
      'mood': mood,
      'quality_score': qualityScore,
      'duration_minutes': durationMinutes,
      'photos': photos,
      'is_makeup': isMakeup ? 1 : 0,
      'makeup_original_date': makeupOriginalDate,
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
      'habitId': habitId,
      'checkDate': checkDate,
      'checkTime': checkTime,
      'status': status.name,
      'note': note,
      'mood': mood,
      'qualityScore': qualityScore,
      'durationMinutes': durationMinutes,
      'photos': photos != null ? jsonDecode(photos!) : null,
      'isMakeup': isMakeup,
      'makeupOriginalDate': makeupOriginalDate,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'extraData': extraData != null ? jsonDecode(extraData!) : null,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON创建打卡记录对象
  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as int?,
      habitId: json['habitId'] as int,
      checkDate: json['checkDate'] as String,
      checkTime: json['checkTime'] as String,
      status: CheckInStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'completed'),
        orElse: () => CheckInStatus.completed,
      ),
      note: json['note'] as String?,
      mood: json['mood'] as String?,
      qualityScore: json['qualityScore'] as int?,
      durationMinutes: json['durationMinutes'] as int?,
      photos: json['photos'] != null 
          ? jsonEncode(json['photos'])
          : null,
      isMakeup: json['isMakeup'] as bool? ?? false,
      makeupOriginalDate: json['makeupOriginalDate'] as String?,
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

  /// 获取打卡的完整日期时间
  DateTime getCheckDateTime() {
    final dateTime = DateTime.parse('${checkDate}T$checkTime:00');
    return dateTime;
  }

  /// 创建今天的打卡记录
  factory CheckIn.forToday({
    required int habitId,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return CheckIn(
      habitId: habitId,
      checkDate: formatDate(today),
      checkTime: _formatTime(now),
      status: status,
      note: note,
      mood: mood?.name,
      qualityScore: qualityScore,
      durationMinutes: durationMinutes,
      photos: photos != null && photos.isNotEmpty ? jsonEncode(photos) : null,
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

  /// 创建补打卡记录
  factory CheckIn.makeup({
    required int habitId,
    required DateTime originalDate,
    CheckInStatus status = CheckInStatus.completed,
    String? note,
    MoodType? mood,
    int? qualityScore,
    int? durationMinutes,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? locationName,
    Map<String, dynamic>? extraData,
  }) {
    final now = DateTime.now();
    
    return CheckIn(
      habitId: habitId,
      checkDate: formatDate(originalDate),
      checkTime: _formatTime(now),
      status: status,
      note: note,
      mood: mood?.name,
      qualityScore: qualityScore,
      durationMinutes: durationMinutes,
      photos: photos != null && photos.isNotEmpty ? jsonEncode(photos) : null,
      isMakeup: true,
      makeupOriginalDate: formatDate(originalDate),
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

  /// 格式化日期为YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化时间为HH:MM
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  /// 解析日期字符串
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// 解析时间字符串
  static DateTime parseTime(String dateString, String timeString) {
    return DateTime.parse('${dateString}T$timeString:00');
  }

  /// 判断是否是今天的打卡
  bool isToday() {
    final now = DateTime.now();
    final today = formatDate(now);
    return checkDate == today;
  }

  /// 判断是否是成功的打卡
  bool isSuccessful() {
    return status == CheckInStatus.completed || status == CheckInStatus.partial;
  }

  /// 获取质量评分的文字描述
  String getQualityDescription() {
    if (qualityScore == null) return '未评分';
    
    switch (qualityScore!) {
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

  /// 获取状态的文字描述
  String getStatusDescription() {
    switch (status) {
      case CheckInStatus.completed:
        return '已完成';
      case CheckInStatus.partial:
        return '部分完成';
      case CheckInStatus.skipped:
        return '已跳过';
      case CheckInStatus.missed:
        return '未完成';
    }
  }

  @override
  String toString() {
    return 'CheckIn(id: $id, habitId: $habitId, checkDate: $checkDate, '
           'checkTime: $checkTime, status: $status, mood: $mood, '
           'qualityScore: $qualityScore, isMakeup: $isMakeup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CheckIn &&
        other.id == id &&
        other.habitId == habitId &&
        other.checkDate == checkDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, habitId, checkDate, status);
  }
}