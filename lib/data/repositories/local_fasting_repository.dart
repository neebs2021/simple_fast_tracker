import 'package:hive/hive.dart';

import '../../domain/entities/fasting_session.dart';

class LocalFastingRepository {
  final Box _box = Hive.box('fasting_sessions');

  Future<void> saveSession(FastingSession session) async {
    await _box.put(session.id, session);
  }

  List<FastingSession> getAllSessions() {
    return _box.values.cast<FastingSession>().toList();
  }
  
  FastingSession? getActiveSession() {
     try {
       return _box.values.cast<FastingSession>().firstWhere((s) => s.isActive);
     } catch (e) {
       return null;
     }
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
  
  Future<void> clearAll() async {
    await _box.clear();
  }
}
