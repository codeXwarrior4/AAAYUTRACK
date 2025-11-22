import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';

class AICheckupPage extends StatefulWidget {
  const AICheckupPage({super.key});

  @override
  State<AICheckupPage> createState() => _AICheckupPageState();
}

class _AICheckupPageState extends State<AICheckupPage> {
  final TextEditingController _symptomController = TextEditingController();
  final Box reportBox = Hive.box('aayutrack_reports');
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _result = "";
  String _severity = "";
  bool _loading = false;
  bool _isListening = false;

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _result = "";
      _severity = "";
    });

    final text = _symptomController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _loading = false;
        _result = "⚠️ Please enter symptoms first.";
      });
      return;
    }

    final langName = _getLanguageName(context);
    final response = await GeminiService.analyzeSymptoms(text, langName);

    _parseSeverity(response);

    setState(() {
      _loading = false;
      _result = response;
    });
  }

  void _parseSeverity(String text) {
    final lower = text.toLowerCase();
    if (lower.contains("urgent") || lower.contains("emergency")) {
      _severity = "🔴 Urgent";
    } else if (lower.contains("moderate") || lower.contains("monitor")) {
      _severity = "🟠 Moderate";
    } else {
      _severity = "🟢 Mild";
    }
  }

  void _saveReport() {
    final timestamp = DateTime.now().toIso8601String();
    reportBox.put(timestamp, {
      'symptoms': _symptomController.text.trim(),
      'diagnosis': _result,
      'timestamp': timestamp,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Report saved")),
    );
  }

  Future<void> _exportPDF() async {
    final langCode = Localizations.localeOf(context).languageCode;
    final now = DateFormat.yMMMMd().add_jm().format(DateTime.now());

    await PdfService.generateCheckupReport(
      patientName: "Anonymous",
      dateTime: now,
      symptom: _symptomController.text.trim(),
      diagnosis: _result,
      lang: langCode,
    );
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      final available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _symptomController.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  String _getLanguageName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      case 'kn':
        return 'Kannada';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color severityColor = colorScheme.primary;
    if (_severity.contains("Urgent")) {
      severityColor = colorScheme.error;
    } else if (_severity.contains("Moderate")) {
      severityColor = colorScheme.secondary;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "🧠 AI Health Checkup",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Describe your symptoms",
                  suffixIcon: IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleListening,
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _analyze,
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text("Analyze"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _result.isEmpty ? null : _saveReport,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Report"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _result.isEmpty ? null : _exportPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export PDF"),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🩺 AI Diagnosis",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_severity.isNotEmpty)
                        Text(
                          "Severity: $_severity",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                      const SizedBox(height: 8),
                      MarkdownBody(
                        data: _result,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(theme).copyWith(
                          p: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
