// lib/screens/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import '../widgets/stat_card.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final Box _box;
  final FlutterTts _tts = FlutterTts();
  bool _loading = true;

  Map<String, dynamic> profile = {};
  List<Map<String, dynamic>> _medLogs = [];
  int _streakMedication = 0;
  int _streakSteps = 0;
  int _streakHydration = 0;

  int _steps = 2500;
  final int _heartRate = 78;
  int _hydration = 1300;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    // Ensure the box is opened in main; here we just read it
    _box = Hive.box('aayutrack_box');
    await NotificationService.init();
    await _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 120));
    profile = Map<String, dynamic>.from(_box.get('profile', defaultValue: {}));
    final rawLogs = List<Map<dynamic, dynamic>>.from(
      _box.get('med_logs', defaultValue: []),
    );
    _medLogs = rawLogs.map((e) => Map<String, dynamic>.from(e)).toList();

    _streakMedication = (_box.get('streak_med', defaultValue: 0) as int);
    _streakSteps = (_box.get('streak_steps', defaultValue: 0) as int);
    _streakHydration = (_box.get('streak_hydration', defaultValue: 0) as int);

    _animController.forward();
    setState(() => _loading = false);
  }

  Future<void> _remindNow() async {
    final name = profile['name'] ?? 'User';
    final msg =
        'Hello $name. This is AayuTrack reminder. Please take your medicine and stay hydrated.';
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.9);
      await _tts.speak(msg);
      await NotificationService.showInstant(
        title: 'AayuTrack Reminder',
        body: msg,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice reminder sent!')),
        );
      }
    } catch (e) {
      debugPrint('Reminder error: $e');
    }
  }

  Future<void> _generateQuickReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator()),
      ),
    );
    try {
      final name = profile['name'] ?? 'User';
      final date = DateFormat.yMMMd().add_jm().format(DateTime.now());
      await PdfService.generateCheckupReport(
        patientName: name,
        dateTime: date,
        symptom: 'Daily health stats summary',
        diagnosis:
            'Steps: $_steps • Heart Rate: $_heartRate bpm • Water: $_hydration ml\n\nStay consistent!',
        lang: 'en',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Report failed: $e')));
      }
    }
  }

  Future<void> _markSteps(int amount) async {
    final todayKey = 'last_steps_date';
    final last = _box.get(todayKey);
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (last != todayStr && amount >= 1000) {
      _streakSteps++;
      await _box.put('streak_steps', _streakSteps);
      await _box.put(todayKey, todayStr);
    }
    _steps += amount;
    await _loadData();
  }

  Future<void> _markHydration(int amountMl) async {
    final todayKey = 'last_hydration_date';
    final last = _box.get(todayKey);
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (last != todayStr && amountMl >= 200) {
      _streakHydration++;
      await _box.put('streak_hydration', _streakHydration);
      await _box.put(todayKey, todayStr);
    }
    _hydration += amountMl;
    await _loadData();
  }

  Future<void> _toggleMed(Map<String, dynamic> m, bool value) async {
    m['taken'] = value;
    final logs = List<Map<dynamic, dynamic>>.from(
        _box.get('med_logs', defaultValue: []));
    final idx = logs.indexWhere((e) => e['id'] == m['id']);
    if (idx >= 0) {
      logs[idx] = m;
    } else {
      logs.add(m);
    }
    await _box.put('med_logs', logs);
    await _loadData();
  }

  Widget _buildHeader() {
    final name = profile['name'] ?? 'Welcome';
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.local_hospital, color: kTeal, size: 38),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello,', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Stay consistent • Private • Offline',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_note),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  /// Responsive stats row:
  /// - On narrow screens: horizontal scrollable row
  /// - On normal/wide: three cards expanded in a row
  Widget _buildStats() {
    // fixed height for the stat area to avoid vertical overflow from child internals
    const double statsHeight = 120;

    final stats = [
      _StatBox(
        child: StatCard(
          title: 'Steps',
          value: '$_steps',
          icon: Icons.directions_walk,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: 'Heart Rate',
          value: '$_heartRate bpm',
          icon: Icons.favorite,
        ),
      ),
      _StatBox(
        child: StatCard(
          title: 'Hydration',
          value: '$_hydration ml',
          icon: Icons.local_drink,
        ),
      ),
    ];

    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
      child: LayoutBuilder(builder: (ctx, constraints) {
        // if screen is narrow (e.g. phones with small width) -> use horizontal scroll
        if (constraints.maxWidth < 380) {
          return SizedBox(
            height: statsHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                return SizedBox(
                  width: (constraints.maxWidth * 0.7).clamp(110.0, 220.0),
                  child: stats[i],
                );
              },
            ),
          );
        }

        // normal/wider screens: show three in a row with equal width
        return SizedBox(
          height: statsHeight,
          child: Row(
            children: [
              Expanded(child: stats[0]),
              const SizedBox(width: 12),
              Expanded(child: stats[1]),
              const SizedBox(width: 12),
              Expanded(child: stats[2]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMedications() {
    final meds = _medLogs.reversed.take(4).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: kTeal),
                const SizedBox(width: 8),
                Text('Medication',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/reminders'),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const Divider(),
            if (meds.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No medicines logged yet.'),
              )
            else
              ...meds.map(
                (m) => ListTile(
                  dense: true,
                  title: Text(m['name'] ?? 'Medicine'),
                  subtitle: Text('At ${m['time'] ?? '--'}'),
                  trailing: Checkbox(
                    value: m['taken'] == true,
                    onChanged: (v) => _toggleMed(m, v ?? false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active),
            label: const Text('Remind Now'),
            onPressed: _remindNow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export Report'),
            onPressed: _generateQuickReport,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          '💧 Drink a glass of water every morning.\n'
          '🏃‍♂️ Maintain a 30-minute walk routine.\n'
          '💊 Take medicines on time.',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildStats(),
          const SizedBox(height: 14),
          // Streak Cards
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Medication Streak\n$_streakMedication days',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/reminders'),
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Steps Streak\n$_streakSteps days',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _markSteps(1000),
                    child: const Text('Add 1000 steps'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hydration Streak\n$_streakHydration days',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _markHydration(250),
                    child: const Text('Add 250 ml'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildMedications(),
          const SizedBox(height: 14),
          _buildActions(),
          const SizedBox(height: 14),
          _buildHealthTips(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Small helper that constrains stat card height so children cannot overflow vertically.
class _StatBox extends StatelessWidget {
  final Widget child;
  const _StatBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: child,
    );
  }
}
