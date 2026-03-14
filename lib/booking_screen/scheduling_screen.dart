import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/address_screen/address_screen.dart';
import 'package:nearfix/payment_screen/ghost_payment_screen.dart';

class ScheduleServiceScreen extends StatefulWidget {
  final String serviceName;
  final String providerId;
  final String visitingCharge;
  final double latitude;
  final double longitude;

  const ScheduleServiceScreen({
    super.key,
    required this.serviceName,
    required this.providerId,
    required this.visitingCharge,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final Color primaryColor = const Color.fromARGB(255, 51, 54, 93);
  DateTime? selectedDate;
  final TextEditingController _notesController = TextEditingController();
  bool isLoading = false;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _startBookingProcess() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a date")));
      return;
    }

    final String? pickedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressScreen()),
    );

    if (pickedAddress == null) return;

    double amountToPay = double.tryParse(widget.visitingCharge) ?? 0.0;

    // --- FIX 1: PASS ALL REQUIRED ARGUMENTS ---
    // GhostPaymentScreen returns a Map<String, dynamic>, not a String!
    final Map<String, dynamic>? paymentResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GhostPaymentScreen(
          amount: amountToPay,
          serviceName: widget.serviceName,
          providerId: widget.providerId,
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
      ),
    );

    // --- FIX 2: EXTRACT DATA FROM THE RETURNED MAP ---
    if (paymentResult != null && paymentResult.containsKey("payment_id")) {
      String payId = paymentResult["payment_id"];
      _saveBookingToDB(payId, pickedAddress, amountToPay.toString());
    }
  }

  Future<void> _saveBookingToDB(String payId, String address, String finalAmount) async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    const String url = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/schedule_service.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
        body: {
          "user_id": userId?.toString() ?? "",
          "provider_id": widget.providerId,
          "service_name": widget.serviceName,
          "booking_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "notes": _notesController.text.trim(),
          "address": address,
          "payment_id": payId,
          "amount": finalAmount,
          // Sending coordinates to DB as well for the provider to see on a map
          "latitude": widget.latitude.toString(),
          "longitude": widget.longitude.toString(),
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving booking")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Booking Requested!", textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("OK")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Schedule ${widget.serviceName}"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: Text("₹${widget.visitingCharge}", style: const TextStyle(fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _selectionCard(
              title: "Date",
              value: selectedDate == null ? "Select Date" : DateFormat('EEE, MMM d, yyyy').format(selectedDate!),
              icon: Icons.calendar_month_rounded,
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Additional Notes (e.g., gate code, specific problem)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF9FAFB),
                )
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _startBookingProcess,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Pay ₹${widget.visitingCharge} & Book", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectionCard({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: primaryColor),
        ),
        onTap: onTap
    );
  }
}