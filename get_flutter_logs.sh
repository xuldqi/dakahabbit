#!/bin/bash

# 使用 Flutter 命令获取日志
# 用法: ./get_flutter_logs.sh [设备ID]

DEVICE_ID=${1:-PKT0220519005612}
FLUTTER_PATH="$HOME/Downloads/flutter/bin/flutter"

echo "=========================================="
echo "Flutter 应用日志查看工具"
echo "=========================================="
echo "设备ID: $DEVICE_ID"
echo "=========================================="
echo ""

# 检查 Flutter 是否可用
if [ ! -f "$FLUTTER_PATH" ]; then
    echo "错误: Flutter 未找到，请检查路径: $FLUTTER_PATH"
    exit 1
fi

# 检查设备连接
if ! adb -s $DEVICE_ID devices | grep -q "$DEVICE_ID.*device"; then
    echo "错误: 设备 $DEVICE_ID 未连接或未授权"
    exit 1
fi

echo "✓ 设备已连接"
echo ""

# 使用 Flutter 日志命令
echo "正在查看 Flutter 应用日志..."
echo "按 Ctrl+C 停止"
echo ""

PATH="$HOME/Downloads/flutter/bin:$PATH" flutter logs -d $DEVICE_ID

