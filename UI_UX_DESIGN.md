# UI/UX 设计规范 - 打卡习惯 (DakaHabit)

## 1. 设计理念

### 1.1 总体风格
**可爱温馨 · 简约实用**
- 采用可爱温馨的设计风格，参考习惯点点等优秀应用
- 柔和的色彩搭配，营造舒适的使用体验
- 圆润的界面元素，减少视觉压力
- 有趣的微动画，增强交互乐趣

### 1.2 设计原则
1. **亲和力** - 界面友好，降低使用门槛
2. **一致性** - 统一的视觉语言和交互方式
3. **简洁性** - 突出核心功能，避免冗余
4. **情感化** - 通过设计传达正向情绪
5. **可用性** - 良好的信息架构和操作反馈

### 1.3 目标用户体验
- **轻松愉悦** - 打卡过程简单有趣
- **成就感** - 通过视觉反馈增强满足感
- **持续性** - 设计鼓励用户坚持使用

## 2. 色彩系统

### 2.1 主色调
```
Primary Colors (主色调)
├── 薄荷绿 #4ECDC4 - 主品牌色，代表清新和活力
├── 温暖橙 #FFB74D - 辅助色，代表阳光和温暖  
├── 柔和粉 #FF6B9D - 强调色，代表可爱和温馨
└── 宁静蓝 #42A5F5 - 信息色，代表可靠和专业
```

### 2.2 辅助色彩
```
Secondary Colors (辅助色彩)
├── 浅薄荷 #A8F0ED - 主色的浅色变体
├── 浅橙色 #FFCC80 - 辅助色的浅色变体
├── 浅粉色 #FFB3D1 - 强调色的浅色变体
├── 浅蓝色 #90CAF9 - 信息色的浅色变体
├── 亮黄色 #FFD93D - 警示和提醒
└── 薄荷紫 #9775FA - 特殊功能标识
```

### 2.3 中性色彩
```
Neutral Colors (中性色彩)
├── 纯白色 #FFFFFF - 背景和卡片
├── 浅灰色 #F8F9FA - 次要背景
├── 中灰色 #E9ECEF - 分隔线和边框
├── 深灰色 #6C757D - 次要文字
├── 炭黑色 #343A40 - 主要文字
└── 阴影色 #00000010 - 阴影效果
```

### 2.4 语义色彩
```
Semantic Colors (语义色彩)
├── 成功绿 #28A745 - 成功状态、完成打卡
├── 警告橙 #FFC107 - 警告状态、即将过期
├── 危险红 #DC3545 - 错误状态、删除操作
├── 信息蓝 #17A2B8 - 提示信息、帮助文本
└── 禁用灰 #6C757D - 禁用状态元素
```

### 2.5 渐变色彩
```
Gradient Colors (渐变色彩)
├── 薄荷渐变: linear-gradient(135deg, #4ECDC4 0%, #44A08D 100%)
├── 橙粉渐变: linear-gradient(135deg, #FFB74D 0%, #FF6B9D 100%)
├── 蓝紫渐变: linear-gradient(135deg, #42A5F5 0%, #9775FA 100%)
├── 日出渐变: linear-gradient(135deg, #FFD93D 0%, #FFB74D 100%)
└── 夕阳渐变: linear-gradient(135deg, #FF6B9D 0%, #9775FA 100%)
```

## 3. 字体系统

### 3.1 字体选择
```
Font Family (字体族)
├── 中文字体: 'PingFang SC', 'SF Pro Text', 'Helvetica Neue'
├── 英文字体: 'SF Pro Text', 'Roboto', 'Helvetica Neue'  
├── 数字字体: 'SF Pro Display', 'Roboto', 'Arial'
└── 图标字体: 'Material Icons', 'Cupertino Icons'
```

### 3.2 字体层级
```
Typography Scale (字体层级)
├── Display Large    - 32sp/40dp - 页面大标题
├── Display Medium   - 28sp/36dp - 卡片标题  
├── Display Small    - 24sp/32dp - 节标题
├── Headline Large   - 20sp/28dp - 列表标题
├── Headline Medium  - 18sp/24dp - 卡片副标题
├── Headline Small   - 16sp/20dp - 表单标签
├── Body Large       - 16sp/24dp - 正文内容
├── Body Medium      - 14sp/20dp - 次要内容
├── Body Small       - 12sp/16dp - 辅助信息
└── Label            - 10sp/16dp - 标签文字
```

