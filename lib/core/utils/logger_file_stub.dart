/// Logger 文件操作占位类（用于 Web 平台）
class LoggerFileHelper {
  static dynamic getFile(String filePath) => null;
  static Future<dynamic> getApplicationDocumentsDirectory() async => null;
  static dynamic createDirectory(String dirPath) => null;
  static Future<bool> directoryExists(dynamic dir) async => false;
  static Stream<dynamic> listDirectory(dynamic dir) => Stream<dynamic>.empty();
  static Future<void> writeToFile(dynamic file, String content) async {}
  static String? getFilePath(dynamic file) => null;
  static Future<dynamic> getFileStat(dynamic file) async => null;
  static Future<List<String>> readFileLines(dynamic file) async => [];
  static Future<void> deleteFile(dynamic file) async {}
  static String basename(String path) => path;
}

// Web 平台的 File 和 Directory 类型占位符
typedef File = dynamic;
typedef Directory = dynamic;
typedef FileStat = dynamic;
