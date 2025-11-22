// lib/screens/telemedicine_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});
  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final Box box = Hive.box('aayutrack_box');
  final List<Map<String, String>> clinics = [
    {'name': 'City Clinic', 'contact': '080-98765432'},
    {'name': 'HealthCare Center', 'contact': '080-12349876'},
  ];

  final _reason = TextEditingController();
  bool _sending = false;

  Future<void> _requestAppointment() async {
    if (_reason.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final history = List<Map<dynamic, dynamic>>.from(
      box.get('tele_history', defaultValue: []),
    );
    history.insert(0, {
      'reason': _reason.text.trim(),
      'time': DateTime.now().toIso8601String(),
    });
    await box.put('tele_history', history);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _sending = false;
      _reason.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Appointment requested')));
  }

  @override
  Widget build(BuildContext context) {
    final tele = List<Map<dynamic, dynamic>>.from(
      box.get('tele_history', defaultValue: []),
    ).map((e) => Map<String, dynamic>.from(e)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Telemedicine')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            const Text(
              'Available Clinics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...clinics.map(
              (c) => Card(
                child: ListTile(
                  leading: const Icon(Icons.local_hospital),
                  title: Text(c['name']!),
                  subtitle: Text(c['contact']!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Request Appointment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Brief reason / symptoms',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _sending ? null : _requestAppointment,
              child: _sending
                  ? const CircularProgressIndicator()
                  : const Text('Request'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Requests History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (tele.isEmpty)
              const Text('No previous requests')
            else
              ...tele.map((r) {
                final when = DateTime.parse(r['time']);
                return Card(
                  child: ListTile(
                    title: Text(r['reason']),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(when)),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
