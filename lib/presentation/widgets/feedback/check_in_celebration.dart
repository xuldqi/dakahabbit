import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';

class CheckInCelebration {
  static Future<void> show(
    BuildContext context, {
    required String habitName,
    int? streakCount,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'check-in-celebration',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return _CelebrationDialog(
          habitName: habitName,
          streakCount: streakCount,
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: curved,
            child: child,
          ),
        );
      },
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({
    required this.habitName,
    this.streakCount,
  });

  final String habitName;
  final int? streakCount;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
    HapticFeedback.mediumImpact();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildMessage(int? streak) {
    if (streak == null || streak <= 1) {
      return '好习惯从今天开始';
    }

    if (streak == 3) {
      return '连续打卡 3 天，养成势头！';
    }
    if (streak == 7) {
      return '连续打卡 7 天，一周成就达成！';
    }
    if (streak == 21) {
      return '连续打卡 21 天，新习惯养成中！';
    }
    if (streak == 30) {
      return '连续打卡 30 天，月度里程碑！';
    }
    if (streak == 100) {
      return '连续打卡 100 天，超级坚持王！';
    }

    return '连续打卡 $streak 天，继续保持！';
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.streakCount;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.habitName} 打卡成功',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _buildMessage(streak),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
