import 'package:flutter/material.dart';
import 'package:nearfix/booking_screen/scheduling_screen.dart';

class ServiceProviderDetailScreen extends StatefulWidget {
  // Pass the Map containing all the database columns
  final Map<String, dynamic> provider;

  const ServiceProviderDetailScreen({super.key, required this.provider});

  static const Color primaryColor = Color(0xFF33365D);

  @override
  State<ServiceProviderDetailScreen> createState() => _ServiceProviderDetailScreenState();
}

class _ServiceProviderDetailScreenState extends State<ServiceProviderDetailScreen> {
  // Update this to your current active ngrok link
  final String _baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/";

  @override
  Widget build(BuildContext context) {
    // 1. Extract IDs and Data safely
    // We need the ID to ensure the booking is linked to this specific professional
    final String providerId = widget.provider['id']?.toString() ?? "0";

    // Support both 'full_name' (from register) and 'name' (from get_providers)
    final String name = widget.provider['full_name'] ?? widget.provider['name'] ?? "Provider";
    final String title = widget.provider['job_title'] ?? widget.provider['title'] ?? "Professional";
    final String aboutMe = widget.provider['about_me'] ?? "No biography provided by this professional.";
    final String experience = widget.provider['experience_years']?.toString() ??
        widget.provider['experience']?.toString() ?? "0";
    final String photoPath = widget.provider['profile_photo_path'] ?? widget.provider['photo'] ?? "";

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
                  _buildHeader(context, photoPath),
                  const SizedBox(height: 70), // Space for the floating profile image
                  _buildProfileInfo(name, title),
                  _buildStatsRow(experience),
                  _buildSectionTitle("About $name"),
                  _buildAboutText(aboutMe),
                  _buildSectionTitle("Reviews"),
                  _buildReviewCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Fixed Bottom Button - Passing providerId and job title
          _buildBottomNavigationBar(name, title, providerId),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String photoPath) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          color: ServiceProviderDetailScreen.primaryColor,
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
        Positioned(
          top: 130,
          child: Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: photoPath.isNotEmpty
                    ? Image.network(
                  "$_baseUrl$photoPath",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                )
                    : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String name, String title) {
    return Center(
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ServiceProviderDetailScreen.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String exp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("4.9", "RATING"),
          _buildStatItem("$exp Years", "EXPERIENCE"),
          _buildStatItem("Verified", "STATUS"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.1, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ServiceProviderDetailScreen.primaryColor),
      ),
    );
  }

  Widget _buildAboutText(String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        bio,
        style: const TextStyle(color: Colors.black87, height: 1.6, fontSize: 14),
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
              const Text("User Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Row(
                children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "\"Excellent work! Prompt and very professional. Highly recommend for anyone looking for quality service.\"",
            style: TextStyle(fontSize: 13, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// UPDATED: Bottom Action Button with providerId
  Widget _buildBottomNavigationBar(String name, String job, String providerId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ServiceProviderDetailScreen.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: () {
          // Navigating to scheduling screen with both the service and the specific provider's ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleServiceScreen(
                serviceName: job,
                providerId: providerId,
              ),
            ),
          );
        },
        child: Text(
          "Book $name Now →",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}