### 3.3 字体重量
```
Font Weight (字体重量)
├── Light    - 300 - 辅助信息
├── Regular  - 400 - 正文内容
├── Medium   - 500 - 重要信息
├── Semibold - 600 - 小标题
└── Bold     - 700 - 大标题
```

## 4. 组件规范

### 4.1 按钮组件
```
Button Specifications (按钮规范)

Primary Button (主要按钮)
├── 背景: 薄荷绿渐变 (#4ECDC4 → #44A08D)
├── 文字: 白色 #FFFFFF, 16sp Medium
├── 圆角: 24dp
├── 高度: 48dp
├── 阴影: elevation 2dp
└── 状态: 按下时透明度 0.8

Secondary Button (次要按钮)  
├── 背景: 透明
├── 边框: 2dp 薄荷绿 #4ECDC4
├── 文字: 薄荷绿 #4ECDC4, 16sp Medium
├── 圆角: 24dp
├── 高度: 48dp
└── 状态: 按下时背景 #4ECDC410

Text Button (文本按钮)
├── 背景: 透明  
├── 文字: 薄荷绿 #4ECDC4, 14sp Medium
├── 圆角: 8dp
├── 内边距: 16dp horizontal, 8dp vertical
└── 状态: 按下时背景 #4ECDC410

Floating Action Button (悬浮按钮)
├── 背景: 温暖橙 #FFB74D
├── 图标: 白色 24dp
├── 尺寸: 56dp × 56dp
├── 圆角: 28dp (完全圆形)
├── 阴影: elevation 6dp
└── 状态: 按下时缩放 0.95
```

### 4.2 卡片组件
```
Card Specifications (卡片规范)

Basic Card (基础卡片)
├── 背景: 白色 #FFFFFF
├── 圆角: 16dp
├── 阴影: elevation 2dp
├── 内边距: 16dp
└── 边框: 无

Elevated Card (悬浮卡片)
├── 背景: 白色 #FFFFFF  
├── 圆角: 20dp
├── 阴影: elevation 4dp
├── 内边距: 20dp
└── 状态: 按下时elevation 8dp

Outlined Card (描边卡片)
├── 背景: 白色 #FFFFFF
├── 边框: 1dp 中灰色 #E9ECEF
├── 圆角: 12dp
├── 内边距: 16dp
└── 阴影: 无

Habit Card (习惯卡片)
├── 背景: 白色 #FFFFFF
├── 圆角: 16dp
├── 阴影: elevation 2dp
├── 左侧边框: 4dp 宽色彩条(根据分类)
├── 内边距: 16dp
└── 高度: 最小 80dp
```

### 4.3 输入组件
```
Input Specifications (输入组件规范)

Text Field (文本输入框)
├── 背景: 浅灰色 #F8F9FA
├── 边框: 无 (focus时添加2dp薄荷绿边框)
├── 圆角: 12dp
├── 高度: 48dp
├── 内边距: 16dp horizontal, 12dp vertical
├── 文字: 炭黑色 #343A40, 16sp Regular
├── 提示文字: 深灰色 #6C757D, 16sp Regular
└── 标签: 深灰色 #6C757D, 14sp Medium

Search Field (搜索输入框)
├── 背景: 浅灰色 #F8F9FA
├── 圆角: 24dp
├── 高度: 40dp  
├── 内边距: 16dp horizontal
├── 左图标: 搜索图标 20dp
├── 文字: 炭黑色 #343A40, 14sp Regular
└── 提示文字: 深灰色 #6C757D, 14sp Regular

Dropdown (下拉选择框)
├── 背景: 白色 #FFFFFF
├── 边框: 1dp 中灰色 #E9ECEF
├── 圆角: 12dp
├── 高度: 48dp
├── 内边距: 16dp horizontal
├── 右图标: 下箭头 20dp
└── 选中状态: 薄荷绿边框 2dp
```

