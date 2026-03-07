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

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 9;
      final url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_all_bookings.php?user_id=$userId";
      final response = await http.get(Uri.parse(url), headers: {"ngrok-skip-browser-warning": "true"});
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        setState(() {
          allBookings = decoded['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<dynamic> get _filteredBookings {
    return allBookings.where((b) {
      final String s = (b['status'] ?? '').toString().toLowerCase().trim();
      if (isUpcoming) {
        return s == 'pending' || s == 'confirmed' || s == '';
      } else {
        return s == 'completed' || s == 'cancelled';
      }
    }).toList()..sort((a, b) => (int.tryParse(b['id'].toString()) ?? 0).compareTo(int.tryParse(a['id'].toString()) ?? 0));
  }

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'pending':
      default: return Colors.amber;
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
                      ? ListView(children: const [SizedBox(height: 200), Center(child: Text("No bookings found"))])
                      : ListView.separated(
                    itemCount: _filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = _filteredBookings[index];
                      final String status = (b['status'] ?? 'Pending').toString();

                      return bookingCard(
                        title: b['service_name'] ?? 'Service',
                        ref: "Ref: #${b['id']}",
                        status: status.toUpperCase(),
                        statusColor: _getStatusColor(status),
                        date: b['booking_date'] ?? 'TBD',
                        price: "₹${b['amount']}",

                        // Main Button: "View Details" (Upcoming) or "Rate/Rebook" (History)
                        primaryButton: isUpcoming
                            ? "View Details"
                            : (status.toLowerCase() == 'completed' ? "Rate Service" : "Rebook"),

                        onPrimaryTap: () {
                          if (isUpcoming || status.toLowerCase() != 'completed') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsUI(bookingId: b['id'].toString())));
                          } else {
                            // Logic for Rating
                            debugPrint("Rating service for booking: ${b['id']}");
                          }
                        },

                        // --- THE REBOOK BUTTON (Optional) ---
                        secondaryButton: (!isUpcoming && status.toLowerCase() == 'completed')
                            ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryBtnColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            debugPrint("Rebooking ${b['service_name']}");
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsUI(bookingId: b['id'].toString())));
                          },
                          child: const Text("View Details", style: TextStyle(color: primaryBtnColor, fontWeight: FontWeight.bold)),
                        )
                            : null,
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

  Widget _tabSwitcher() {
    return Container(
      height: 44, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        _tab("Upcoming", isUpcoming, () => setState(() => isUpcoming = true)),
        _tab("History", !isUpcoming, () => setState(() => isUpcoming = false)),
      ]),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: active ? primaryBtnColor : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))));
  }

  Widget bookingCard({
    required String title,
    required String ref,
    required String status,
    required Color statusColor,
    required String date,
    required String price,
    required String primaryButton,
    VoidCallback? onPrimaryTap,
    Widget? secondaryButton, // Added parameter
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Row(children: [
          CircleAvatar(backgroundColor: primaryBtnColor.withOpacity(0.1), child: const Icon(Icons.build, color: primaryBtnColor)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(ref, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
        ]),
        const Divider(height: 24),
        Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(date, style: const TextStyle(color: Colors.grey)), const Spacer(), Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBtnColor))]),
        const SizedBox(height: 16),

        // --- UPDATED BUTTON ROW ---
        Row(
          children: [
            if (secondaryButton != null) ...[
              Expanded(child: SizedBox(height: 40, child: secondaryButton)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBtnColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: onPrimaryTap,
                      child: Text(primaryButton, style: const TextStyle(color: Colors.white))
                  )
              ),
            ),
          ],
        ),
      ]),
    );
  }
}