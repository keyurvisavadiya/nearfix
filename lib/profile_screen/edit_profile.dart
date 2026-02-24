import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  File? _imageFile;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  final String baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}get_user_details.php?user_id=${widget.userId}"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        setState(() {
          nameCtrl.text = data['name'] ?? "";
          emailCtrl.text = data['email'] ?? "";
          phoneCtrl.text = data['phone'] ?? "";
          // CHANGED: looking for 'profile_image'
          _networkImageUrl = data['profile_image'];
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _saveChanges() async {
    setState(() => isLoading = true);
    final String updateUrl = "${baseUrl}update_profile.php";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(updateUrl));
      request.headers.addAll({"ngrok-skip-browser-warning": "true"});

      request.fields['user_id'] = widget.userId.toString();
      request.fields['name'] = nameCtrl.text.trim();
      request.fields['email'] = emailCtrl.text.trim();
      request.fields['phone'] = phoneCtrl.text.trim();

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      var res = await http.Response.fromStream(await request.send());
      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', nameCtrl.text.trim());

        // Store the image path in SharedPreferences for the main Profile Screen
        if (data['profile_image'] != null) {
          await prefs.setString('profile_pic', data['profile_image']);
        }

        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Update error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_networkImageUrl != null && _networkImageUrl!.isNotEmpty)
                    ? NetworkImage("$baseUrl$_networkImageUrl")
                    :  const NetworkImage("") as ImageProvider,
              ),
            ),
            const SizedBox(height: 30),
            _buildInput("FULL NAME", nameCtrl),
            _buildInput("EMAIL", emailCtrl),
            _buildInput("PHONE NUMBER", phoneCtrl),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }
}