### 4.4 列表组件
```
List Specifications (列表组件规范)

List Item (列表项)
├── 背景: 白色 #FFFFFF
├── 高度: 最小 56dp
├── 内边距: 16dp horizontal, 12dp vertical
├── 分隔线: 中灰色 #E9ECEF, 1dp
├── 左图标: 24dp, 距左16dp
├── 标题: 炭黑色 #343A40, 16sp Regular
├── 副标题: 深灰色 #6C757D, 14sp Regular  
└── 右图标: 20dp, 距右16dp

Habit List Item (习惯列表项)
├── 背景: 白色 #FFFFFF
├── 高度: 80dp
├── 内边距: 16dp
├── 左侧: 习惯图标 40dp
├── 中间: 标题和描述文字区域
├── 右侧: 打卡按钮或状态图标
└── 状态指示: 左侧4dp宽色彩条

Check-in Item (打卡记录项)
├── 背景: 白色 #FFFFFF  
├── 高度: 变化 (内容决定)
├── 内边距: 16dp
├── 顶部: 日期和时间
├── 中间: 习惯信息和状态
├── 底部: 备注和心情 (如果有)
└── 状态图标: 右上角
```

## 5. 图标系统

### 5.1 图标风格
```
Icon Style (图标风格)
├── 风格: Material Design + 可爱圆润
├── 线条: 2dp 粗细，圆润端点
├── 尺寸: 16dp, 20dp, 24dp, 32dp, 40dp
├── 颜色: 继承文字颜色或自定义
└── 状态: 激活/未激活有不同透明度
```

### 5.2 常用图标
```
Common Icons (常用图标)
├── home - 首页
├── task_alt - 习惯/任务
├── analytics - 统计
├── book - 日志  
├── settings - 设置
├── add - 添加
├── edit - 编辑
├── delete - 删除
├── check_circle - 完成
├── radio_button_unchecked - 未完成
├── access_time - 时间
├── notifications - 通知
├── star - 收藏/重要
├── emoji_emotions - 心情
├── photo_camera - 拍照
└── more_vert - 更多操作
```

### 5.3 习惯分类图标
```
Category Icons (分类图标)  
├── health - favorite (健康)
├── exercise - fitness_center (运动)
├── study - school (学习)
├── work - work (工作)
├── life - home (生活)
├── social - groups (社交)
├── hobby - palette (爱好)
└── other - more_horiz (其他)
```

## 6. 动画规范

### 6.1 动画原则
```
Animation Principles (动画原则)
├── 时长: 快速响应 (150-300ms), 内容变化 (300-500ms)
├── 缓动: 自然缓动曲线 (ease-out, ease-in-out)
├── 目的: 提供反馈，引导注意，增强体验
├── 频率: 适度使用，避免过度动画
└── 性能: 优先使用transform和opacity
```

### 6.2 常用动画
```
Common Animations (常用动画)

Page Transition (页面转场)
├── 类型: 滑动、淡入淡出
├── 时长: 300ms
├── 缓动: ease-out
└── 方向: 根据导航层级

Button Feedback (按钮反馈)
├── 按下: 缩放至0.95 (100ms)
├── 释放: 回弹至1.0 (200ms)
├── 加载: 旋转动画 (1000ms循环)
└── 成功: 缩放+颜色变化 (300ms)

Card Animation (卡片动画)
├── 出现: 从下往上滑入 + 透明度 (400ms)
├── 消失: 向左滑出 + 透明度 (300ms)
├── 悬停: 阴影增强 (200ms)
└── 点击: 轻微缩放 (150ms)

Check-in Animation (打卡动画)
├── 成功: 图标缩放+旋转+颜色变化 (500ms)
├── 粒子: 周围散发小星星 (800ms)
├── 反弹: 弹性缓动效果
└── 声音: 配合触觉反馈
```

### 6.3 手势动画
```
Gesture Animations (手势动画)
├── 滑动刷新: 下拉刷新动画 (300ms)
├── 滑动删除: 左滑显示删除按钮 (200ms)  
├── 长按: 轻微震动 + 缩放 (100ms)
└── 双击: 连续缩放动画 (200ms × 2)
```

## 7. 布局规范

### 7.1 间距系统
```
Spacing System (间距系统)
├── 4dp - 最小间距
├── 8dp - 小间距 (元素内部)
├── 12dp - 中小间距
├── 16dp - 标准间距 (推荐)
├── 20dp - 中等间距
├── 24dp - 大间距 (卡片间)
├── 32dp - 特大间距 (节之间)
└── 40dp - 页面级间距
```

### 7.2 网格系统
```
Grid System (网格系统)
├── 列数: 4列 (手机), 8列 (平板)
├── 间距: 16dp (列间距)
├── 边距: 16dp (左右边距)  
├── 断点: 360dp (小屏), 768dp (平板)
└── 最大宽度: 1200dp
```

