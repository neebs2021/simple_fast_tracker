import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/utils.dart';
import '../../../../core/theme/app_colors.dart';
import 'history_controller.dart';
import 'history_detail_page.dart';
import 'widgets/history_list_item.dart';
import 'widgets/stat_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(title: const Text('History')), 
      body: RefreshIndicator(
        onRefresh: () async => controller.loadHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildStatsGrid(controller),
              const SizedBox(height: 16),
              _buildFilterDropdown(controller),
              const SizedBox(height: 20),
              // We need to show the list for the selected day. 
              // Since we are now in a SingleChildScroll, we shouldn't use Expanded/ListView directly if the list is long.
              // We'll use a physics disabled ListView with shrinkWrap.
              _buildDayList(controller),
              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsGrid(HistoryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          StatCard(
            title: "Longest Fast",
            value: controller.longestFast,
            icon: Icons.timer,
            gradientColors: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
          StatCard(
            title: "Avg Duration",
            value: controller.averageDuration,
            icon: Icons.functions,
            gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
          ),
          StatCard(
            title: "Total Fasts",
            value: "${controller.totalFasts}",
            icon: Icons.history,
            gradientColors: const [Color(0xFFFF5F6D), Color(0xFFFFC371)],
          ),
           StatCard(
            title: "Current Streak",
            value: "${controller.currentStreak} Days",
            icon: Icons.local_fire_department,
            gradientColors: const [Color(0xFF4568DC), Color(0xFFB06AB3)],
          ),
        ],
      )),
    );
  }

  Widget _buildDayList(HistoryController controller) {
    return Obx(() {
      if (controller.selectedSessions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "No sessions for selected day.",
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.selectedSessions.length,
        itemBuilder: (context, index) {
          final session = controller.selectedSessions[index];
          return HistoryListItem(
            session: session,
            onTap: () => Get.to(() => HistoryDetailPage(session: session)),
          );
        },
      );
    });
  }

  Widget _buildFilterDropdown(HistoryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Decreased vertical padding
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.transparent), // Removing visible border for cleaner look
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.filterType.value,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  isExpanded: true,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Get.isDarkMode ? Colors.white : AppColors.textPrimaryLight, 
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                  ),
                  dropdownColor: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  items: <String>['Week', 'Month', 'All'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Week' ? 'Last 7 Days' : 
                        value == 'Month' ? 'Last 30 Days' : 'All History'
                      ),
                    );
                  }).toList(),
                  onChanged: controller.onFilterChanged,
                ),
              )),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary, // Using primary color for the action button
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Implement advanced filter dialog
                Utils.toast("Filter", "Advanced filtering coming soon!");
              },
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              tooltip: "Filter Records",
            ),
          ),
        ],
      ),
    );
  }
} // End of HistoryPage
