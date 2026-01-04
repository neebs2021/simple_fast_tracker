import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_controller.dart';
import 'widgets/timer_display.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 40),

              // Timer
              Obx(() => TimerDisplay(
                elapsed: controller.elapsed.value,
                isFasting: controller.currentSession.value != null,
              )),
              
              const SizedBox(height: 40),

              // Action Button
              // Action Button
              Obx(() {
                 bool isFasting = controller.currentSession.value != null;
                 return Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isFasting 
                        ? [AppColors.stop , Colors.red] // Darker for stop
                        : [AppColors.primary, AppColors.accent], // Gradient for start
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFasting ? Colors.black : AppColors.primary).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: controller.toggleFast,
                      child: Center(
                        child: Text(
                          isFasting ? "End Fast" : "Start Fasting",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color:  Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

              // Info Cards (Phase & Water)
              Obx(() { 
                if (controller.currentSession.value != null) {
                   return _buildPhaseInfo(context, controller);
                }
                return const SizedBox.shrink();
              }),
              
              const SizedBox(height: 20),
              
              _buildWaterTracker(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              "Let's stay healthy",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 28),
        )
      ],
    );
  }

  Widget _buildPhaseInfo(BuildContext context, HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                controller.currentPhase,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            controller.phaseDescription,
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(BuildContext context, HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.surfaceLight.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.water.withOpacity(0.2), 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.water.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.water.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Water Intake", 
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Get.isDarkMode ? Colors.white : AppColors.textPrimaryLight
                        )
                      ),
                      Obx(() => Text(
                        "${controller.waterIntake.value * 250} ml", 
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.water, 
                          fontWeight: FontWeight.w600,
                          fontSize: 14
                        )
                      )),
                    ],
                  ),
                ],
              ),
              Row(
                 children: [
                    _buildIconButton(
                      icon: Icons.remove, 
                      onTap: controller.removeWater,
                      color: AppColors.textSecondaryLight
                    ),
                    const SizedBox(width: 12),
                    _buildIconButton(
                      icon: Icons.add, 
                      onTap: controller.addWater,
                      color: AppColors.water,
                      isPrimary: true
                    ),
                 ],
              )
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar Visual
          Container(
            height: 12, // slightly thicker
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.water.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(() {
               final progress = (controller.waterIntake.value / 12).clamp(0.0, 1.0);
               return FractionallySizedBox(
                 alignment: Alignment.centerLeft,
                 widthFactor: progress,
                 child: Container(
                   decoration: BoxDecoration(
                     color: AppColors.water,
                     borderRadius: BorderRadius.circular(10),
                     gradient: LinearGradient(
                       colors: [AppColors.water, const Color(0xFF81D4FA)],
                     )
                   ),
                 ),
               );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, required Color color, bool isPrimary = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12), // larger touch target
          decoration: BoxDecoration(
            color: isPrimary ? color.withOpacity(0.2) : Colors.transparent,
            border: isPrimary ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isPrimary ? color : Colors.grey, size: 20),
        ),
      ),
    );
  }
}