### 7.3 页面结构
```
Page Structure (页面结构)
├── Status Bar - 系统状态栏
├── App Bar - 应用顶栏 (56dp)
├── Content - 主内容区域
├── Bottom Navigation - 底部导航 (80dp)
└── Safe Area - 安全区域适配
```

## 8. 组件状态

### 8.1 交互状态
```
Interaction States (交互状态)
├── Default - 默认状态
├── Hover - 悬停状态 (Web/Desktop)
├── Pressed - 按下状态
├── Focused - 聚焦状态
├── Disabled - 禁用状态
└── Loading - 加载状态
```

### 8.2 数据状态
```
Data States (数据状态)  
├── Empty - 空状态
├── Loading - 加载中
├── Error - 错误状态
├── Success - 成功状态
└── Offline - 离线状态
```

### 8.3 习惯状态
```
Habit States (习惯状态)
├── Active - 激活状态 (薄荷绿)
├── Paused - 暂停状态 (橙色)  
├── Completed - 完成状态 (绿色)
├── Overdue - 过期状态 (红色)
└── Upcoming - 即将到期 (黄色)
```

## 9. 可访问性

### 9.1 颜色对比
```
Color Contrast (颜色对比)
├── 正文文字: 最小对比度 4.5:1
├── 大文字: 最小对比度 3:1  
├── 非文本元素: 最小对比度 3:1
└── 色盲友好: 不仅依赖颜色传达信息
```

### 9.2 触摸目标
```
Touch Targets (触摸目标)
├── 最小尺寸: 48dp × 48dp
├── 推荐尺寸: 56dp × 56dp
├── 间距: 相邻目标间距8dp以上
└── 位置: 易于触达的位置
```

### 9.3 文字可读性
```
Text Readability (文字可读性)
├── 最小字号: 12sp
├── 正文字号: 16sp推荐
├── 行间距: 1.4-1.6倍字号
└── 段落间距: 0.75-1.25倍行高
```

## 10. 深色主题

### 10.1 深色色彩
```
Dark Theme Colors (深色主题色彩)
├── 背景: #121212 - 主背景
├── 表面: #1E1E1E - 卡片背景  
├── 主色: #4ECDC4 - 保持主品牌色
├── 主色变体: #5EDDD4 - 稍亮的变体
├── 次要色: #FFB74D - 保持辅助色
├── 文字主要: #FFFFFF - 主要文字
├── 文字次要: #CCCCCC - 次要文字
└── 文字禁用: #666666 - 禁用文字
```

### 10.2 深色适配
```
Dark Theme Adaptation (深色适配)
├── 阴影: 使用浅色描边替代
├── 分隔线: 使用#333333  
├── 输入框: #2C2C2C背景
├── 按钮: 调整透明度和颜色
└── 图标: 使用白色或浅色变体
```

## 11. 响应式设计

### 11.1 屏幕适配
```
Screen Adaptation (屏幕适配)
├── 小屏 (< 360dp): 单列布局
├── 中屏 (360-768dp): 单列为主，局部双列
├── 大屏 (> 768dp): 多列布局
└── 横屏: 调整布局以适应宽屏
```

### 11.2 内容优先级
```
Content Priority (内容优先级)
├── P0: 核心功能 (打卡按钮)
├── P1: 重要信息 (习惯列表)
├── P2: 辅助信息 (统计数据)
└── P3: 装饰元素 (背景图案)
```

## 12. 品牌元素

### 12.1 Logo设计
```
Logo Design (Logo设计)
├── 主Logo: 文字+图标组合
├── 图标Logo: 纯图标版本
├── 文字Logo: 纯文字版本
├── 最小使用尺寸: 24dp × 24dp
└── 安全空间: Logo周围预留1/2高度空间
```

### 12.2 应用图标
```
App Icon (应用图标)
├── 尺寸: 多种规格 (1024×1024为基础)
├── 风格: 圆角矩形 (iOS), 自适应 (Android)
├── 背景: 薄荷绿渐变
├── 前景: 简化的习惯打卡图标
└── 颜色: 符合品牌色彩
```

这个设计规范为打卡习惯应用提供了完整的UI/UX指导方针，确保界面的一致性、可用性和美观性，同时体现可爱温馨的品牌风格。