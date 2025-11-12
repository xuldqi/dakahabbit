import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// 条件导入：仅在非 Web 平台导入文件系统相关包
import 'logger_file_stub.dart'
    if (dart.library.io) 'logger_file_io.dart';

/// 日志级别
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  off(4);
  
  const LogLevel(this.value);
  final int value;
  
  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <(LogLevel other) => value < other.value;
  bool operator <=(LogLevel other) => value <= other.value;
  bool operator >(LogLevel other) => value > other.value;
}

/// 日志工具类
class Logger {
  static LogLevel _level = LogLevel.info;
  static bool _enableFileLogging = false;
  static dynamic _logFile; // 使用 dynamic 以支持不同平台的 File 类型
  static bool _isInitialized = false;
  
  /// 当前日志级别
  static LogLevel get level => _level;
  
  /// 是否启用文件日志
  static bool get enableFileLogging => _enableFileLogging;
  
  /// 是否已初始化
  static bool get isInitialized => _isInitialized;
  
  /// 初始化日志系统
  static Future<void> initialize({
    LogLevel level = LogLevel.info,
    bool enableFileLogging = false,
  }) async {
    _level = level;
    _enableFileLogging = enableFileLogging;
    
    if (_enableFileLogging) {
      try {
        await _initializeLogFile();
      } catch (e) {
        developer.log(
          '初始化日志文件失败: $e',
          name: 'Logger',
          level: 1000,
        );
      }
    }
    
    _isInitialized = true;
    info('Logger initialized with level: ${level.name}, file logging: $enableFileLogging');
  }
  
  /// 初始化日志文件
  static Future<void> _initializeLogFile() async {
    // Web 平台不支持文件日志
    if (kIsWeb) {
      developer.log(
        'Web 平台不支持文件日志',
        name: 'Logger',
        level: 500,
      );
      return;
    }
    
    try {
      // 使用条件导入的文件操作帮助类
      final appDir = await LoggerFileHelper.getApplicationDocumentsDirectory();
      if (appDir == null) return;
      
      // 获取目录路径
      final appDirPath = (appDir as dynamic).path as String?;
      if (appDirPath == null) return;
      
      final logDirPath = '$appDirPath/logs';
      final logDir = LoggerFileHelper.createDirectory(logDirPath);
      
      // 创建日志目录
      if (!await LoggerFileHelper.directoryExists(logDir)) {
        await (logDir as dynamic).create(recursive: true);
      }
      
      // 创建日志文件
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final logFileName = 'dakahabit_$dateStr.log';
      final logFilePath = '$logDirPath/$logFileName';
      _logFile = LoggerFileHelper.getFile(logFilePath);
      
      // 清理旧日志文件
      await _cleanOldLogFiles(logDir);
      
    } catch (e) {
      developer.log(
        '初始化日志文件失败: $e',
        name: 'Logger',
        level: 1000,
      );
    }
  }
  
  /// 清理旧日志文件（保留最近7天的日志）
  static Future<void> _cleanOldLogFiles(dynamic logDir) async {
    if (kIsWeb) return;
    
    try {
      final fileList = await LoggerFileHelper.listDirectory(logDir).toList();
      final files = fileList.where((entity) {
        // 检查是否是文件
        try {
          final path = LoggerFileHelper.getFilePath(entity);
          return path != null;
        } catch (e) {
          return false;
        }
      }).toList();
      final now = DateTime.now();
      const maxAge = Duration(days: 7);
      
      for (final file in files) {
        try {
          final stat = await LoggerFileHelper.getFileStat(file);
          final modified = (stat as dynamic).modified as DateTime;
          final age = now.difference(modified);
          
          if (age > maxAge) {
            await LoggerFileHelper.deleteFile(file);
            developer.log('删除过期日志文件: ${LoggerFileHelper.getFilePath(file)}', name: 'Logger');
          }
        } catch (e) {
          // 跳过无法处理的文件
          continue;
        }
      }
    } catch (e) {
      developer.log('清理旧日志文件失败: $e', name: 'Logger', level: 1000);
    }
  }
  
