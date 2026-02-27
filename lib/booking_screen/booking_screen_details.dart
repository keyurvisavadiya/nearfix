import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix/chat_screen/chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);
const Color pageBg = Color(0xFFF6F7FB);

class BookingDetailsUI extends StatefulWidget {
  final String bookingId;
  const BookingDetailsUI({super.key, required this.bookingId});

  @override
  State<BookingDetailsUI> createState() => _BookingDetailsUIState();
}

class _BookingDetailsUIState extends State<BookingDetailsUI> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_booking_details.php?booking_id=${widget.bookingId}";
    try {
      final response = await http.get(Uri.parse(url), headers: {"ngrok-skip-browser-warning": "true"});
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        setState(() {
          bookingData = decoded['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(backgroundColor: pageBg, body: Center(child: CircularProgressIndicator(color: primaryBtnColor)));

    // Pure logic update only: Map the status string for the UI
    final String rawStatus = (bookingData?['status'] ?? "Pending").toString();
    final bool canCancel = rawStatus.toLowerCase() == 'confirmed' || rawStatus.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Booking Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statusCard(rawStatus.toUpperCase(), widget.bookingId),
            const SizedBox(height: 20),
            _serviceCard(bookingData!['service_name'] ?? "Service", bookingData!['booking_date'] ?? "TBD"),
            const SizedBox(height: 20),
            _professionalCard(bookingData!['provider_name'] ?? "Not Assigned"),
            const SizedBox(height: 20),
            _paymentCard(bookingData!['payment_id'], bookingData!['amount']),
            const SizedBox(height: 20),
            _locationCard(bookingData!['address'] ?? "No Address Provided"),
            const SizedBox(height: 28),
            if (canCancel) _cancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String status, String id) {
    // Back to your original dual-color logic
    bool isCancelled = status.toLowerCase() == 'cancelled';
    bool isCompleted = status.toLowerCase() == 'completed';

    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    if (isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (isCompleted) {
      statusColor = Colors.blue;
      statusIcon = Icons.verified;
    } else if (status.toLowerCase() == 'pending') {
      statusColor = Colors.amber;
      statusIcon = Icons.access_time_filled;
    }

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(height: 12),
          Text("Booking $status", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Reference: #$id", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _serviceCard(String name, String date) {
    return _section("SERVICE", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: primaryBtnColor.withOpacity(0.1),
          child: Icon(_getServiceIcon(name), color: primaryBtnColor)
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
    ));
  }

  Widget _professionalCard(String pName) {
    return _section("PROFESSIONAL", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(pName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text("Verified Provider"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleIcon(Icons.chat, pId: bookingData!['provider_id'], pName: pName),
          const SizedBox(width: 8),
          const _CircleIcon(Icons.call),
        ],
      ),
    ));
  }

  Widget _paymentCard(String? payId, dynamic amount) {
    return _section("PAYMENT DETAILS", Column(
      children: [
        _row("Transaction ID", (payId == null || payId.isEmpty) ? "Pending" : payId),
        _row("Total Amount", "₹$amount", isBold: true),
      ],
    ));
  }

  Widget _locationCard(String address) {
    return _section("LOCATION", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.location_on, color: Colors.red),
      title: Text(address, style: const TextStyle(fontSize: 14)),
    ));
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {},
        child: const Text("Cancel Booking", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))
        ],
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    final s = service.toLowerCase();
    if (s.contains("clean")) return Icons.cleaning_services;
    if (s.contains("plumb")) return Icons.plumbing;
    if (s.contains("elect")) return Icons.electrical_services;
    return Icons.build;
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final dynamic pId;
  final String? pName;
  const _CircleIcon(this.icon, {this.pId, this.pName});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, size: 18, color: primaryBtnColor)
    );
  }
}