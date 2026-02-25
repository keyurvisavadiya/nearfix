import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix/chat_screen/chatscreen.dart'; // Make sure this contains ProviderChatMessageScreen
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
    // Replace with your current Ngrok link
    final url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_booking_details.php?booking_id=${widget.bookingId}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        setState(() {
          bookingData = decoded['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching booking: $e");
      setState(() => isLoading = false);
    }
  }

  void _showCancelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Cancel Booking?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to cancel\nRef: #${widget.bookingId}? This cannot be undone.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBtnColor,
                        side: const BorderSide(color: primaryBtnColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Keep", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx), // Static for now
                      child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: pageBg, body: Center(child: CircularProgressIndicator(color: primaryBtnColor)));
    }

    if (bookingData == null) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
        body: const Center(child: Text("Booking details not found.")),
      );
    }

    final double w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Booking Details", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 16),
        child: Column(
          children: [
            _statusCard(bookingData!['status'] ?? "Confirmed", widget.bookingId),
            const SizedBox(height: 20),
            _serviceCard(bookingData!['service_name'] ?? "Service", bookingData!['booking_date'] ?? ""),
            const SizedBox(height: 20),
            _professionalCard(bookingData!['provider_name'] ?? "Professional"),
            const SizedBox(height: 20),
            _paymentCard(bookingData!['payment_id'], bookingData!['amount']),
            const SizedBox(height: 20),
            _locationCard(bookingData!['address'] ?? "No address"),
            const SizedBox(height: 28),
            _cancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String status, String id) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: status == 'Cancelled' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: status == 'Cancelled' ? Colors.red.shade50 : const Color(0xFFDFF6EA),
            child: Icon(status == 'Cancelled' ? Icons.close : Icons.check, color: status == 'Cancelled' ? Colors.red : Colors.green),
          ),
          const SizedBox(height: 12),
          Text("Booking $status", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Reference ID: #$id", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _serviceCard(String name, String date) {
    return _section("SERVICE", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 44, width: 44,
        decoration: BoxDecoration(color: primaryBtnColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.cleaning_services, color: primaryBtnColor),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
    ));
  }

  Widget _professionalCard(String pName) {
    return _section("PROFESSIONAL", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(radius: 22, child: Icon(Icons.person)),
      title: Text(pName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text("Verified Provider"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleIcon(
            Icons.chat,
            providerId: int.tryParse(bookingData!['provider_id'].toString()),
            providerName: pName,
          ),
          const SizedBox(width: 10),
          const _CircleIcon(Icons.call),
        ],
      ),
    ));
  }

  Widget _paymentCard(String? payId, dynamic amount) {
    return _section("PAYMENT DETAILS", Column(
      children: [
        _PaymentRow("Transaction ID", payId ?? "Pending"),
        const _PaymentRow("Status", "Paid", isPaid: true),
        const Divider(height: 24),
        _PaymentRow("Total Charged", "\$${amount.toString()}", isTotal: true),
      ],
    ));
  }

  Widget _locationCard(String address) {
    return _section("LOCATION", ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.location_on, color: Colors.deepPurple),
      title: const Text("Home Address"),
      subtitle: Text(address),
    ));
  }

  Widget _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _showCancelSheet(context),
        child: const Text("Cancel Booking", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label, value;
  final bool isPaid, isTotal;
  const _PaymentRow(this.label, this.value, {this.isPaid = false, this.isTotal = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isPaid ? Colors.green : (isTotal ? Colors.deepPurple : Colors.black))),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final int? providerId;
  final String? providerName;

  const _CircleIcon(this.icon, {this.providerId, this.providerName});

  Future<void> _navigateToChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final int myUserId = prefs.getInt('user_id') ?? 1;

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderChatMessageScreen(
            currentUserId: myUserId,
            peerId: providerId ?? 0,
            peerName: providerName ?? "Provider",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (icon == Icons.chat && providerId != null) {
          _navigateToChat(context);
        } else if (icon == Icons.call) {
          debugPrint("Call feature not implemented");
        }
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, size: 18, color: primaryBtnColor),
      ),
    );
  }
}