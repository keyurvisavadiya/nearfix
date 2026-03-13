import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/home_screen/home_screen.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  // ================= SIGNUP FUNCTION =================
  Future<void> signUpUser() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 2. Your Live Ngrok URL
    const String url = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/signup.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true", // Required for Ngrok Free Tier
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      // 3. Debug Response
      print("Signup Response: ${response.body}");
      final data = json.decode(response.body);

      if (data["success"] == true) {
        // 4. Save User Session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);

        // Safely parse user_id to integer
        int userId = int.parse(data["user_id"].toString());
        await prefs.setInt("user_id", userId);
        await prefs.setString("userName", _nameController.text.trim());

        if (!mounted) return;

        // 5. Navigate to Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created!"), backgroundColor: Colors.green),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        _showError(data["message"] ?? "Registration failed");
      }
    } catch (e) {
      print("Flutter Error: $e");
      _showError("Connection error. Check if Ngrok is running.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // ================= UI BUILDER =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text("Join NearFix for premium home services.", style: TextStyle(color: Colors.black54)),

                const SizedBox(height: 32),

                _buildInput("FULL NAME", "test case", Icons.person_outline, _nameController,
                    validator: (v) => (v == null || v.isEmpty) ? "Name is required" : null),

                _buildInput("EMAIL ADDRESS", "test123@example.com", Icons.email_outlined, _emailController,
                    validator: (v) => (v != null && v.contains('@')) ? null : "Enter a valid email"),

                _buildInput("PHONE NUMBER", "1234567890", Icons.phone_android_outlined, _phoneController,
                    validator: (v) => (v != null && v.length >= 10) ? null : "Enter a valid phone number"),

                _buildInput("PASSWORD", "••••••••", Icons.lock_outline, _passwordController, isPassword: true,
                    validator: (v) => (v != null && v.length >= 6) ? null : "Min 6 characters required"),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signUpUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBtnColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, IconData icon, TextEditingController controller, {bool isPassword = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ],
      ),
    );
  }
}