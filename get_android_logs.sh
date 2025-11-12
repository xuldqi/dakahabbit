#!/bin/bash

# 获取 Android 设备日志脚本
# 用法: ./get_android_logs.sh [设备ID] [包名]

DEVICE_ID=${1:-PKT0220519005612}
PACKAGE_NAME=${2:-com.example.dakahabit}
LOG_FILE="android_logs_$(date +%Y%m%d_%H%M%S).txt"

echo "=========================================="
echo "Android 设备日志获取工具"
echo "=========================================="
echo "设备ID: $DEVICE_ID"
echo "包名: $PACKAGE_NAME"
echo "日志文件: $LOG_FILE"
echo "=========================================="
echo ""

# 检查 adb 命令是否存在
if ! command -v adb &> /dev/null; then
    echo "错误: adb 命令未找到，请确保 Android SDK Platform Tools 已安装并在 PATH 中"
    exit 1
fi

# 检查设备连接
if ! adb -s "$DEVICE_ID" devices | grep -q "$DEVICE_ID.*device"; then
    echo "错误: 设备 $DEVICE_ID 未连接或未授权"
    exit 1
fi

echo "✓ 设备已连接"
echo ""

# 选项菜单
echo "请选择日志查看方式:"
echo "1. 实时查看 Flutter 应用日志"
echo "2. 实时查看所有日志"
echo "3. 查看最近的日志（过滤 Flutter/Dart）"
echo "4. 保存日志到文件"
echo "5. 查看应用崩溃日志"
echo "6. 清除日志缓存并查看新日志"
echo ""
read -p "请输入选项 (1-6): " choice

case $choice in
    1)
        echo "正在查看 Flutter 应用日志（实时）..."
        echo "按 Ctrl+C 停止"
        echo ""
        if ! adb -s "$DEVICE_ID" logcat -c; then
            echo "错误: 清除日志缓存失败"
            exit 1
        fi
        # 实时日志流，grep 如果没有匹配会返回非零，但这是正常的
        adb -s "$DEVICE_ID" logcat | grep -E "flutter|dart|$PACKAGE_NAME" || true
        ;;
    2)
        echo "正在查看所有日志（实时）..."
        echo "按 Ctrl+C 停止"
        echo ""
        if ! adb -s "$DEVICE_ID" logcat; then
            echo "错误: 获取日志失败"
            exit 1
        fi
        ;;
    3)
        echo "正在查看最近的日志（过滤 Flutter/Dart）..."
        echo ""
        LOG_OUTPUT=$(adb -s "$DEVICE_ID" logcat -d 2>&1)
        if [ $? -ne 0 ]; then
            echo "错误: 获取日志失败"
            exit 1
        fi
        FILTERED_LOG=$(echo "$LOG_OUTPUT" | grep -E "flutter|dart|$PACKAGE_NAME" | tail -100)
        if [ -z "$FILTERED_LOG" ]; then
            echo "警告: 未找到匹配的日志"
        else
            echo "$FILTERED_LOG"
        fi
        ;;
    4)
        echo "正在保存日志到文件: $LOG_FILE"
        echo "按 Ctrl+C 停止"
        echo ""
        
        # 检查文件是否可写
        if ! touch "$LOG_FILE" 2>/dev/null; then
            echo "错误: 无法创建日志文件 $LOG_FILE（可能是权限问题）"
            exit 1
        fi
        
        # 启动后台进程并获取 PID
        adb -s "$DEVICE_ID" logcat > "$LOG_FILE" 2>&1 &
        LOG_PID=$!
        
        # 等待一小段时间检查进程是否成功启动
        sleep 0.5
        if ! kill -0 "$LOG_PID" 2>/dev/null; then
            echo "错误: 无法启动日志记录进程（请检查设备连接）"
            rm -f "$LOG_FILE"
            exit 1
        fi
        
        echo "日志正在保存到 $LOG_FILE (PID: $LOG_PID)"
        echo "按 Ctrl+C 停止保存"
        
        # 标记是否已经清理过
        CLEANUP_DONE=false
        
        # 设置清理函数
        cleanup() {
            if [ "$CLEANUP_DONE" = true ]; then
                return
            fi
            CLEANUP_DONE=true
            
            if kill -0 "$LOG_PID" 2>/dev/null; then
                kill "$LOG_PID" 2>/dev/null
                # 等待进程结束
                sleep 0.5
            fi
            
            if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
                echo ""
                echo "日志已保存到 $LOG_FILE"
            else
                echo ""
                echo "警告: 日志文件为空或不存在"
                rm -f "$LOG_FILE"
            fi
        }
        
        # 设置 trap
        trap cleanup INT TERM
        
        # 等待进程（如果进程自己结束，也会执行清理）
        if wait "$LOG_PID" 2>/dev/null; then
            cleanup
        else
            cleanup
        fi
        ;;
    5)
        echo "正在查看应用崩溃日志..."
        echo ""
        LOG_OUTPUT=$(adb -s "$DEVICE_ID" logcat -d 2>&1)
        if [ $? -ne 0 ]; then
            echo "错误: 获取日志失败"
            exit 1
        fi
        CRASH_LOG=$(echo "$LOG_OUTPUT" | grep -i "fatal\|crash\|exception\|error" | grep -i "$PACKAGE_NAME\|flutter\|dart" | tail -50)
        if [ -z "$CRASH_LOG" ]; then
            echo "未找到崩溃日志"
        else
            echo "$CRASH_LOG"
        fi
        ;;
    6)
        echo "正在清除日志缓存..."
        if ! adb -s "$DEVICE_ID" logcat -c; then
            echo "错误: 清除日志缓存失败"
            exit 1
        fi
        echo "✓ 日志缓存已清除"
        echo ""
        echo "等待 5 秒后查看新日志..."
        sleep 5
        echo ""
        echo "最近的日志:"
        LOG_OUTPUT=$(adb -s "$DEVICE_ID" logcat -d 2>&1)
        if [ $? -ne 0 ]; then
            echo "错误: 获取日志失败"
            exit 1
        fi
        FILTERED_LOG=$(echo "$LOG_OUTPUT" | grep -E "flutter|dart|$PACKAGE_NAME" | tail -50)
        if [ -z "$FILTERED_LOG" ]; then
            echo "未找到匹配的日志"
        else
            echo "$FILTERED_LOG"
        fi
        ;;
    *)
        echo "无效选项"
        exit 1
        ;;
esac

