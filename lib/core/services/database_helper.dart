/// 数据库帮助类接口（占位文件）
/// 实际实现由 platform-specific 文件提供
class DatabaseHelper {
  static Future<dynamic> openDatabase(String name, int version) {
    throw UnimplementedError('DatabaseHelper.openDatabase must be implemented');
  }
  
  static Future<void> closeDatabase(dynamic database) async {
    // 占位实现
  }
}

