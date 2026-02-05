import 'package:flutter/material.dart';


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
                // ! App Bar
                const Text(
                  "My Bookings",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // !  Tabs
                _tabSwitcher(),
                const SizedBox(height: 16),

                // !  content
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
        ));
  }

  // !  Tab switcher widget
  Widget _tabSwitcher() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _tabItem("Upcoming", isUpcoming, () {
            setState(() => isUpcoming = true);
          }),
          _tabItem("History", !isUpcoming, () {
            setState(() => isUpcoming = false);
          }),
        ],
      ),
    );
  }

  Widget _tabItem(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
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

  // !  Upcoming widget
  List<Widget> _upcomingBookings() {
    return [
      bookingCard(
        icon: Icons.local_shipping,
        title: "House Shifting",
        ref: "Ref: #83293",
        status: "PENDING",
        statusColor: Colors.orange,
        date: "Tomorrow",
        time: "10:30 AM",
        primaryButton: "View Details",
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
  }

  // !  history
  List<Widget> _historyBookings() {
    return [
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
  }

  // ! Booking card widget
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: primaryBtnColor.withOpacity(0.1),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// DATE / TIME / PRICE
          Row(
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
          ),

          const SizedBox(height: 16),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBtnColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(primaryButton),
                ),
              ),
              if (secondaryButton != null) ...[
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
                    child: Text(secondaryButton),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}