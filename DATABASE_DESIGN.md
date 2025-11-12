# 数据库设计文档 - 打卡习惯 (DakaHabit)

## 1. 数据库概述

### 1.1 技术选择
- **数据库类型**: SQLite
- **ORM框架**: sqflite
- **数据序列化**: json_annotation

### 1.2 设计原则
- 数据规范化，避免冗余
- 支持多对多关系
- 考虑查询性能优化
- 预留扩展字段
- 数据完整性约束

## 2. 数据表结构

### 2.1 习惯表 (habits)

存储用户创建的所有习惯信息。

```sql
CREATE TABLE habits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                    -- 习惯名称
    description TEXT,                      -- 习惯描述
    icon TEXT NOT NULL DEFAULT 'default', -- 图标标识
    category TEXT NOT NULL,               -- 分类
    importance INTEGER DEFAULT 3,          -- 重要性(1-5)
    difficulty INTEGER DEFAULT 2,         -- 难度(1-3: 简单/中等/困难)
    
    -- 时间相关
    cycle_type TEXT NOT NULL DEFAULT 'daily', -- 周期类型: daily/weekly/custom
    cycle_config TEXT,                     -- 周期配置(JSON)
    time_range_start TEXT,                 -- 打卡时间范围开始 (HH:mm)
    time_range_end TEXT,                   -- 打卡时间范围结束 (HH:mm)
    duration_minutes INTEGER,              -- 持续时间(分钟)
    
    -- 目标设置
    target_days INTEGER,                   -- 目标天数
    target_total INTEGER,                  -- 总目标次数
    
    -- 状态和时间
    is_active BOOLEAN DEFAULT TRUE,        -- 是否激活
    is_deleted BOOLEAN DEFAULT FALSE,      -- 是否删除
    start_date TEXT NOT NULL,             -- 开始日期 (YYYY-MM-DD)
    end_date TEXT,                        -- 结束日期 (YYYY-MM-DD)
    
    -- 提醒设置
    reminder_enabled BOOLEAN DEFAULT FALSE, -- 是否启用提醒
    reminder_times TEXT,                   -- 提醒时间列表(JSON)
    
    -- 统计字段
    total_checkins INTEGER DEFAULT 0,     -- 总打卡次数
    streak_count INTEGER DEFAULT 0,       -- 当前连续天数
    max_streak INTEGER DEFAULT 0,         -- 最大连续天数
    
    -- 扩展字段
    extra_config TEXT,                     -- 额外配置(JSON)
    
    -- 时间戳
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 索引
CREATE INDEX idx_habits_category ON habits(category);
CREATE INDEX idx_habits_active ON habits(is_active);
CREATE INDEX idx_habits_created_at ON habits(created_at);
```

#### cycle_config 字段说明
```json
{
  \"weekly\": {
    \"days\": [1, 3, 5], // 周一、周三、周五
    \"weeks_interval\": 1 // 每周
  },
  \"custom\": {
    \"interval_days\": 3, // 每3天
    \"specific_dates\": [\"2024-01-01\", \"2024-01-15\"] // 特定日期
  }
}
```

### 2.2 打卡记录表 (check_ins)

记录每次打卡的详细信息。

```sql
CREATE TABLE check_ins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL,
    
    -- 打卡信息
    check_date TEXT NOT NULL,              -- 打卡日期 (YYYY-MM-DD)
    check_time TEXT NOT NULL,              -- 打卡时间 (HH:mm:ss)
    status TEXT NOT NULL DEFAULT 'completed', -- 状态: completed/partial/skipped/leave
    
    -- 详细信息
    note TEXT,                            -- 打卡备注
    mood TEXT,                            -- 心情状态
    quality_score INTEGER,                -- 完成质量评分(1-5)
    duration_minutes INTEGER,             -- 实际持续时间
    
    -- 媒体文件
    photos TEXT,                          -- 照片路径列表(JSON)
    
    -- 元数据
    is_makeup BOOLEAN DEFAULT FALSE,      -- 是否补卡
    makeup_original_date TEXT,            -- 原始应打卡日期
    
    -- 扩展字段
    extra_data TEXT,                      -- 额外数据(JSON)
    
    -- 时间戳
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
);

-- 索引
CREATE UNIQUE INDEX idx_checkins_habit_date ON check_ins(habit_id, check_date);
CREATE INDEX idx_checkins_date ON check_ins(check_date);
CREATE INDEX idx_checkins_status ON check_ins(status);
CREATE INDEX idx_checkins_created_at ON check_ins(created_at);
```

### 2.3 日志表 (journals)

用户的日记和反思记录。

