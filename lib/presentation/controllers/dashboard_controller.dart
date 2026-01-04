import 'package:get/get.dart';

import '../pages/history/history_controller.dart';

class DashboardController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 1) {
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadHistory();
      }
    }
  }
}
