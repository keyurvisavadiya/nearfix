import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'chatscreen.dart' show ProviderChatMessageScreen;

const Color _primary = Color(0xFF33365D);
const Color _accent = Color(0xFF8B5CF6); // Nearfix Purple
const Color _bg = Color(0xFFF4F5FB);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _chatList = [];
  bool _isLoading = true;
  int? _currentUserId;

  final String _baseUrl = "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/";

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('provider_id') ?? prefs.getInt('user_id');
    });
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    if (_currentUserId == null) return;

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
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Chat List Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPad + 15, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1F3E), Color(0xFF33365D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Messages",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isLoading = true);
                    _fetchChatList();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : _chatList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              color: _primary,
              onRefresh: _fetchChatList,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: _chatList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = _chatList[index];

                  int pId = 0;
                  int unreadCount = 0;
                  try {
                    pId = int.parse(chat['contact_id'].toString());
                    unreadCount = int.parse(chat['unread_count']?.toString() ?? "0");
                  } catch (e) {
                    debugPrint("ID Parsing Error: $e");
                  }

                  return _ChatCard(
                    currentUserId: _currentUserId ?? 0,
                    peerId: pId,
                    name: chat['contact_name'] ?? "User",
                    message: chat['message'] ?? "",
                    time: chat['created_at'] ?? "",
                    imageUrl: chat['contact_image'],
                    baseUrl: _baseUrl,
                    unreadCount: unreadCount, // Passing unread count here
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No conversations found",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1C3A), fontSize: 16)),
          const Text("New messages from bookings will appear here",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final int currentUserId;
  final int peerId;
  final String name;
  final String message;
  final String time;
  final String? imageUrl;
  final String baseUrl;
  final int unreadCount; // New variable

  const _ChatCard({
    required this.currentUserId,
    required this.peerId,
    required this.name,
    required this.message,
    required this.time,
    required this.baseUrl,
    this.imageUrl,
    this.unreadCount = 0,
  });

  String _formatTime(String raw) {
    if (raw.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(raw);
      if (DateTime.now().day == dt.day) {
        return DateFormat('hh:mm a').format(dt);
      } else {
        return DateFormat('dd MMM').format(dt);
      }
    } catch (_) { return ""; }
  }

  @override
  Widget build(BuildContext context) {
    final String fullImageUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? (imageUrl!.startsWith('http') ? imageUrl! : "$baseUrl$imageUrl")
        : "";

    return GestureDetector(
      onTap: () {
        if (peerId == 0) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderChatMessageScreen(
              currentUserId: currentUserId,
              peerId: peerId,
              peerName: name,
              peerImageUrl: fullImageUrl,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _primary.withOpacity(0.1),
              backgroundImage: fullImageUrl.isNotEmpty ? NetworkImage(fullImageUrl) : null,
              child: fullImageUrl.isEmpty
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(color: _primary, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontWeight: unreadCount > 0 ? FontWeight.w900 : FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF1A1C3A)
                          )
                      ),
                      Text(_formatTime(time),
                          style: TextStyle(
                              fontSize: 11,
                              color: unreadCount > 0 ? _accent : Colors.grey,
                              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: unreadCount > 0 ? Colors.black87 : Colors.blueGrey,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      // ── UNREAD BADGE ──
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}