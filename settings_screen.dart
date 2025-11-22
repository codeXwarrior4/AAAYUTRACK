// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'language_screen.dart';
import '../main.dart'; // needed for MyAppTheme

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguageName = "English";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Page Title
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 5),
              child: Text(
                "Settings",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // 🌐 LANGUAGE CARD
            _buildSettingsCard(
              icon: Icons.language,
              iconColor: Colors.teal,
              title: "Language",
              subtitle: _currentLanguageName,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageScreen(
                      onChangedLocale: (Locale newLocale) {
                        setState(() {
                          _currentLanguageName =
                              _mapLanguageCode(newLocale.languageCode);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            // 🌙 DARK MODE TOGGLE (NEW)
            _buildSettingsCard(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.deepPurple,
              title: "Dark Mode",
              subtitle: isDark ? "Enabled" : "Disabled",
              onTap: () {
                final theme = MyAppTheme.of(context);
                theme.toggleTheme(!isDark);
                setState(() {});
              },
            ),

            // 🔔 Notifications
            _buildSettingsCard(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.orange.shade600,
              title: "Notifications",
              subtitle: "Manage alerts & permissions",
              onTap: () {},
            ),

            // 🔐 Privacy
            _buildSettingsCard(
              icon: Icons.lock_outline,
              iconColor: Colors.blueGrey,
              title: "Privacy",
              subtitle: "Data and permissions",
              onTap: () {},
            ),

            const SizedBox(height: 18),

            // About Section
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "About",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            _buildSettingsCard(
              icon: Icons.info_outline,
              iconColor: Colors.indigo,
              title: "About AayuTrack",
              subtitle: "Version 1.0.0",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build clean setting card
  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // map locale code to user-friendly name
  String _mapLanguageCode(String code) {
    switch (code) {
      case 'hi':
        return "Hindi";
      case 'mr':
        return "Marathi";
      case 'kn':
        return "Kannada";
      default:
        return "English";
    }
  }
}
