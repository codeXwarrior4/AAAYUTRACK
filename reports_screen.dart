// lib/screens/reports_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 for kIsWeb
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_filex/open_filex.dart'; // 👈 correct import
import 'package:intl/intl.dart';
import '../theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final Box _box;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('aayutrack_reports');
    _loadReports();
  }

  void _loadReports() {
    final rawList = List<Map<dynamic, dynamic>>.from(
      _box.get('history', defaultValue: []),
    );

    setState(() {
      _reports = rawList.map((e) => Map<String, dynamic>.from(e)).toList();

      _reports.sort(
        (a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
      );
    });
  }

  Future<void> _openFile(String path) async {
    // ❗ Avoid Web crash
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File viewer not supported on Web")),
      );
      return;
    }

    final file = File(path);

    if (await file.exists()) {
      await OpenFilex.open(path); // 👈 Correct usage
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("File not found: $path")));
    }
  }

  Widget _buildReportTile(Map<String, dynamic> report) {
    final file = File(report['path']);
    final name = file.path.split('/').last;

    final lang = report['lang'] ?? 'en';
    final type = report['type'] ?? 'checkup';

    final icon = type == 'checkup'
        ? Icons.analytics_outlined
        : Icons.picture_as_pdf_outlined;

    final date = DateFormat.yMMMd().add_jm().format(
      DateTime.parse(report['date']),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kMint.withOpacity(0.2),
          child: Icon(icon, color: kTeal),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text("🕒 $date  |  🌐 ${lang.toUpperCase()}"),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          color: kTeal,
          onPressed: () => _openFile(report['path']),
        ),
        onLongPress: () async {
          if (await file.exists()) await file.delete();
          _reports.remove(report);
          _box.put('history', _reports);
          _loadReports();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Report deleted')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports History"),
        centerTitle: true,
        backgroundColor: kTeal,
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Text(
                "No reports found yet.\nGenerate one from AI Checkup or Dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadReports(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: _reports.map(_buildReportTile).toList(),
              ),
            ),
    );
  }
}
