/// Database 类型占位符（用于 Web 平台）
typedef Database = dynamic;

/// Batch 类型占位符（用于 Web 平台）
typedef Batch = dynamic;

/// Transaction 类型占位符（用于 Web 平台）
typedef Transaction = dynamic;

/// ConflictAlgorithm 枚举占位符（用于 Web 平台）
enum ConflictAlgorithm {
  rollback,
  abort,
  fail,
  ignore,
  replace,
}