```sql
CREATE TABLE journals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- 基本信息
    title TEXT NOT NULL,                   -- 日志标题
    content TEXT NOT NULL,                 -- 日志内容
    
    -- 情感信息
    mood TEXT,                            -- 心情状态
    mood_score INTEGER,                   -- 心情评分(1-5)
    
    -- 媒体文件
    photos TEXT,                          -- 图片路径列表(JSON)
    
    -- 标签和分类
    tags TEXT,                            -- 标签列表(JSON)
    category TEXT,                        -- 分类
    
    -- 关联信息
    date TEXT NOT NULL,                   -- 日志日期 (YYYY-MM-DD)
    
    -- 统计信息
    word_count INTEGER DEFAULT 0,        -- 字数统计
    
    -- 状态
    is_private BOOLEAN DEFAULT FALSE,     -- 是否私密
    is_deleted BOOLEAN DEFAULT FALSE,     -- 是否删除
    
    -- 扩展字段
    extra_data TEXT,                      -- 额外数据(JSON)
    
    -- 时间戳
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 索引
CREATE INDEX idx_journals_date ON journals(date);
CREATE INDEX idx_journals_mood ON journals(mood);
CREATE INDEX idx_journals_category ON journals(category);
CREATE INDEX idx_journals_created_at ON journals(created_at);
```

### 2.4 习惯-日志关联表 (habit_journal_relations)

实现习惯和日志的多对多关系。

```sql
CREATE TABLE habit_journal_relations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL,
    journal_id INTEGER NOT NULL,
    
    -- 关联信息
    relation_type TEXT DEFAULT 'general',  -- 关联类型: general/reflection/goal
    relation_note TEXT,                    -- 关联备注
    
    -- 时间戳
    created_at TEXT NOT NULL,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id) REFERENCES journals(id) ON DELETE CASCADE
);

-- 唯一约束和索引
CREATE UNIQUE INDEX idx_habit_journal_unique ON habit_journal_relations(habit_id, journal_id);
CREATE INDEX idx_habit_journal_habit ON habit_journal_relations(habit_id);
CREATE INDEX idx_habit_journal_journal ON habit_journal_relations(journal_id);
```

### 2.5 用户设置表 (user_settings)

存储用户的个人设置和偏好。

```sql
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT NOT NULL UNIQUE,             -- 设置键
    value TEXT NOT NULL,                  -- 设置值
    value_type TEXT NOT NULL DEFAULT 'string', -- 值类型: string/int/bool/json
    
    -- 分组
    category TEXT DEFAULT 'general',      -- 设置分类
    
    -- 时间戳
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 索引
CREATE INDEX idx_settings_category ON user_settings(category);
```

#### 常用设置项
```json
{
  \"theme\": \"light\",                    // 主题: light/dark/auto
  \"language\": \"zh_CN\",               // 语言
  \"notification_enabled\": true,        // 通知开关
  \"default_reminder_time\": \"09:00\",  // 默认提醒时间
  \"first_day_of_week\": 1,             // 一周第一天(0=周日, 1=周一)
  \"data_backup_enabled\": true,        // 数据备份开关
  \"analytics_enabled\": true           // 统计分析开关
}
```

### 2.6 成就表 (achievements)

用户获得的成就和徽章。

```sql
CREATE TABLE achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- 成就信息
    type TEXT NOT NULL,                   -- 成就类型
    name TEXT NOT NULL,                   -- 成就名称
    description TEXT,                     -- 成就描述
    icon TEXT,                           -- 成就图标
    
    -- 获得信息
    habit_id INTEGER,                     -- 关联习惯ID(可为空)
    earned_date TEXT NOT NULL,           -- 获得日期
    earned_value INTEGER,                -- 获得时的数值
    
    -- 奖励信息
    points INTEGER DEFAULT 0,            -- 获得积分
    
    -- 时间戳
    created_at TEXT NOT NULL,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE SET NULL
);

-- 索引
CREATE INDEX idx_achievements_type ON achievements(type);
CREATE INDEX idx_achievements_habit ON achievements(habit_id);
CREATE INDEX idx_achievements_date ON achievements(earned_date);
```

### 2.7 预设习惯模板表 (habit_templates)

系统预设的习惯模板。

```sql
CREATE TABLE habit_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                   -- 模板名称
    description TEXT,                     -- 模板描述
    icon TEXT NOT NULL,                   -- 图标
    category TEXT NOT NULL,               -- 分类
    
    -- 默认设置
    default_cycle_type TEXT DEFAULT 'daily',
    default_time_range_start TEXT,
    default_time_range_end TEXT,
    default_duration_minutes INTEGER,
    default_importance INTEGER DEFAULT 3,
    default_difficulty INTEGER DEFAULT 2,
    
    -- 建议设置
    suggested_reminder_times TEXT,        -- 建议提醒时间(JSON)
    suggested_target_days INTEGER,        -- 建议目标天数
    
    -- 模板信息
    is_popular BOOLEAN DEFAULT FALSE,     -- 是否热门
    usage_count INTEGER DEFAULT 0,       -- 使用次数
    
    -- 时间戳
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- 索引
CREATE INDEX idx_templates_category ON habit_templates(category);
CREATE INDEX idx_templates_popular ON habit_templates(is_popular);
```

