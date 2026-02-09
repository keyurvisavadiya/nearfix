import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressFormScreen extends StatefulWidget {
  const AddAddressFormScreen({super.key});

  @override
  State<AddAddressFormScreen> createState() => _AddAddressFormScreenState();
}

class _AddAddressFormScreenState extends State<AddAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  String selectedType = "Home";
  bool isLoading = false;
  final Color primaryColor = const Color.fromARGB(255, 51, 54, 93);

  @override
  void dispose() {
    _nameController.dispose();
    _houseController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _saveAddressToDb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      _showMsg("Error: User not logged in", Colors.red);
      setState(() => isLoading = false);
      return;
    }

    // 🔥 Update this URL if your ngrok tunnel restarts
    const String url = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/add_address.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "user_id": userId.toString(),
          "full_name": _nameController.text.trim(),
          "house": _houseController.text.trim(),
          "area": _areaController.text.trim(),
          "landmark": _landmarkController.text.trim(),
          "type": selectedType,
        },
      );

      print("Response: ${response.body}");
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (!mounted) return;
        _showMsg("Address saved successfully!", Colors.green);
        Navigator.pop(context, true); // Return 'true' to trigger list refresh
      } else {
        _showMsg(data['message'] ?? "Failed to save", Colors.red);
      }
    } catch (e) {
      print("Error: $e");
      _showMsg("Connection Error. Is Ngrok running?", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Address",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Full Name", true),
                    _field(_nameController, "Enter your name", "Required"),
                    const SizedBox(height: 20),
                    _label("House No. / Building Name", true),
                    _field(_houseController, "e.g. A-102", "Required"),
                    const SizedBox(height: 20),
                    _label("Area / Locality", true),
                    _field(_areaController, "e.g. Satellite", "Required"),
                    const SizedBox(height: 20),
                    _label("Landmark (Optional)", false),
                    _field(_landmarkController, "Near mall", null),
                    const SizedBox(height: 30),
                    _label("Save As", true),
                    const SizedBox(height: 12),
                    _typeSelector(),
                  ],
                ),
              ),
            ),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool required) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
        if (required) const Text(" *", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, String? err) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: c,
        validator: (v) => (err != null && (v == null || v.isEmpty)) ? err : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF6F7F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _typeSelector() {
    final types = [
      {"label": "Home", "icon": Icons.home_rounded},
      {"label": "Work", "icon": Icons.work_rounded},
      {"label": "Other", "icon": Icons.location_on_rounded},
    ];

    return Row(
      children: types.map((t) {
        final selected = selectedType == t["label"];
        return GestureDetector(
          onTap: () => setState(() => selectedType = t["label"] as String),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primaryColor),
            ),
            child: Row(
              children: [
                Icon(t["icon"] as IconData, size: 18, color: selected ? Colors.white : primaryColor),
                const SizedBox(width: 8),
                Text(
                  t["label"] as String,
                  style: TextStyle(color: selected ? Colors.white : primaryColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveAddressToDb,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}