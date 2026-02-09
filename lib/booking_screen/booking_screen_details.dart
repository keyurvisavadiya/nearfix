import 'package:flutter/material.dart';
import 'package:nearfix/chat_screen/chatscreen.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);
const Color pageBg = Color(0xFFF6F7FB);

class BookingDetailsUI extends StatelessWidget {
  const BookingDetailsUI({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05, // responsive side padding
          vertical: 16,
        ),
        child: Column(
          children: [
            _statusCard(),
            const SizedBox(height: 20),
            _serviceCard(),
            const SizedBox(height: 20),
            _professionalCard(),
            const SizedBox(height: 20),
            _paymentCard(),
            const SizedBox(height: 20),
            _locationCard(),
            const SizedBox(height: 28),
            _cancelButton(),
          ],
        ),
      ),
    );
  }

  // ================= STATUS =================
  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFDFF6EA),
            child: Icon(Icons.check, color: Colors.green),
          ),
          SizedBox(height: 12),
          Text(
            "Booking Confirmed",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("Reference ID: #88293", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= SERVICE =================
  Widget _serviceCard() {
    return _section(
      "SERVICE",
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: primaryBtnColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.cleaning_services, color: primaryBtnColor),
        ),
        title: const Text(
          "Deep Home Cleaning",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Today, 2:00 PM - 5:00 PM"),
      ),
    );
  }

  // ================= PROFESSIONAL =================
  Widget _professionalCard() {
    return _section(
      "PROFESSIONAL",
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage("assets/avatar.png"), // optional
          child: Icon(Icons.person),
        ),
        title: const Text(
          "Sarah Jenkins",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: const [
            Icon(Icons.star, size: 16, color: Colors.orange),
            SizedBox(width: 4),
            Text("4.9 (124 Reviews)"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _CircleIcon(Icons.chat),
            SizedBox(width: 10),
            _CircleIcon(Icons.call),
          ],
        ),
      ),
    );
  }

  // ================= PAYMENT =================
  Widget _paymentCard() {
    return _section(
      "PAYMENT DETAILS",
      Column(
        children: const [
          _PaymentRow("Payment Method", "VISA **** 4242"),
          _PaymentRow("Status", "Paid", isPaid: true),
          Divider(height: 24),
          _PaymentRow("Subtotal", "\$120.00"),
          _PaymentRow("Tax (5%)", "\$6.00"),
          SizedBox(height: 8),
          _PaymentRow("Total", "\$126.00", isTotal: true),
        ],
      ),
    );
  }

  // ================= LOCATION =================
  Widget _locationCard() {
    return _section(
      "LOCATION",
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.location_on, color: Colors.deepPurple),
        title: const Text("Home"),
        subtitle: const Text(
          "123 Beverly Hill Dr, Apt 4B\nLos Angeles, CA 90210",
        ),
      ),
    );
  }

  // ================= CANCEL =================
  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {},
        child: const Text("Cancel Booking", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // ================= SECTION =================
  Widget _section(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// ================= PAYMENT ROW =================
class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPaid;
  final bool isTotal;

  const _PaymentRow(
    this.label,
    this.value, {
    this.isPaid = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isPaid
                  ? Colors.green
                  : isTotal
                  ? Colors.deepPurple
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= CIRCLE ICON =================
class _CircleIcon extends StatelessWidget {
  final IconData icon;

  const _CircleIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProviderChatMessageScreen()),
        );
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, size: 18, color: primaryBtnColor),
      ),
    );
  }
}
