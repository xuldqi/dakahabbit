import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

/// Logger 文件操作帮助类（IO 平台实现）
class LoggerFileHelper {
  static File? getFile(String filePath) => File(filePath);
  
  static Future<Directory> getApplicationDocumentsDirectory() async {
    return await path_provider.getApplicationDocumentsDirectory();
  }
  
  static Directory createDirectory(String dirPath) => Directory(dirPath);
  
  static Future<bool> directoryExists(Directory dir) async {
    return await dir.exists();
  }
  
  static Stream<FileSystemEntity> listDirectory(Directory dir) {
    return dir.list();
  }
  
  static Future<void> writeToFile(File file, String content) async {
    await file.writeAsString(content, mode: FileMode.append, flush: true);
  }
  
  static String? getFilePath(File? file) => file?.path;
  
  static Future<FileStat> getFileStat(File file) async {
    return await file.stat();
  }
  
  static Future<List<String>> readFileLines(File file) async {
    return await file.readAsLines();
  }
  
  static Future<void> deleteFile(File file) async {
    await file.delete();
  }
  
  static String basename(String filePath) => path.basename(filePath);
}

