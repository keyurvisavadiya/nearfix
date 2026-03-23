import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'chatscreen.dart';

const Color _primary = Color(0xFF33365D);
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

  final String _baseUrl =
      "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/";

  @override
  void initState() {
    super.initState();
    _loadUserAndChats();
  }

  Future<void> _loadUserAndChats() async {
    final prefs = await SharedPreferences.getInstance();
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
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1F3E), Color(0xFF33365D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Messages",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                      ),
                    ),
                  ],
                ),
                // Refresh button
                GestureDetector(
                  onTap: _fetchChatList,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary),
                  )
                : _chatList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEBF5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: _primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C3A),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Start a conversation from a booking",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9B9DB8),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: _primary,
                    onRefresh: _fetchChatList,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      itemCount: _chatList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat = _chatList[index];
                        return _ChatCard(
                          currentUserId: _currentUserId!,
                          peerId: int.parse(chat['contact_id'].toString()),
                          name: chat['contact_name'] ?? "User",
                          message: chat['message'] ?? "",
                          time: chat['created_at'] ?? "",
                          imageUrl: chat['contact_image'],
                          baseUrl: _baseUrl,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Chat card
// ════════════════════════════════════════════════════════════════
class _ChatCard extends StatelessWidget {
  final int currentUserId;
  final int peerId;
  final String name;
  final String message;
  final String time;
  final String? imageUrl;
  final String baseUrl;

  const _ChatCard({
    required this.currentUserId,
    required this.peerId,
    required this.name,
    required this.message,
    required this.time,
    required this.baseUrl,
    this.imageUrl,
  });

  String _formatTime(String raw) {
    if (raw.isEmpty) return "";
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return "";
    }
  }

  // Generates a consistent color from the name initial
  Color _avatarColor(String n) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF0EA5E9),
      Color(0xFF8B5CF6),
    ];
    return colors[n.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String fullImageUrl = "$baseUrl$imageUrl";
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final Color aColor = _avatarColor(name);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProviderChatMessageScreen(
            currentUserId: currentUserId,
            peerId: peerId,
            peerName: name,
            peerImageUrl: fullImageUrl,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEFF8), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aColor.withValues(alpha: .15),
                    border: Border.all(
                      color: aColor.withValues(alpha: .3),
                      width: 1.5,
                    ),
                  ),
                  child: hasImage
                      ? ClipOval(
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _initials(name, aColor),
                          ),
                        )
                      : _initials(name, aColor),
                ),
                // Online dot
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C3A),
                          letterSpacing: -.1,
                        ),
                      ),
                      Text(
                        _formatTime(time),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9B9DB8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9B9DB8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Chevron
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(String n, Color color) => Center(
    child: Text(
      n.isNotEmpty ? n[0].toUpperCase() : "?",
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
    ),
  );
}
