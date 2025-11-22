import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyBUMa6KLAdfLEj2FTKbxh6lHcSGb7IAcUQ";
  static const String _model = "models/gemini-2.5-flash";

  static Future<String> analyzeSymptoms(String text, String lang) async {
    try {
      final model = GenerativeModel(
        model: _model,
        apiKey: _apiKey,
      );

      final prompt = "Analyze these symptoms in $lang. Respond in $lang: $text";

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? "No analysis returned.";
    } catch (e) {
      return "Exception: $e";
    }
  }
}
