import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class GhostPaymentScreen extends StatefulWidget {
  final double amount;
  final String serviceName;

  const GhostPaymentScreen({
    super.key,
    required this.amount,
    required this.serviceName,
  });

  @override
  State<GhostPaymentScreen> createState() => _GhostPaymentScreenState();
}

class _GhostPaymentScreenState extends State<GhostPaymentScreen> {
  late Razorpay _razorpay;
  static const Color primaryColor = Color(0xFF33365D);

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Bind listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Auto-launch Razorpay immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchRazorpay());
  }

  void _launchRazorpay() {
    var options = {
      'key': 'rzp_test_SGMtKOLbD6h9TD', // Your Test Key
      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'NearFix',
      'description': widget.serviceName,
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@example.com'
      },
      // Time/timeout section removed to keep it standard ✅
      'retry': {'enabled': false},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
      _handleError(PaymentFailureResponse(0, "Gateway Error", {}));
    }
  }

  // --- SUCCESS HANDLER ---
  void _handleSuccess(PaymentSuccessResponse response) {
    if (mounted) {
      // 🔥 IMPORTANT: Pass the payment ID back to the previous screen
      // This allows the Scheduling screen to save it to your MySQL DB
      Navigator.pop(context, response.paymentId);
    }
  }

  // --- ERROR/CANCEL HANDLER ---
  void _handleError(PaymentFailureResponse response) {
    if (mounted) {
      // Return 'null' so the Scheduling screen knows not to save the booking
      Navigator.pop(context, null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Cancelled or Failed"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
             SizedBox(height: 24),
            Text(
              "Connecting to Secure Gateway...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}