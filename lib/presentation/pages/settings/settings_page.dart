import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            '外观设置',
            [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('主题设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 导航到主题设置页面
                },
              ),
            ],
          ),
          _buildSection(
            context,
            '通知设置',
            [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('提醒设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 导航到通知设置页面
                },
              ),
            ],
          ),
          _buildSection(
            context,
            '数据管理',
            [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('备份设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 导航到备份设置页面
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('隐私设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 导航到隐私设置页面
                },
              ),
            ],
          ),
          _buildSection(
            context,
            '其他',
            [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('关于应用'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 导航到关于页面
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}