  /// 输出调试日志
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// 输出信息日志
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// 输出警告日志
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// 输出错误日志
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// 内部日志方法
  static void _log(
    LogLevel logLevel,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 检查日志级别
    if (logLevel < _level) return;
    
    // 构建日志消息
    final now = DateTime.now();
    final timestamp = _formatTimestamp(now);
    final levelStr = logLevel.name.toUpperCase();
    final tagStr = tag ?? 'App';
    
    String logMessage = '[$timestamp] [$levelStr] [$tagStr] $message';
    
    if (error != null) {
      logMessage += '\nError: $error';
    }
    
    if (stackTrace != null) {
      logMessage += '\nStackTrace:\n$stackTrace';
    }
    
    // 控制台输出
    _printToConsole(logLevel, logMessage);
    
    // 文件输出
    if (_enableFileLogging) {
      _writeToFile(logMessage);
    }
  }
  
  /// 格式化时间戳
  static String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.year}-'
           '${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}.'
           '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }
  
  /// 控制台输出
  static void _printToConsole(LogLevel logLevel, String message) {
    if (kDebugMode) {
      // 在调试模式下使用不同的颜色输出
      switch (logLevel) {
        case LogLevel.debug:
          developer.log(message, name: 'DEBUG', level: 500);
          break;
        case LogLevel.info:
          developer.log(message, name: 'INFO', level: 800);
          break;
        case LogLevel.warning:
          developer.log(message, name: 'WARNING', level: 900);
          break;
        case LogLevel.error:
          developer.log(message, name: 'ERROR', level: 1000);
          break;
        case LogLevel.off:
          break;
      }
    } else {
      // 在发布模式下直接print
      print(message);
    }
  }
  
  /// 写入文件
  static void _writeToFile(String message) {
    if (kIsWeb || _logFile == null) return;
    
    try {
      LoggerFileHelper.writeToFile(_logFile, '$message\n');
    } catch (e) {
      developer.log('写入日志文件失败: $e', name: 'Logger', level: 1000);
    }
  }
  
  /// 设置日志级别
  static void setLevel(LogLevel level) {
    _level = level;
    info('日志级别已设置为: ${level.name}');
  }
  
  /// 启用文件日志
  static Future<void> enableFileLoggingAsync() async {
    if (_enableFileLogging) return;
    
    _enableFileLogging = true;
    await _initializeLogFile();
    info('文件日志已启用');
  }
  
  /// 禁用文件日志
  static void disableFileLogging() {
    _enableFileLogging = false;
    _logFile = null;
    info('文件日志已禁用');
  }
  
  /// 获取日志文件路径
  static String? getLogFilePath() {
    return LoggerFileHelper.getFilePath(_logFile);
  }
  
  /// 获取所有日志文件
  static Future<List<dynamic>> getAllLogFiles() async {
    if (kIsWeb) return [];
    
    try {
      final appDir = await LoggerFileHelper.getApplicationDocumentsDirectory();
      if (appDir == null) return [];
      
      // 获取目录路径
      final appDirPath = (appDir as dynamic).path as String?;
      if (appDirPath == null) return [];
      
      final logDirPath = '$appDirPath/logs';
      final logDir = LoggerFileHelper.createDirectory(logDirPath);
      
      if (!await LoggerFileHelper.directoryExists(logDir)) {
        return [];
      }
      
      final fileList = await LoggerFileHelper.listDirectory(logDir).toList();
      final files = fileList.where((entity) {
        // 检查是否是文件且以 .log 结尾
        try {
          final path = LoggerFileHelper.getFilePath(entity);
          return path != null && path.endsWith('.log');
        } catch (e) {
          return false;
        }
      }).toList();
      
      // 按修改时间排序
      final fileStats = <MapEntry<dynamic, dynamic>>[];
      for (final file in files) {
        try {
          final stat = await LoggerFileHelper.getFileStat(file);
          fileStats.add(MapEntry(file, stat));
        } catch (e) {
          // 跳过无法获取 stat 的文件
          continue;
        }
      }
      fileStats.sort((a, b) {
        try {
          final aModified = (a.value as dynamic).modified as DateTime;
          final bModified = (b.value as dynamic).modified as DateTime;
          return bModified.compareTo(aModified);
        } catch (e) {
          return 0;
        }
      });
      
      return fileStats.map((e) => e.key).toList();
    } catch (e) {
      error('获取日志文件列表失败: $e');
      return [];
    }
  }
  
  /// 清理所有日志文件
  static Future<bool> clearAllLogs() async {
    if (kIsWeb) return true;
    
    try {
      final appDir = await LoggerFileHelper.getApplicationDocumentsDirectory();
      if (appDir == null) return true;
      
      // 获取目录路径
      final appDirPath = (appDir as dynamic).path as String?;
      if (appDirPath == null) return true;
      
      final logDirPath = '$appDirPath/logs';
      final logDir = LoggerFileHelper.createDirectory(logDirPath);
      
      if (!await LoggerFileHelper.directoryExists(logDir)) {
        return true;
      }
      
      final fileList = await LoggerFileHelper.listDirectory(logDir).toList();
      final files = fileList.where((entity) {
        // 检查是否是文件
        try {
          final path = LoggerFileHelper.getFilePath(entity);
          return path != null;
        } catch (e) {
          return false;
        }
      }).toList();
      
      for (final file in files) {
        await LoggerFileHelper.deleteFile(file);
      }
      
      info('所有日志文件已清理');
      return true;
    } catch (e) {
      error('清理日志文件失败: $e');
      return false;
    }
  }
  
  /// 获取日志文件大小（字节）
  static Future<int> getLogSize() async {
    if (kIsWeb) return 0;
    
    try {
      final files = await getAllLogFiles();
      int totalSize = 0;
      
      for (final file in files) {
        try {
          final stat = await LoggerFileHelper.getFileStat(file);
          totalSize += (stat as dynamic).size as int;
        } catch (e) {
          // 跳过无法获取 stat 的文件
          continue;
        }
      }
      
      return totalSize;
    } catch (e) {
      error('获取日志大小失败: $e');
      return 0;
    }
  }
  
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// 导出日志文件内容
  static Future<String> exportLogs({int? maxLines}) async {
    if (kIsWeb) return '';
    
    try {
      final files = await getAllLogFiles();
      final buffer = StringBuffer();
      
      for (final file in files) {
        final filePath = LoggerFileHelper.getFilePath(file);
        if (filePath == null) continue;
        
        buffer.writeln('=== ${LoggerFileHelper.basename(filePath)} ===');
        
        final lines = await LoggerFileHelper.readFileLines(file);
        final exportLines = maxLines != null && lines.length > maxLines
            ? lines.take(maxLines).toList()
            : lines;
        
        for (final line in exportLines) {
          buffer.writeln(line);
        }
        
        if (maxLines != null && lines.length > maxLines) {
          buffer.writeln('... (省略${lines.length - maxLines}行)');
        }
        
        buffer.writeln();
      }
      
      return buffer.toString();
    } catch (e) {
      error('导出日志失败: $e');
      return '';
    }
  }
  
  /// 性能测试日志
  static void performance(String operation, Duration duration, {String? tag}) {
    if (_level <= LogLevel.debug) {
      debug('Performance: $operation took ${duration.inMilliseconds}ms', tag: tag ?? 'Performance');
    }
  }
  
  /// 网络请求日志
  static void network(String method, String url, {int? statusCode, Duration? duration, String? error}) {
    final buffer = StringBuffer();
    buffer.write('$method $url');
    
    if (statusCode != null) {
      buffer.write(' -> $statusCode');
    }
    
    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }
    
    if (error != null) {
      Logger.error(buffer.toString(), tag: 'Network', error: error);
    } else {
      info(buffer.toString(), tag: 'Network');
    }
  }
  
  /// 数据库操作日志
  static void database(String operation, {String? table, Duration? duration, Object? error}) {
    final buffer = StringBuffer();
    buffer.write('Database: $operation');
    
    if (table != null) {
      buffer.write(' on $table');
    }
    
    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }
    
    if (error != null) {
      Logger.error(buffer.toString(), tag: 'Database', error: error);
    } else {
      debug(buffer.toString(), tag: 'Database');
    }
  }
}