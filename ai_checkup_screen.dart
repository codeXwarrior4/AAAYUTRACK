import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../services/gemini_service.dart';

class AICheckupPage extends StatefulWidget {
  const AICheckupPage({super.key});

  @override
  State<AICheckupPage> createState() => _AICheckupPageState();
}

class _AICheckupPageState extends State<AICheckupPage> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  String _selectedLang = "en-IN";
  String _aiResponse = "";

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (!available) return;

    setState(() => _isListening = true);

    await _speech.listen(
      localeId: _selectedLang,
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> runCheckup() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() => _aiResponse = "Analyzing... please wait");

    final response = await GeminiService.analyzeSymptoms(input, _selectedLang);

    setState(() => _aiResponse = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Health Checkup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Language:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLang,
              items: const [
                DropdownMenuItem(
                    value: "en-IN", child: Text("English (India)")),
                DropdownMenuItem(value: "hi-IN", child: Text("Hindi")),
                DropdownMenuItem(value: "mr-IN", child: Text("Marathi")),
              ],
              onChanged: (v) => setState(() => _selectedLang = v!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Describe your symptoms",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isListening ? stopListening : startListening,
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: Text(_isListening ? "Stop" : "Speak"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: runCheckup,
                  child: const Text("Analyze"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("AI Diagnosis:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _aiResponse,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
