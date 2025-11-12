import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_colors.dart';
import '../../widgets/reminder/reminder_setup_widget.dart';

/// 通知设置页面
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _globalEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _weekendEnabled = true;
  String _defaultTime = '09:00';
  List<String> _quietHours = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '全局提醒',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _globalEnabled,
                          onChanged: (value) {
                            setState(() {
                              _globalEnabled = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    if (!_globalEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '关闭全局提醒后，所有习惯的提醒都将被禁用',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_globalEnabled) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '提醒偏好',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('声音提醒'),
                        subtitle: const Text('提醒时播放提示音'),
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      SwitchListTile(
                        title: const Text('震动提醒'),
                        subtitle: const Text('提醒时震动设备'),
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      SwitchListTile(
                        title: const Text('周末提醒'),
                        subtitle: const Text('周末也接收提醒'),
                        value: _weekendEnabled,
                        onChanged: (value) {
                          setState(() {
                            _weekendEnabled = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '默认提醒时间',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '创建新习惯时的默认提醒时间',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('默认时间'),
                        subtitle: Text(_defaultTime),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final parts = _defaultTime.split(':');
                          final initialTime = TimeOfDay(
                            hour: int.parse(parts[0]),
                            minute: int.parse(parts[1]),
                          );
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _defaultTime =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '免打扰时段',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '设置免打扰时段，该时段内不会发送提醒',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_quietHours.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.bedtime_outlined,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  '未设置免打扰时段',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _setQuietHours,
                                  icon: const Icon(Icons.add),
                                  label: const Text('设置免打扰时段'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListTile(
                          title: const Text('免打扰时段'),
                          subtitle: Text(
                            '${_quietHours[0]} - ${_quietHours[1]}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _setQuietHours,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _quietHours = [];
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '保存设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuietHours() async {
    // 简化实现：设置开始和结束时间
    final startParts = _quietHours.isNotEmpty
        ? _quietHours[0].split(':')
        : ['22', '00'];
    final endParts = _quietHours.length > 1
        ? _quietHours[1].split(':')
        : ['08', '00'];

    final startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    final endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    // 显示对话框让用户选择时间
    final result = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (context) => _QuietHoursDialog(
        initialStart: startTime,
        initialEnd: endTime,
      ),
    );

    if (result != null) {
      setState(() {
        _quietHours = [
          '${result['start']!.hour.toString().padLeft(2, '0')}:${result['start']!.minute.toString().padLeft(2, '0')}',
          '${result['end']!.hour.toString().padLeft(2, '0')}:${result['end']!.minute.toString().padLeft(2, '0')}',
        ];
      });
    }
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),
        backgroundColor: AppColors.success,
      ),
    );
    // TODO: 实际保存到 SharedPreferences 或数据库
  }
}

class _QuietHoursDialog extends StatefulWidget {
  final TimeOfDay initialStart;
  final TimeOfDay initialEnd;

  const _QuietHoursDialog({
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<_QuietHoursDialog> createState() => _QuietHoursDialogState();
}

class _QuietHoursDialogState extends State<_QuietHoursDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStart;
    _endTime = widget.initialEnd;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置免打扰时段'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('开始时间'),
            subtitle: Text(
              '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (picked != null) {
                setState(() {
                  _startTime = picked;
                });
              }
            },
          ),
          ListTile(
            title: const Text('结束时间'),
            subtitle: Text(
              '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (picked != null) {
                setState(() {
                  _endTime = picked;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'start': _startTime,
              'end': _endTime,
            });
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
