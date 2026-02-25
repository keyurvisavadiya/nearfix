import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'chatscreen.dart'; // Add intl to your pubspec.yaml

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _chatList = [];
  bool _isLoading = true;
  int? _currentUserId;

  final String _baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/";

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    // Use 'provider_id' if you are logged in as a provider
    _currentUserId = prefs.getInt('provider_id') ?? prefs.getInt('user_id');
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    try {
      final response = await http.get(
        Uri.parse("${_baseUrl}get_chat_list.php?user_id=$_currentUserId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success']) {
        setState(() {
          _chatList = decoded['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Messages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _chatList.isEmpty
          ? const Center(child: Text("No messages yet"))
          : RefreshIndicator(
        onRefresh: _fetchChatList,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _chatList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final chat = _chatList[index];
            return ChatCard(
              currentUserId: _currentUserId!,
              peerId: int.parse(chat['contact_id'].toString()),
              name: chat['contact_name'] ?? "User",
              message: chat['message'] ?? "",
              time: chat['created_at'] ?? "",
              imageUrl: chat['contact_image'],
            );
          },
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final int currentUserId;
  final int peerId;
  final String name;
  final String message;
  final String time;
  final String? imageUrl;

  const ChatCard({
    super.key,
    required this.currentUserId,
    required this.peerId,
    required this.name,
    required this.message,
    required this.time,
    this.imageUrl,
  });

  String _formatTime(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('hh:mm a').format(dt); // Displays as 09:40 PM
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullImageUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/$imageUrl";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderChatMessageScreen(
              currentUserId: currentUserId,
              peerId: peerId,
              peerName: name,
              peerImageUrl: fullImageUrl,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? NetworkImage(fullImageUrl)
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Text(name[0], style: const TextStyle(color: Color(0xFF8B5CF6)))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(_formatTime(time), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}