## 3. 数据库版本管理

### 3.1 版本控制策略
- 版本号格式: MAJOR.MINOR.PATCH
- 每次结构变更增加版本号
- 提供升级脚本

### 3.2 初始版本 (1.0.0)
包含所有基础表结构。

### 3.3 升级脚本示例
```sql
-- 版本 1.1.0: 添加习惯排序字段
ALTER TABLE habits ADD COLUMN sort_order INTEGER DEFAULT 0;
CREATE INDEX idx_habits_sort_order ON habits(sort_order);

-- 版本 1.2.0: 添加日志心情评分
ALTER TABLE journals ADD COLUMN mood_score INTEGER;
```

## 4. 查询优化

### 4.1 常用查询模式
1. 获取今日需要打卡的习惯
2. 查询某个时间范围内的统计数据
3. 获取与习惯相关的日志
4. 查询用户成就列表

### 4.2 索引策略
- 主键自动索引
- 外键字段建立索引
- 常用查询字段建立复合索引
- 定期分析查询性能

### 4.3 查询示例

#### 获取今日需要打卡的习惯
```sql
SELECT h.* FROM habits h
WHERE h.is_active = TRUE 
  AND h.is_deleted = FALSE
  AND (
    h.cycle_type = 'daily' 
    OR (h.cycle_type = 'weekly' AND /* 检查今天是否在周期内 */)
  )
  AND h.id NOT IN (
    SELECT habit_id FROM check_ins 
    WHERE check_date = date('now', 'localtime')
  );
```

#### 计算习惯完成率
```sql
SELECT 
  h.name,
  COUNT(c.id) as total_checkins,
  COUNT(CASE WHEN c.status = 'completed' THEN 1 END) as completed_checkins,
  ROUND(
    COUNT(CASE WHEN c.status = 'completed' THEN 1 END) * 100.0 / COUNT(c.id), 
    2
  ) as completion_rate
FROM habits h
LEFT JOIN check_ins c ON h.id = c.habit_id
WHERE h.is_active = TRUE
GROUP BY h.id, h.name;
```

#### 获取习惯相关日志
```sql
SELECT j.* FROM journals j
JOIN habit_journal_relations hjr ON j.id = hjr.journal_id
WHERE hjr.habit_id = ? 
  AND j.is_deleted = FALSE
ORDER BY j.date DESC;
```

## 5. 数据完整性约束

### 5.1 外键约束
- 启用外键支持
- 级联删除相关数据
- 防止孤立记录

### 5.2 检查约束
```sql
-- 确保评分在有效范围内
ALTER TABLE check_ins ADD CONSTRAINT chk_quality_score 
CHECK (quality_score IS NULL OR (quality_score >= 1 AND quality_score <= 5));

-- 确保重要性在有效范围内
ALTER TABLE habits ADD CONSTRAINT chk_importance 
CHECK (importance >= 1 AND importance <= 5);

-- 确保难度在有效范围内
ALTER TABLE habits ADD CONSTRAINT chk_difficulty 
CHECK (difficulty >= 1 AND difficulty <= 3);
```

### 5.3 数据验证规则
- 日期格式: YYYY-MM-DD
- 时间格式: HH:mm:ss
- JSON 字段需要验证格式
- 必填字段不能为空

## 6. 数据备份和恢复

### 6.1 备份策略
- 定期自动备份数据库文件
- 支持手动导出数据
- 备份文件加密存储

### 6.2 恢复策略
- 从备份文件恢复数据库
- 数据迁移和导入功能
- 版本兼容性处理

### 6.3 数据导出格式
支持导出为 JSON 格式，便于数据迁移和备份：
```json
{
  \"version\": \"1.0.0\",
  \"export_date\": \"2024-01-01T12:00:00Z\",
  \"habits\": [...],
  \"check_ins\": [...],
  \"journals\": [...],
  \"habit_journal_relations\": [...],
  \"achievements\": [...],
  \"user_settings\": [...]
}
```

## 7. 性能监控

### 7.1 监控指标
- 查询响应时间
- 数据库文件大小
- 索引使用情况
- 慢查询日志

### 7.2 优化建议
- 定期清理过期数据
- 重建索引以提高性能
- 分析查询执行计划
- 考虑数据分区策略

这个数据库设计为打卡习惯应用提供了完整的数据存储解决方案，支持所有核心功能，并考虑了性能优化和扩展性。