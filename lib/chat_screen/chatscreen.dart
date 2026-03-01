import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProviderChatMessageScreen extends StatefulWidget {
  final int currentUserId;
  final int peerId;
  final String peerName;
  final String? peerImageUrl;

  const ProviderChatMessageScreen({
    super.key,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    this.peerImageUrl,
  });

  @override
  State<ProviderChatMessageScreen> createState() => _ProviderChatMessageScreenState();
}

class _ProviderChatMessageScreenState extends State<ProviderChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;

  final String _handlerUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/chat_handler.php";

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (t) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse("$_handlerUrl?action=fetch&user1=${widget.currentUserId}&user2=${widget.peerId}"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        if (_messages.length != data['data'].length) {
          setState(() { _messages = data['data']; });
          _scrollToBottom();
        }
      }
    } catch (e) { debugPrint("Chat Error: $e"); }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();
    try {
      await http.post(Uri.parse("$_handlerUrl?action=send"), body: {
        "sender_id": widget.currentUserId.toString(),
        "receiver_id": widget.peerId.toString(),
        "message": text,
      });
      _fetchMessages();
    } catch (e) { debugPrint("Send Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              // IMPROVED: Robust Image loading
              child: ClipOval(
                child: widget.peerImageUrl != null && widget.peerImageUrl!.isNotEmpty
                    ? Image.network(
                  widget.peerImageUrl!,
                  fit: BoxFit.cover,
                  width: 36, height: 36,
                  errorBuilder: (context, error, stackTrace) => Text(widget.peerName[0]),
                )
                    : Text(widget.peerName[0]),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.peerName, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final msg = _messages[index];
            bool isMe = msg['sender_id'].toString() == widget.currentUserId.toString();
            return _buildBubble(msg, isMe);
          },
        )),
        _buildInput(),
      ]),
    );
  }

  Widget _buildBubble(dynamic msgData, bool isMe) {
    String message = msgData['message'] ?? "";
    String rawTime = msgData['created_at'] ?? "";
    String formattedTime = "";
    if (rawTime.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(rawTime);
        formattedTime = DateFormat('hh:mm a').format(dt);
      } catch (e) { formattedTime = ""; }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF8B5CF6) : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 15)),
        ),
        Text(formattedTime, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildInput() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
    child: SafeArea(child: Row(children: [
      Expanded(child: TextField(
        controller: _messageController,
        decoration: InputDecoration(hintText: "Type a message...", filled: true, fillColor: Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)),
      )),
      const SizedBox(width: 8),
      IconButton(icon: const Icon(Icons.send, color: Color(0xFF8B5CF6)), onPressed: _sendMessage),
    ])),
  );
}