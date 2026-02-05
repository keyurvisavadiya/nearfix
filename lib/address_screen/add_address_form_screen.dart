import 'package:flutter/material.dart';

class AddAddressFormScreen extends StatefulWidget {
  const AddAddressFormScreen({super.key});

  @override
  State<AddAddressFormScreen> createState() => _AddAddressFormScreenState();
}

class _AddAddressFormScreenState extends State<AddAddressFormScreen> {
  // 1. Create a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  String selectedType = "Home";
  final Color primaryColor = const Color.fromARGB(255, 51, 54, 93);

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      // 2. Wrap the body in a Form widget
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
                    _buildInputLabel("Full Name", isRequired: true),
                    _buildTextFormField("Enter your name", "Full name is required"),

                    const SizedBox(height: 20),
                    _buildInputLabel("House No. / Building Name", isRequired: true),
                    _buildTextFormField("e.g. A-102, Keyur Apartment", "House details are required"),

                    const SizedBox(height: 20),
                    _buildInputLabel("Area / Locality", isRequired: true),
                    _buildTextFormField("e.g. Satellite, Ahmedabad", "Area is required"),

                    const SizedBox(height: 20),
                    _buildInputLabel("Landmark (Optional)", isRequired: false),
                    // No validation message passed here
                    _buildTextFormField("e.g. Near Iscon Mall", null),

                    const SizedBox(height: 30),
                    _buildInputLabel("Save As", isRequired: true),
                    const SizedBox(height: 12),
                    _buildAddressTypeSelector(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {required bool isRequired}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        if (isRequired)
          const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 3. Updated to use TextFormField with Validator
  Widget _buildTextFormField(String hint, String? errorMsg) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextFormField(
        validator: (value) {
          if (errorMsg != null && (value == null || value.isEmpty)) {
            return errorMsg;
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF6F7F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    List<Map<String, dynamic>> types = [
      {"label": "Home", "icon": Icons.home_rounded},
      {"label": "Work", "icon": Icons.work_rounded},
      {"label": "Other", "icon": Icons.location_on_rounded},
    ];

    return Row(
      children: types.map((type) {
        bool isSelected = selectedType == type["label"];
        return GestureDetector(
          onTap: () => setState(() => selectedType = type["label"]),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(type["icon"], size: 18, color: isSelected ? Colors.white : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  type["label"],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: ElevatedButton(
        onPressed: () {
          // 4. Trigger validation check
          if (_formKey.currentState!.validate()) {
            // If all required fields are filled:
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Address saved successfully!")),
            );
          } else {
            // If validation fails, it automatically shows the red text below fields
            debugPrint("Form is incomplete");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text("Save Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}