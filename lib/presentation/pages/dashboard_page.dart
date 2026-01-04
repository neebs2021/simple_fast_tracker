import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_fast_tracker/presentation/controllers/dashboard_controller.dart';
import 'package:simple_fast_tracker/presentation/pages/history/history_page.dart';
import 'package:simple_fast_tracker/presentation/pages/home/home_page.dart';
import 'package:simple_fast_tracker/presentation/pages/settings/settings_page.dart';

import '../../../core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomePage(),
          HistoryPage(),
          SettingsPage(),
        ],
      )),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex.value,
        onDestinationSelected: controller.changePage,
        backgroundColor: AppColors.backgroundLight,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer, color: AppColors.primary),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      )),
    );
  }
}
