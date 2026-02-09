import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/authentication/sign_up.dart';
import 'package:nearfix/home_screen/home_screen.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool isLoading = false;

  // ================= LOGIN FUNCTION =================
// ... inside your _LoginScreenState class ...

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    const String url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/login.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": emailCtrl.text.trim(),
          "password": passwordCtrl.text.trim(),
        },
      );

      print("Response Body: ${response.body}");
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // 1. Save data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Ensure user_id is saved correctly (PHP sends it as int or string)
        await prefs.setInt('user_id', int.parse(data['user_id'].toString()));
        await prefs.setString('userName', data['name'] ?? "User");

        if (!mounted) return;

        // 2. SHOW SUCCESS MESSAGE
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green),
        );

        // 3. NAVIGATE TO HOME SCREEN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false, // This removes the login screen from the back-stack
        );
      } else {
        // Show the error message from PHP (e.g., "Incorrect password")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login failed"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Flutter Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error. Check ngrok."), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🔥 NEW: NAVIGATION ROW (BACK & SKIP)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // LOGO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.home_filled,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to access your personalized home services.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 40),

                // EMAIL
                _buildInputField(
                  label: "EMAIL ADDRESS",
                  hint: "alex@example.com",
                  icon: Icons.email_outlined,
                  controller: emailCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return "Invalid email";
                    return null;
                  },
                ),

                // PASSWORD
                _buildInputField(
                  label: "PASSWORD",
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  controller: passwordCtrl,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password required";
                    if (v.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        loginUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBtnColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELD HELPER =================
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.black26, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}