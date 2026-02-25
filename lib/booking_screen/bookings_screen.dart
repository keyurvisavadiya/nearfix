import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/booking_screen/booking_screen_details.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool isUpcoming = true;
  bool isLoading = true;
  List<dynamic> allBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // --- DATABASE FETCHING ---
  Future<void> _fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 9;

      final url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_all_bookings.php?user_id=$userId";

      final response = await http.get(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        setState(() {
          allBookings = decoded['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get _filteredBookings {
    if (isUpcoming) {
      return allBookings.where((b) =>
      b['status'] == 'Confirmed' || b['status'] == 'pending').toList();
    } else {
      return allBookings.where((b) =>
      b['status'] == 'COMPLETED' || b['status'] == 'Cancelled').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("My Bookings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _tabSwitcher(),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryBtnColor))
                    : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: _filteredBookings.isEmpty
                      ? const Center(child: Text("No bookings found"))
                      : ListView.separated(
                    itemCount: _filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = _filteredBookings[index];
                      return bookingCard(
                        icon: _getIcon(b['service_name']),
                        title: b['service_name'] ?? "Service",
                        ref: "Ref: #${b['id']}",
                        status: b['status'].toString().toUpperCase(),
                        statusColor: _getStatusColor(b['status']),
                        date: b['booking_date'] ?? "",
                        price: "₹${b['amount']}",
                        primaryButton: isUpcoming ? "View Details" : "Rebook",
                        onPrimaryTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailsUI(bookingId: b['id'].toString()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI HELPERS (The missing methods) ----------------

  Widget _tabSwitcher() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          _tab("Upcoming", isUpcoming, () => setState(() => isUpcoming = true)),
          _tab("History", !isUpcoming, () => setState(() => isUpcoming = false)),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? primaryBtnColor : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // --- THIS IS THE METHOD THAT WAS MISSING ---
  Widget bookingCard({
    required IconData icon,
    required String title,
    required String ref,
    required String status,
    required Color statusColor,
    required String date,
    String? price,
    required String primaryButton,
    VoidCallback? onPrimaryTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: primaryBtnColor.withOpacity(0.1), child: Icon(icon, color: primaryBtnColor)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(ref, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              _statusChip(status, statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              Text(price ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBtnColor)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBtnColor),
              onPressed: onPrimaryTap,
              child: Text(primaryButton, style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getIcon(String? service) {
    if (service == null) return Icons.build;
    if (service.toLowerCase().contains("clean")) return Icons.cleaning_services;
    if (service.toLowerCase().contains("plumb")) return Icons.plumbing;
    return Icons.settings;
  }
}