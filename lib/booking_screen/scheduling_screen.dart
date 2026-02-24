import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/address_screen/address_screen.dart';
import 'package:nearfix/payment_screen/ghost_payment_screen.dart';

class ScheduleServiceScreen extends StatefulWidget {
  final String serviceName;
  final String providerId; // Receives the ID from Detail Screen

  const ScheduleServiceScreen({
    super.key,
    required this.serviceName,
    required this.providerId,
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

    final String? paymentId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GhostPaymentScreen(amount: 25.0, serviceName: widget.serviceName),
      ),
    );

    if (paymentId != null) {
      _saveBookingToDB(paymentId, pickedAddress);
    }
  }

  Future<void> _saveBookingToDB(String payId, String address) async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    // Getting the userId saved during Login
    final userId = prefs.getInt('user_id');

    // Debugging logs to console - remove these once it works
    print("DEBUG: UserID: $userId, ProviderID: ${widget.providerId}, PayID: $payId");

    const String url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/schedule_service.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
        body: {
          "user_id": userId?.toString() ?? "", // Send empty string if null to trigger PHP error
          "provider_id": widget.providerId,    // Passing the ID from the widget
          "service_name": widget.serviceName,
          "booking_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "notes": _notesController.text.trim(),
          "address": address,
          "payment_id": payId,
          "amount": "25.0",
        },
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        // This will now show you exactly which ID is missing
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
        content: const Text("Booking Confirmed!", textAlign: TextAlign.center),
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
      appBar: AppBar(title: Text("Schedule ${widget.serviceName}")),
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
                decoration: const InputDecoration(hintText: "Additional Notes", border: OutlineInputBorder())
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _startBookingProcess,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56)
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Select Address & Pay", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectionCard({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
        tileColor: Colors.grey.shade100,
        title: Text(title),
        subtitle: Text(value),
        leading: Icon(icon, color: primaryColor),
        onTap: onTap
    );
  }
}