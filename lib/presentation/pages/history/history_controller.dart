import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../domain/entities/fasting_session.dart';
import '../../../data/repositories/supabase_fasting_repository.dart';

class HistoryController extends GetxController {
  final _repo = SupabaseFastingRepository();
  
  final RxList<FastingSession> allSessions = <FastingSession>[].obs;
  final RxList<FastingSession> selectedSessions = <FastingSession>[].obs;

  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx<DateTime?>(DateTime.now());

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
    }
  }
  
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }
  

  
  final RxString filterType = 'Week'.obs; // Week, Month, All
  
  void onFilterChanged(String? newValue) {
    if (newValue != null) {
      filterType.value = newValue;
      filterSessions();
    }
  }

  void filterSessions() {
    final now = DateTime.now();
    if (filterType.value == 'Week') {
      selectedSessions.assignAll(allSessions.where((s) => s.startTime.isAfter(now.subtract(const Duration(days: 7)))));
    } else if (filterType.value == 'Month') {
      selectedSessions.assignAll(allSessions.where((s) => s.startTime.isAfter(now.subtract(const Duration(days: 30)))));
    } else {
      selectedSessions.assignAll(allSessions);
    }
  }

  // Override loadHistory to apply default filter
  void loadHistory() async {
    final list = await _repo.getMyHistory();
    allSessions.assignAll(list);
    filterSessions();
  }
  // Stats Getters
  int get totalFasts => allSessions.length;

  String get averageDuration {
    if (allSessions.isEmpty) return "0h";
    final completed = allSessions.where((s) => !s.isActive);
    if (completed.isEmpty) return "0h";
    
    final totalSeconds = completed.fold<int>(0, (sum, item) => sum + item.duration.inSeconds);
    final avgSeconds = totalSeconds ~/ completed.length;
    final duration = Duration(seconds: avgSeconds);
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
  }

  String get longestFast {
    if (allSessions.isEmpty) return "0h";
    final completed = allSessions.where((s) => !s.isActive);
    if (completed.isEmpty) return "0h";

    final longest = completed.reduce((curr, next) => curr.duration > next.duration ? curr : next);
    return "${longest.duration.inHours}h ${longest.duration.inMinutes.remainder(60)}m";
  }

  int get currentStreak {
    // Simplified streak: consecutive days looking backwards from today having at least one fast
    // This is a basic implementation
    if (allSessions.isEmpty) return 0;
    
    // Group by date string yyyy-MM-dd
    final dates = allSessions.map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); // Descending
    
    int streak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Check if we fasted today or yesterday to keep streak alive
    if (!dates.contains(today) && !dates.contains(today.subtract(const Duration(days: 1)))) {
      return 0;
    }

    DateTime checkDate = dates.contains(today) ? today : today.subtract(const Duration(days: 1));
    
    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
}
