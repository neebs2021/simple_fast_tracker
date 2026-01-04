import 'package:get/get.dart';

import '../../core/services/encryption_service.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/entities/fasting_session.dart';
import 'local_fasting_repository.dart';

class SupabaseFastingRepository {
  final _supabase = Get.find<SupabaseService>().client;
  final _encryption = Get.find<EncryptionService>();
  final _localRepo = LocalFastingRepository();

  /// Save session to local DB immediately.
  /// If user is logged in, syncs to Supabase in background.
  Future<void> saveSession(FastingSession session) async {
    // 1. Save Local
    await _localRepo.saveSession(session);
    
    // 2. Sync to Cloud if Logged In
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Fire and forget (or await if we want to ensure sync)
      // For "eventual consistency", we don't block UI on cloud error.
      _syncSessionToCloud(session, user.id);
    }
  }

  /// Returns local history always for speed.
  /// Triggering a full sync might be done via Settings or on App Init.
  Future<List<FastingSession>> getMyHistory() async {
    // 1. Return Local
    List<FastingSession> localSessions = _localRepo.getAllSessions();
    
    // 2. If Local is empty but User is Logged In, try to pull from Cloud (First Run / Restore)
    final user = _supabase.auth.currentUser;
    if (localSessions.isEmpty && user != null) {
        // Attempt restore
        await _pullFromCloud();
        localSessions = _localRepo.getAllSessions();
    }
    
    // 3. Sort
    localSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return localSessions;
  }

  Future<FastingSession?> getActiveSession() async {
    return _localRepo.getActiveSession();
  }
  
  // --- Cloud Sync Helpers ---

  Future<void> _syncSessionToCloud(FastingSession session, String userId) async {
     try {
       final encryptedStart = _encryption.encryptData(session.startTime.toIso8601String());
       final encryptedEnd = session.endTime != null 
           ? _encryption.encryptData(session.endTime!.toIso8601String()) 
           : null;
       final encryptedDuration = _encryption.encryptData(session.duration.inSeconds.toString());
       // User requested 'updated_at' be the encrypted update time string
       final encryptedUpdateTime = _encryption.encryptData(DateTime.now().toIso8601String());

       await _supabase.from('fasting_sessions').upsert({
         'id': session.id,
         'user_id': userId,
         // start_time removed per request
         'encrypted_start_time': encryptedStart,
         'encrypted_end_time': encryptedEnd,
         'encrypted_duration': encryptedDuration,
         'updated_at': encryptedUpdateTime, // Storing encrypted string in text column
       });
     } catch (e) {
       print("Cloud sync failed: $e");
     }
  }
  
  /// Pulls all sessions from Cloud, decrypts, and saves to Local.
  Future<void> _pullFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('fasting_sessions')
          .select()
          .eq('user_id', user.id);

      for (final row in response) {
        try {
          final startStr = _encryption.decryptData(row['encrypted_start_time']);
          String? endStr;
          if (row['encrypted_end_time'] != null) {
            endStr = _encryption.decryptData(row['encrypted_end_time']);
          }

          if (startStr.isNotEmpty) {
             final session = FastingSession(
              id: row['id'],
              startTime: DateTime.parse(startStr),
              endTime: endStr != null && endStr.isNotEmpty ? DateTime.parse(endStr) : null,
            );
            await _localRepo.saveSession(session);
          }
        } catch (e) {
          print("Error decrypting session ${row['id']}: $e");
        }
      }
    } catch (e) {
      print("Pull from cloud failed: $e");
    }
  }
  
  /// Delete account data from Cloud.
  Future<void> deleteAccountData() async {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      // Delete rows
      await _supabase.from('fasting_sessions').delete().eq('user_id', user.id);
      
      // Additional account deletion logic would go here (e.g. calling an Edge Function)
      // Supabase Auth deletion usually requires admin rights or user self-deletion call.
      // await _supabase.rpc('deleteUser'); // Theoretical.
  }
}
