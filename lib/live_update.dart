import 'package:flutter/material.dart';

import 'package:civicvote/theme.dart';

class LiveUpdatesBlinker extends StatefulWidget {
  @override
  _LiveUpdatesBlinkerState createState() => _LiveUpdatesBlinkerState();
}

class _LiveUpdatesBlinkerState extends State<LiveUpdatesBlinker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 1-second cycle: 0.5s visible, 0.5s invisible
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        )..repeat(
          reverse: true,
        ); // repeats forward (visible) and backward (invisible)
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FadeTransition(
          opacity: _opacityAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error, // ensure this color is defined
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        Text(
          'LIVE UPDATES',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.error,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
