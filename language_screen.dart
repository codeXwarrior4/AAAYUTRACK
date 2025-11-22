import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  final Function(Locale) onChangedLocale;

  const LanguageScreen({super.key, required this.onChangedLocale});

  @override
  Widget build(BuildContext context) {
    final languages = {
      'en': 'English',
      'hi': 'Hindi',
      'kn': 'Kannada',
      'mr': 'Marathi',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: languages.entries.map((entry) {
          return ListTile(
            title: Text(entry.value),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              onChangedLocale(Locale(entry.key));
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
