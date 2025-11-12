import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';

/// 提醒时间模板
class ReminderTemplate {
  final String name;
  final String description;
  final List<String> times;
  final IconData icon;

  const ReminderTemplate({
    required this.name,
    required this.description,
    required this.times,
    required this.icon,
  });
}

/// 提醒设置组件
class ReminderSetupWidget extends StatefulWidget {
  final bool initialEnabled;
  final List<String> initialTimes;
  final ValueChanged<bool>? onEnabledChanged;
  final ValueChanged<List<String>>? onTimesChanged;

  const ReminderSetupWidget({
    super.key,
    this.initialEnabled = false,
    this.initialTimes = const [],
    this.onEnabledChanged,
    this.onTimesChanged,
  });

  @override
  State<ReminderSetupWidget> createState() => _ReminderSetupWidgetState();
}

class _ReminderSetupWidgetState extends State<ReminderSetupWidget> {
  late bool _enabled;
  late List<String> _reminderTimes;

  static final List<ReminderTemplate> _templates = [
    ReminderTemplate(
      name: '早晨',
      description: '适合晨间习惯',
      times: ['07:00', '08:00'],
      icon: Icons.wb_sunny,
    ),
    ReminderTemplate(
      name: '中午',
      description: '适合午间习惯',
      times: ['12:00', '13:00'],
      icon: Icons.lunch_dining,
    ),
    ReminderTemplate(
      name: '晚上',
      description: '适合晚间习惯',
      times: ['19:00', '20:00'],
      icon: Icons.nightlight,
    ),
    ReminderTemplate(
      name: '全天',
      description: '多次提醒',
      times: ['08:00', '12:00', '18:00', '21:00'],
      icon: Icons.schedule,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
    _reminderTimes = List<String>.from(widget.initialTimes);
  }

  void _toggleEnabled(bool value) {
    setState(() {
      _enabled = value;
    });
    widget.onEnabledChanged?.call(value);
  }

  void _applyTemplate(ReminderTemplate template) {
    setState(() {
      _reminderTimes = List<String>.from(template.times);
      _enabled = true;
    });
    widget.onEnabledChanged?.call(true);
    widget.onTimesChanged?.call(_reminderTimes);
    
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已应用"${template.name}"提醒模板'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_reminderTimes.contains(timeStr)) {
        setState(() {
          _reminderTimes.add(timeStr);
          _reminderTimes.sort();
        });
        widget.onTimesChanged?.call(_reminderTimes);
      }
    }
  }

  void _removeTime(String time) {
    setState(() {
      _reminderTimes.remove(time);
    });
    widget.onTimesChanged?.call(_reminderTimes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '提醒设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: _enabled,
              onChanged: _toggleEnabled,
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_enabled) ...[
          const SizedBox(height: 16),
          const Text(
            '快速模板',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () => _applyTemplate(template),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '提醒时间',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              TextButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加时间'),
              ),
            ],
          ),
          if (_reminderTimes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '点击"添加时间"或选择模板来设置提醒',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderTimes.map((time) {
                return Chip(
                  label: Text(time),
                  onDeleted: () => _removeTime(time),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
        ] else ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_off, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '开启提醒可以帮助你更好地坚持习惯',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ReminderTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(template.icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${template.times.length}个提醒',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

