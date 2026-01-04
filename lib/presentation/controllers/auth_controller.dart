import 'package:get/get.dart';
import 'package:simple_fast_tracker/core/helper/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../data/repositories/supabase_fasting_repository.dart';
import '../pages/auth/login_page.dart';
import '../pages/dashboard_page.dart';

class AuthController extends GetxController {
  final _supabaseService = Get.find<SupabaseService>();
  
  // Reactive user state
  final Rxn<User> currentUser = Rxn<User>();
  
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    // Check initial session
    final session = _supabaseService.client.auth.currentSession;
    currentUser.value = session?.user;
    
    if (session != null) {
      Get.offAll(() => const DashboardPage());
    } else {
        // Ensure we are on Login Page if not logged in initially?
        // If main.dart sets home: LoginPage, we are good.
    }

    // Listen to auth state changes
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      currentUser.value = session?.user;
      
      if (session != null) {
        Get.offAll(() => const DashboardPage());
      } 
      // Do NOT auto-redirect to Login on sign out, handle typically manually or let user be guest
    });
  }
  
  void continueAsGuest() {
    Get.offAll(() => const DashboardPage());
  }
  
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      await _supabaseService.client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      Utils.toast('Error', 'Login failed: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      await _supabaseService.client.auth.signUp(email: email, password: password);
      // Determine if we should navigate or wait for email. 
      // Supabase default is often "confirm email".
      Utils.toast('Success', 'Account created! Please check your email.');
    } catch (e) {
      Utils.toast("Error", "Sign up failed: $e", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _supabaseService.client.auth.signOut();
    Get.offAll(() => const LoginPage());
  }

  Future<void> deleteAccount() async {
      try {
          isLoading.value = true;
          
          await SupabaseFastingRepository().deleteAccountData();
          
          // 2. Sign Out
          await _supabaseService.client.auth.signOut();
          
          Get.offAll(() => const LoginPage()); // Go back to login
          Utils.toast('Account Deleted', 'Your account and server data have been removed.');
      } catch(e) {
          Utils.toast('Error', 'Failed to delete account: $e', isError: true);
      } finally {
          isLoading.value = false;
      }
  }
}
