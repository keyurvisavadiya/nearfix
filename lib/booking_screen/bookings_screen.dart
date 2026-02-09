import 'package:flutter/material.dart';
import 'package:nearfix/booking_screen/booking_screen_details.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool isUpcoming = true;

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
              const Text(
                "My Bookings",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _tabSwitcher(),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: isUpcoming
                      ? _upcomingBookings()
                      : _historyBookings(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TAB SWITCHER ----------------
  Widget _tabSwitcher() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _tab("Upcoming", isUpcoming, () => setState(() => isUpcoming = true)),
          _tab(
            "History",
            !isUpcoming,
            () => setState(() => isUpcoming = false),
          ),
        ],
      ),
    );
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? primaryBtnColor : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UPCOMING ----------------
  List<Widget> _upcomingBookings() => [
    bookingCard(
      icon: Icons.local_shipping,
      title: "House Shifting",
      ref: "Ref: #83293",
      status: "PENDING",
      statusColor: Colors.orange,
      date: "Tomorrow",
      time: "10:30 AM",
      primaryButton: "View Details",
      onPrimaryTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingDetailsUI()),
        );
      },
    ),
    const SizedBox(height: 12),
    bookingCard(
      icon: Icons.cleaning_services,
      title: "Deep Cleaning",
      ref: "Ref: #77710",
      status: "CONFIRMED",
      statusColor: Colors.green,
      date: "Today",
      time: "2:00 PM",
      primaryButton: "Track Pro",
      secondaryButton: "Cancel",
    ),
    const SizedBox(height: 12),
    bookingCard(
      icon: Icons.cleaning_services,
      title: "Deep Cleaning",
      ref: "Ref: #77710",
      status: "CONFIRMED",
      statusColor: Colors.green,
      date: "Today",
      time: "2:00 PM",
      primaryButton: "Track Pro",
      secondaryButton: "Cancel",
    ),
  ];

  // ---------------- HISTORY ----------------
  List<Widget> _historyBookings() => [
    bookingCard(
      icon: Icons.ac_unit,
      title: "AC Repair",
      ref: "Ref: #55432",
      status: "COMPLETED",
      statusColor: Colors.grey,
      date: "Jan 15, 2026",
      price: "₹450.00",
      primaryButton: "Rate",
      secondaryButton: "Rebook",
    ),
    const SizedBox(height: 12),
    bookingCard(
      icon: Icons.plumbing,
      title: "Plumbing",
      ref: "Ref: #44110",
      status: "CANCELLED",
      statusColor: Colors.red,
      date: "Dec 20, 2025",
      primaryButton: "Book Again",
    ),
  ];

  // ---------------- BOOKING CARD ----------------
  Widget bookingCard({
    required IconData icon,
    required String title,
    required String ref,
    required String status,
    required Color statusColor,
    required String date,
    String? time,
    String? price,
    required String primaryButton,
    String? secondaryButton,
    VoidCallback? onPrimaryTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(icon, title, ref, status, statusColor),
          const SizedBox(height: 14),
          _cardDateRow(date, time, price),
          const SizedBox(height: 16),
          _cardButtons(primaryButton, secondaryButton, onPrimaryTap),
        ],
      ),
    );
  }

  // ---------------- SMALL HELPERS ----------------
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
    ],
  );

  Widget _cardHeader(
    IconData icon,
    String title,
    String ref,
    String status,
    Color statusColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: primaryBtnColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryBtnColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ref,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        _statusChip(status, statusColor),
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _cardDateRow(String date, String? time, String? price) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(price ?? date, style: const TextStyle(color: Colors.grey)),
        if (time != null) ...[
          const SizedBox(width: 12),
          const Icon(Icons.access_time, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _cardButtons(
    String primary,
    String? secondary,
    VoidCallback? onPrimaryTap,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBtnColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onPrimaryTap ?? () {},

            child: Text(primary, style: TextStyle(color: Colors.white)),
          ),
        ),
        if (secondary != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBtnColor,
                side: const BorderSide(color: primaryBtnColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text(secondary),
            ),
          ),
        ],
      ],
    );
  }
}
