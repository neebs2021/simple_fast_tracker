import 'dart:async';

import 'package:get/get.dart';

import '../../../data/repositories/supabase_fasting_repository.dart';
import '../../../domain/entities/fasting_session.dart';

class HomeController extends GetxController {
  final _repo = SupabaseFastingRepository();
  final Rxn<FastingSession> currentSession = Rxn<FastingSession>();
  final Rx<Duration> elapsed = Duration.zero.obs;
  final RxInt waterIntake = 0.obs; // Cups of water
  
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadActiveSession();
    _startTicker();
  }
  
  void _loadActiveSession() async {
    final session = await _repo.getActiveSession();
    if (session != null) {
      currentSession.value = session;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSession.value != null && currentSession.value!.isActive) {
        elapsed.value = currentSession.value!.duration;
        _checkMilestones(); // Check for autophagy etc.
      } else {
        elapsed.value = Duration.zero;
      }
    });
  }

  Future<void> toggleFast() async {
    if (currentSession.value == null) {
      // Start Fast
      final newSession = FastingSession.startNew();
      currentSession.value = newSession;
      await _repo.saveSession(newSession);
    } else {
      // End Fast
      final endedSession = FastingSession(
        id: currentSession.value!.id,
        startTime: currentSession.value!.startTime,
        endTime: DateTime.now(),
      );
      currentSession.value = null;
      elapsed.value = Duration.zero;
      await _repo.saveSession(endedSession);
    }
  }

  void addWater() {
    waterIntake.value++;
  }
  
  void removeWater() {
    if (waterIntake.value > 0) waterIntake.value--;
  }
  
  void _checkMilestones() {
    // Logic to check phases and maybe notify user
    // For now, just a placeholder
    // if (elapsed.value.inHours == 12) SendNotification("You are in Anabolic State!");
  }
  
  // Logic for tips
  String get currentPhase {
    final hours = elapsed.value.inHours;
    if (hours < 12) return "Anabolic State";
    if (hours < 18) return "Catabolic State";
    if (hours < 24) return "Ketosis";
    if (hours < 72) return "Autophagy";
    return "Deep Ketosis";
  }

  String get phaseDescription {
    final hours = elapsed.value.inHours;
    if (hours < 12) return "Your body is digesting food and storing energy.";
    if (hours < 18) return "You are burning glycogen stores.";
    if (hours < 24) return "Fat burning mode activated.";
    if (hours < 72) return "Cellular repair and cleanup processes active.";
    return "Deep cellular cleansing and immune system regeneration.";
  }
}
