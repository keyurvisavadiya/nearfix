import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class NearFixChatService {
  // Use the most stable model name for 2026 free tier
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: 'AIzaSyDniyTPxJE-4nv3yU1N7J6Tam-YzFJ0MEI',
    systemInstruction: Content.system(
        "You are the NearFix Support Bot. Only answer questions about Plumbing, Electricians, Cleaning, Carpentry, and AC Repair in Ahmedabad."
    ),
  );

  Future<String> getResponse(String userPrompt) async {
    try {
      final content = [Content.text(userPrompt)];
      final response = await model.generateContent(content);

      if (response.text == null) return "I'm sorry, I couldn't generate a response.";
      return response.text!;

    } catch (e) {
      debugPrint("--- GEMINI DEBUG ERROR ---");
      debugPrint(e.toString());

      // Handle the "High Demand" 503 error specifically
      if (e.toString().contains("503") || e.toString().contains("overloaded")) {
        return "The AI is currently busy (High Demand). Please wait 10 seconds and try again.";
      }

      // Handle API Key issues
      if (e.toString().contains("403")) {
        return "API Key error. Please verify your key in Google AI Studio.";
      }

      return "Connection error. Check your internet or try again later.";
    }
  }
}