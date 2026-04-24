import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../services/chat_service.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Gemini with your System Instructions
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyDFURPGALZCfZWBJiswteTUlVVG1zTL85k',

      systemInstruction: Content.system(
          "You are the NearFix Support Bot. Only answer questions related to NearFix services: "
              "Plumbing, Electricians, Cleaning, Carpentry, and AC Repair in Ahmedabad. "
              "If the user asks about anything else, say: 'I can only help with NearFix services!'"
      ),
    );
  }

  // Inside _ChatScreenState
  final NearFixChatService _chatService = NearFixChatService();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
    });
    _controller.clear();

    // Call the service
    final botResponse = await _chatService.getResponse(userText);

    setState(() {
      _messages.add({"role": "bot", "text": botResponse});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        title: const Text("Support Chat", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF33365D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF33365D) : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(color: isUser ? Colors.white : const Color(0xFF1A1C3A), fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type your query...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                fillColor: const Color(0xFFF4F5FB),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF33365D), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}