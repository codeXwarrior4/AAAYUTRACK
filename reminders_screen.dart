// lib/screens/reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../services/notification_service.dart';
import '../theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  late final Box _remindersBox;
  List<Map<String, dynamic>> _suggestions = [];
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _remindersBox = Hive.box('aayutrack_reminders');
    _generateSmartSuggestions();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateSmartSuggestions() {
    final hour = DateTime.now().hour;

    final List<Map<String, dynamic>> suggestions = [];

    if (hour < 10) {
      suggestions.add({
        'title': '💧 Morning Hydration',
        'body': 'Drink a glass of water after waking up.',
        'hour': 8,
        'minute': 0,
        'color': Colors.blue.shade100,
        'typeTag': 'hydration',
      });
    } else if (hour < 16) {
      suggestions.add({
        'title': '💊 Afternoon Medicine',
        'body': 'Take your post-lunch medicine.',
        'hour': 14,
        'minute': 0,
        'color': Colors.orange.shade100,
        'typeTag': 'medicine',
      });
    } else {
      suggestions.add({
        'title': '🌙 Night Medicine',
        'body': 'Take medicine before sleep.',
        'hour': 21,
        'minute': 0,
        'color': Colors.purple.shade100,
        'typeTag': 'medicine',
      });
    }

    // remove suggestions already present (compare by title)
    final existingTitles = _remindersBox.values.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return m['title']?.toString() ?? '';
    }).toSet();

    _suggestions =
        suggestions.where((s) => !existingTitles.contains(s['title'])).toList();
  }

  Future<void> _addReminderDialog({Map<String, dynamic>? editData}) async {
    // local controllers & state
    final titleCtr = TextEditingController(
        text: editData != null ? editData['title']?.toString() : '');
    final bodyCtr = TextEditingController(
        text: editData != null ? editData['body']?.toString() : '');
    TimeOfDay time = editData != null
        ? (editData['type'] == 'daily'
            ? TimeOfDay(
                hour: (editData['hour'] ?? 8) as int,
                minute: (editData['minute'] ?? 0) as int)
            : TimeOfDay.fromDateTime(
                DateTime.tryParse(editData['time'] ?? '') ?? DateTime.now()))
        : TimeOfDay.now();
    bool daily = (editData != null ? editData['type'] == 'daily' : false);

    // Show dialog with StatefulBuilder so local variables update correctly
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: StatefulBuilder(builder: (context, setSB) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.15),
                      offset: const Offset(0, 6))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Add Reminder',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtr,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtr,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: time);
                        if (t != null) setSB(() => time = t);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: kTeal),
                            const SizedBox(width: 10),
                            Text('Pick Time: ${time.format(context)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                            value: daily,
                            onChanged: (v) => setSB(() => daily = v ?? false)),
                        const Text('Repeat daily'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.redAccent))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12)),
                          onPressed: () async {
                            final title = titleCtr.text.trim();
                            final body = bodyCtr.text.trim();
                            if (title.isEmpty) {
                              // show quick message
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please enter title')));
                              return;
                            }

                            // determine id
                            final DateTime now = DateTime.now();
                            DateTime scheduled;
                            if (daily) {
                              // scheduled today at chosen time
                              scheduled = DateTime(now.year, now.month, now.day,
                                  time.hour, time.minute);
                              if (scheduled.isBefore(now)) {
                                scheduled =
                                    scheduled.add(const Duration(days: 1));
                              }
                            } else {
                              scheduled = DateTime(now.year, now.month, now.day,
                                  time.hour, time.minute);
                              if (scheduled.isBefore(now)) {
                                scheduled =
                                    scheduled.add(const Duration(days: 1));
                              }
                            }

                            final id = daily
                                ? (time.hour * 100 + time.minute)
                                : (scheduled.millisecondsSinceEpoch ~/ 1000);

                            // schedule via NotificationService
                            try {
                              if (daily) {
                                await NotificationService.scheduleDaily(
                                    title: title, body: body, time: time);
                              } else {
                                await NotificationService.schedule(
                                    title: title, body: body, time: scheduled);
                              }

                              // persist to Hive
                              final record = <String, dynamic>{
                                'id': id,
                                'title': title,
                                'body': body,
                                'type': daily ? 'daily' : 'once',
                                if (daily) 'hour': time.hour,
                                if (daily) 'minute': time.minute,
                                if (!daily) 'time': scheduled.toIso8601String(),
                                'created_at': DateTime.now().toIso8601String(),
                                'completed': false,
                              };

                              await _remindersBox.put(id, record);

                              // refresh suggestions and list
                              _generateSmartSuggestions();
                              setState(() {});
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Reminder saved: $title')));
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to save reminder: $e')));
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _editReminder(Map<String, dynamic> data) async {
    // For edit — prepopulate the dialog
    await _addReminderDialog(editData: data);
  }

  Future<void> _snoozeReminder(Map<String, dynamic> data,
      {int minutes = 10}) async {
    try {
      // cancel existing (optional) and reschedule
      final originalId = data['id'];
      final now = DateTime.now();
      final snTime = now.add(Duration(minutes: minutes));
      final newId = snTime.millisecondsSinceEpoch ~/ 1000;

      await NotificationService.schedule(
          title: data['title'], body: data['body'], time: snTime);

      // save snoozed reminder as a one-time reminder
      final newRecord = <String, dynamic>{
        'id': newId,
        'title': data['title'],
        'body': data['body'],
        'type': 'once',
        'time': snTime.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'snoozed_from': originalId,
        'completed': false,
      };

      await _remindersBox.put(newId, newRecord);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Snoozed for $minutes minutes')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Snooze failed: $e')));
    }
  }

  Future<void> _deleteReminder(Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) return;
    await _remindersBox.delete(id);
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reminder deleted')));
  }

  Future<void> _toggleComplete(Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) return;
    final current = Map<String, dynamic>.from(_remindersBox.get(id) as Map);
    current['completed'] = !(current['completed'] == true);
    await _remindersBox.put(id, current);
    setState(() {});
  }

  List<Map<String, dynamic>> _readRemindersSorted() {
    final raw = _remindersBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // sort: daily first (by hour:minute), then upcoming one-time (by time), then older
    raw.sort((a, b) {
      final ta = a['type'] == 'daily' ? 0 : 1;
      final tb = b['type'] == 'daily' ? 0 : 1;
      if (ta != tb) return ta - tb;

      if (a['type'] == 'daily' && b['type'] == 'daily') {
        final ah = (a['hour'] ?? 0) as int;
        final am = (a['minute'] ?? 0) as int;
        final bh = (b['hour'] ?? 0) as int;
        final bm = (b['minute'] ?? 0) as int;
        return (ah * 60 + am).compareTo(bh * 60 + bm);
      }

      // for one-time
      final da = a['type'] == 'once'
          ? DateTime.tryParse(a['time'] ?? '') ?? DateTime(2100)
          : DateTime(2100);
      final db = b['type'] == 'once'
          ? DateTime.tryParse(b['time'] ?? '') ?? DateTime(2100)
          : DateTime(2100);
      return da.compareTo(db);
    });

    return raw;
  }

  Widget _emptyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none, size: 120, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text('No reminders yet!',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Add one or use Smart Suggestions',
            style: TextStyle(color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _suggestionCards() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.all(12),
            child: Text('💡 Smart Suggestions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        SizedBox(
          height: 150,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 10, right: 10),
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final s = _suggestions[index];
              return GestureDetector(
                onTap: () async {
                  // add as daily by default
                  final time = TimeOfDay(
                      hour: s['hour'] as int, minute: s['minute'] as int);
                  await NotificationService.scheduleDaily(
                      title: s['title'] as String,
                      body: s['body'] as String,
                      time: time);

                  final id = (time.hour * 100 + time.minute);
                  final rec = <String, dynamic>{
                    'id': id,
                    'title': s['title'],
                    'body': s['body'],
                    'type': 'daily',
                    'hour': time.hour,
                    'minute': time.minute,
                    'created_at': DateTime.now().toIso8601String(),
                    'completed': false,
                  };
                  await _remindersBox.put(id, rec);
                  _generateSmartSuggestions();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added: ${s['title']}')));
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: s['color'] as Color?,
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(s['body'] as String, maxLines: 2),
                        const Spacer(),
                        Text(
                            "⏰ ${(s['hour'] as int).toString().padLeft(2, '0')}:${(s['minute'] as int).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.black54)),
                      ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _reminderCard(Map<String, dynamic> data) {
    final bool daily = data['type'] == 'daily';
    final bool completed = data['completed'] == true;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: daily ? Colors.teal.shade50 : Colors.amber.shade50,
          child: Icon(daily ? Icons.repeat : Icons.alarm,
              color: daily ? Colors.teal : Colors.orange),
        ),
        title: Text(data['title']?.toString() ?? 'Reminder',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: completed ? TextDecoration.lineThrough : null)),
        subtitle: Text(
          daily
              ? "Daily at ${data['hour'].toString().padLeft(2, '0')}:${data['minute'].toString().padLeft(2, '0')}"
              : "Once at ${DateFormat('MMM d, h:mm a').format(DateTime.parse(data['time'] ?? DateTime.now().toIso8601String()))}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          // Complete toggle
          IconButton(
            icon: Icon(completed ? Icons.check_circle : Icons.circle_outlined,
                color: completed ? kTeal : Colors.grey),
            onPressed: () => _toggleComplete(data),
            tooltip: completed ? 'Mark incomplete' : 'Mark complete',
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                await _editReminder(data);
              } else if (v == 'snooze') {
                await _snoozeReminder(data, minutes: 10);
              } else if (v == 'delete') {
                await _deleteReminder(data);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'snooze', child: Text('Snooze 10m')),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = _readRemindersSorted();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kTeal,
        onPressed: () => _addReminderDialog(),
        label: const Text('Add Reminder'),
        icon: const Icon(Icons.add),
      ),
      body: reminders.isEmpty
          ? Center(child: _emptyView())
          : RefreshIndicator(
              onRefresh: () async {
                _generateSmartSuggestions();
                setState(() {});
              },
              child: ListView(
                children: [
                  _suggestionCards(),
                  const SizedBox(height: 8),
                  ...reminders.map((r) {
                    final id = r['id']?.toString() ?? UniqueKey().toString();
                    return Dismissible(
                      key: ValueKey(id),
                      background: Container(
                        color: Colors.green.shade400,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        child: const Icon(Icons.snooze, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red.shade400,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete_forever,
                            color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // delete
                          final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Reminder?'),
                                  content: const Text(
                                      'This will remove the reminder permanently.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              ) ??
                              false;
                          if (ok) await _deleteReminder(r);
                          return ok;
                        } else {
                          // left swipe - snooze 10 min
                          await _snoozeReminder(r, minutes: 10);
                          return false; // don't dismiss this item
                        }
                      },
                      child: _reminderCard(r),
                    );
                  }),
                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }
}
