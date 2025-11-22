// lib/screens/emergency_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static final List<Map<String, String>> _staticContacts = [
    {'name': 'Ambulance (Emergency)', 'phone': '102'},
    {'name': 'Local Hospital A', 'phone': '080-12345678'},
    {'name': 'Police', 'phone': '100'},
    {'name': 'Fire', 'phone': '101'},
  ];

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box('aayutrack_box');
    final profile = Map<String, dynamic>.from(
      box.get('profile', defaultValue: {}),
    );
    final emergency = profile['contact'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (emergency != null && emergency.toString().isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.contact_phone, color: Colors.red),
                title: const Text('Your emergency contact'),
                subtitle: Text(emergency.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: emergency.toString()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency contact copied')),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Useful numbers',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._staticContacts.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
                title: Text(c['name']!),
                subtitle: Text(c['phone']!),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
  Clipboard.setData(ClipboardData(text: c['phone'] ?? ""));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Number copied to clipboard')),
  );
},

                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning),
            label: const Text('Call nearest ambulance (opens dialer)'),
            onPressed: () {
              // If you later add url_launcher you can open phone dialer here.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dialer open (placeholder)')),
              );
            },
          ),
        ],
      ),
    );
  }
}
