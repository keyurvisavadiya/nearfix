import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/address_screen/address_screen.dart';
import 'package:nearfix/profile_screen/edit_profile.dart';
import 'package:nearfix/profile_screen/help_support_screen.dart';

import '../authentication/sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables to hold current user data
  bool _isLoggedIn = false;
  String _userName = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load data from database-saved session
  }

  /// Fetch the user name and login status from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      // 'userName' must match the key you used in your LoginScreen save logic
      _userName = prefs.getString('userName') ?? "Guest User";
    });
  }

  ///  Clear the session and redirect to Login
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('user_id');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(), // Now uses the dynamic _userName
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _sectionTitle("Account Settings"),
                _profileTile(
                  icon: Icons.person_rounded,
                  title: "Edit Profile",
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                ),
                _profileTile(
                  icon: Icons.location_on_rounded,
                  title: "Saved Addresses",
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
                ),

                const SizedBox(height: 16),
                _sectionTitle("Support"),
                _profileTile(
                  icon: Icons.help_center_rounded,
                  title: "Help & Support",
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),

                const SizedBox(height: 16),

                // Show Logout if logged in, otherwise show Login
                _isLoggedIn
                    ? _profileTile(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  color: Colors.red,
                  isLogout: true,
                  onTap: _showLogoutDialog,
                )
                    : _profileTile(
                  icon: Icons.login_rounded,
                  title: "Login / Sign Up",
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
                        .then((_) => _loadUserData()); // Refresh when returning
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(height: 16),
          //  DYNAMIC NAME FROM DATABASE
          Text(
              _userName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
              _isLoggedIn ? "Gold Member" : "Guest",
              style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.2),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
            title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : const Color(0xFF1E293B)
            )
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}