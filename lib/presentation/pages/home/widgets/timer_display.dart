import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsed;
  final Duration goal; // For progress calculation
  final bool isFasting;

  const TimerDisplay({
    super.key,
    required this.elapsed,
    this.goal = const Duration(hours: 16), // Default 16:8
    required this.isFasting,
  });

  @override
  Widget build(BuildContext context) {
    double percent = 0.0;
    if (isFasting) {
      percent = (elapsed.inMinutes / goal.inMinutes).clamp(0.0, 1.0);
    }

    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return CircularPercentIndicator(
      radius: 130.0,
      lineWidth: 25.0, // Thicker pleasant ring
      animation: true,
      animateFromLastPercent: true,
      percent: percent,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Get.isDarkMode ? AppColors.surfaceLight.withOpacity(0.1) : Colors.grey.shade200,
      linearGradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      center: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min, // shrink wrap to prevent overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFasting ? Icons.bolt_rounded : Icons.restaurant_rounded,
              size: 32,
              color: isFasting ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 12),
            FittedBox( // Prevent text overflow
              fit: BoxFit.scaleDown,
              child: Text(
                isFasting ? "$hours:$minutes:$seconds" : "Ready",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                  height: 1.0, 
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isFasting ? "Fasting Time" : "to Fast",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
