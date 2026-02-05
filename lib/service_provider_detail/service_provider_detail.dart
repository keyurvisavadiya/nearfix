import 'package:flutter/material.dart';

class ServiceProviderDetailScreen extends StatelessWidget {
  const ServiceProviderDetailScreen({super.key});

  // Using the Deep Indigo color from your previous screens
  static const Color primaryColor = Color(0xFF33365D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Scrollable Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 70), // Space for the floating image
                  _buildProfileInfo(),
                  _buildStatsRow(),
                  _buildSectionTitle("About Sarah"),
                  _buildAboutText(),
                  _buildSectionTitle("Reviews"),
                  _buildReviewCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Fixed Bottom Button
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  /// 1. Dark Header with Back Button
  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: primaryColor,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        // Floating Profile Image Card
        Positioned(
          top: 130,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFFE0E7FF),
                  child: const Icon(Icons.person, size: 60, color: Colors.black26),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Name and Title
  Widget _buildProfileInfo() {
    return const Center(
      child: Column(
        children: [
          Text(
            "Sarah Jenkins",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Professional Cleaner & Organizer",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Stats Row (Rating, Reviews, Price)
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("4.9", "RATING"),
          _buildStatItem("250+", "REVIEWS"),
          _buildStatItem("\$25", "PER HOUR"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  /// 4. Common Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  /// 5. About Description
  Widget _buildAboutText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Hi! I'm Sarah, a dedicated home service professional with over 5 years of experience in deep cleaning and home organization. I use eco-friendly products and guarantee 100% satisfaction. Let me make your home sparkle! ✨",
        style: TextStyle(
          color: Colors.black87,
          height: 1.5,
          fontSize: 14,
        ),
      ),
    );
  }

  /// 6. Review Card UI
  Widget _buildReviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5E7EB),
                child: Icon(Icons.person, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Text(
                "James D.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "\"Sarah was amazing! My apartment has never looked this clean. Highly recommended.\"",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 7. Bottom Action Button
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () {},
        child: const Text(
          "Book Sarah Now →",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}