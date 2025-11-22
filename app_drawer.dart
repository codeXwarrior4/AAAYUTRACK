// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box('aayutrack_box');
    final profile = Map<String, dynamic>.from(
      box.get('profile', defaultValue: {}),
    );
    final name = profile['name'] ?? 'User';

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(box.get('auth_email', defaultValue: '')),
              currentAccountPicture: CircleAvatar(
                backgroundColor: kTeal,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              decoration: BoxDecoration(color: kTeal),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Progress'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Reports'),
              onTap: () => Navigator.of(context).pushNamed('/reports'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Telemedicine'),
              onTap: () => Navigator.of(context).pushNamed('/telemedicine'),
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Emergency'),
              onTap: () => Navigator.of(context).pushNamed('/emergency'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await box.put('loggedIn', false);
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
