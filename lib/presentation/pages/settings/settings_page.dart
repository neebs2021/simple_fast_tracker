import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_page.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Settings", style: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
              // Account Section
              Obx(() {
                final user = auth.currentUser.value;
                if (user != null) {
                   return _buildProfileCard(user.email ?? "User");
                } else {
                   return _buildGuestCard();
                }
              }),
              
              const SizedBox(height: 30),
              
              Text("General", style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 10),
              _buildSettingTile(
                icon: Icons.straighten, 
                title: "Use Imperial Units", 
                trailing: Obx(() => Switch(
                  value: controller.isImperial.value,
                  onChanged: (val) => controller.toggleUnit(),
                  activeColor: AppColors.primary,
                ))
              ),
              
              const SizedBox(height: 30),
              
              Text("Data Management", style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 10),
              _buildSettingTile(
                icon: Icons.upload_file, 
                title: "Export Data (Backup)", 
                onTap: controller.exportData,
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                icon: Icons.file_download, 
                title: "Import Data", 
                onTap: controller.importData,
              ),

              const SizedBox(height: 30),

              Text("About", style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 10),
              _buildSettingTile(icon: Icons.info_outline, title: "About", onTap: () {}),
              const SizedBox(height: 10),
              _buildSettingTile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", onTap: () {}),

              const SizedBox(height: 40),

              // Danger Zone
              Obx(() {
                 if (auth.currentUser.value != null) {
                    return Column(
                      children: [
                         _buildDangerButton("Sign Out", auth.signOut),
                         const SizedBox(height: 16),
                         _buildDangerButton("Delete Account", () => _confirmDelete(auth)),
                      ],
                    );
                 }
                 return const SizedBox.shrink();
              }),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Tap to edit profile", style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondaryLight, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
  
  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 30, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Guest Mode", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                    Text("Sign in to sync your data", style: TextStyle(fontFamily: 'Outfit', color: AppColors.primary.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const LoginPage()), // Navigate to Login
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Sign In / Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, VoidCallback? onTap, Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           if (onTap != null || trailing != null)
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
        ]
      ),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, color: AppColors.textPrimaryLight)
        ),
        title: Text(title, style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight, size: 20),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
  
  Widget _buildDangerButton(String text, VoidCallback onTap) {
      return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: Text(text, style: TextStyle(fontFamily: 'Outfit', color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
      );
  }
  
  void _confirmDelete(AuthController auth) {
      Get.dialog(
          AlertDialog(
              title: const Text("Delete Account"),
              content: const Text("Are you sure? This will delete all your data on the server. Your local data will remain."),
              actions: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                  TextButton(
                      onPressed: () { 
                          Get.back();
                          auth.deleteAccount(); 
                      }, 
                      child: const Text("Delete", style: TextStyle(color: Colors.red))
                  ),
              ],
          )
      );
  }
}
