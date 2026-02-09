import 'package:flutter/material.dart';
import 'package:nearfix/booking_screen/bookings_screen.dart';
import 'package:nearfix/profile_screen/profile_screen.dart';
// Ensure these imports match your actual file paths
import '../address_screen/address_screen.dart';
import '../all_service_providers/all_service_providers.dart';
import '../chat_screen/chat_screen_tile.dart';
import '../service_providers/service_providers.dart';

const Color primaryBtnColor = Color.fromARGB(255, 51, 54, 93);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> services = [
    {"icon": Icons.cleaning_services, "title": "Cleaning"},
    {"icon": Icons.electrical_services, "title": "Electric"},
    {"icon": Icons.plumbing, "title": "Plumbing"},
    {"icon": Icons.handyman, "title": "Repair"},
    {"icon": Icons.ac_unit, "title": "AC"},
    {"icon": Icons.format_paint, "title": "Painting"},
    {"icon": Icons.local_laundry_service, "title": "Laundry"},
    {"icon": Icons.more_horiz, "title": "More"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      // AppBar only shows on the Home Tab
      appBar: currentIndex == 0 ? _buildHomeAppBar() : null,
      body: _buildBodyContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// 1. Navigation Logic for Tabs
  Widget _buildBodyContent() {
    switch (currentIndex) {
      case 0: return _buildHomeBody();
      case 1: return const BookingsScreen();
      case 2: return const ChatScreen();
      case 3: return const ProfileScreen();
      default: return _buildHomeBody();
    }
  }

  /// 2. AppBar with Clickable Address Section
  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      toolbarHeight: 72,
      titleSpacing: 16,
      title: InkWell(
        onTap: () {
          // TODO: Navigate to Address Page
           Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_on, color: Colors.black, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Home",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Keyur Apartment, Ahmedabad",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  /// 3. Main Home Body
  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          _buildSectionHeader("Services"),
          _buildServicesGrid(),
          _buildSectionHeader("Upcoming Booking"),
          _buildUpcomingCard(),
          _buildSectionHeader("Recommended for you"),
          _buildRecommendedList(),
        ],
      ),
    );
  }

  /// 4. Search Bar UI
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchBar(
        hintText: "Search services",
        leading: const Icon(Icons.search),
        elevation: const WidgetStatePropertyAll(1),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  /// 5. Services Grid UI
  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (service["title"] == "More") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllServicesScreen()));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ServiceProvidersScreen(serviceName: service["title"])),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service["icon"], color: Colors.black87, size: 26),
                  const SizedBox(height: 6),
                  Text(service["title"], style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 6. Upcoming Card UI
  Widget _buildUpcomingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.cleaning_services, color: Colors.blue),
                const SizedBox(width: 10),
                const Expanded(child: Text("Deep Home Cleaning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                _statusBadge("Confirmed", Colors.green),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, color: Colors.black54)),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Keyur Visavadiya", style: TextStyle(fontWeight: FontWeight.w600)),
                    Text("Service Provider", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                _iconAction(Icons.call, Colors.green),
                const SizedBox(width: 8),
                _iconAction(Icons.message, Colors.blue),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 7. Recommended List (NOW CLICKABLE)
  Widget _buildRecommendedList() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceProvidersScreen(serviceName: "Recommended")),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: const Center(child: Icon(Icons.image, color: Colors.white54, size: 30)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Service Name", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Top rated provider", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 8. Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBtnColor,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// Helper Widgets
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _iconAction(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: () {}),
    );
  }
}