import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix/booking_screen/booking_screen_details.dart';
import 'package:nearfix/booking_screen/bookings_screen.dart';
import 'package:nearfix/profile_screen/profile_screen.dart';
import 'package:nearfix/service_provider_detail/service_provider_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../address_screen/address_screen.dart';
import '../all_service_providers/all_service_providers.dart';
import '../chat_screen/chat_screen_tile.dart';
import '../notifications/notifications.dart';
import '../service_providers/service_providers.dart';

const Color primaryBtnColor = Color(0xFF33365D);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<dynamic> _dbProviders = [];
  Map<String, dynamic>? _upcomingBooking;
  bool _isLoading = true;

  // Ensure this URL is updated to your current active Ngrok link
  final String _baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/";

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
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1;

      // 1. Fetch Recommended Providers
      final providersRes = await http.get(
        Uri.parse("${_baseUrl}get_providers.php"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      // 2. Fetch the Dynamic Upcoming Booking
      final bookingRes = await http.get(
        Uri.parse("${_baseUrl}get_upcoming_booking.php?user_id=$userId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (!mounted) return;

      if (providersRes.statusCode == 200 && bookingRes.statusCode == 200) {
        final providersData = json.decode(providersRes.body);
        final bookingData = json.decode(bookingRes.body);

        setState(() {
          _dbProviders = providersData['data'] ?? [];
          _upcomingBooking = (bookingData['status'] == 'success') ? bookingData['data'] : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: currentIndex == 0 ? _buildHomeAppBar() : null,
      body: _buildBodyContent(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBodyContent() {
    switch (currentIndex) {
      case 0: return _buildHomeBody();
      case 1: return const BookingsScreen();
      case 2: return const ChatScreen();
      case 3: return const ProfileScreen();
      default: return _buildHomeBody();
    }
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
      title: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.black, size: 18),
                SizedBox(width: 4),
                Text("Home", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
              ],
            ),
            Text("Keyur Apartment, Ahmedabad", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
        ),
      ],
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => showSearch(context: context, delegate: ServiceSearchDelegate(services)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF33365D), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Search for 'Plumbing' or 'AC'...",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15, letterSpacing: 0.3),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF33365D).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune, color: Color(0xFF33365D), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return InkWell(
            onTap: () {
              if (service["title"] == "More") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllServicesScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceProvidersScreen(serviceName: service["title"])));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
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

  Widget _buildUpcomingCard() {
    if (_upcomingBooking == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            children: [
              Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 30),
              SizedBox(height: 10),
              Text("No upcoming bookings found", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final booking = _upcomingBooking!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        // FIXED: Now passing the actual ID from the map instead of 'bId'
        onTap: () {
          final String actualID = booking['id'].toString();
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookingDetailsUI(bookingId: actualID))
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.cleaning_services, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(booking['service_name'] ?? "Service", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  _statusBadge(booking['status'] ?? "Confirmed", Colors.green),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: NetworkImage("$_baseUrl${booking['provider_photo'] ?? ''}"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['provider_name'] ?? "Provider", style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(booking['booking_date'] ?? "Scheduled", style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
      ),
    );
  }

  Widget _buildRecommendedList() {
    if (_isLoading) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));

    return SizedBox(
      height: 170,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _dbProviders.length,
        itemBuilder: (context, index) {
          final item = _dbProviders[index];
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceProviderDetailScreen(provider: item)));
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      "$_baseUrl${item['photo'] ?? ''}",
                      height: 90, width: 150, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(height: 90, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(item['name'] ?? 'Provider', style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(item['title'] ?? 'Professional', style: const TextStyle(fontSize: 11, color: Colors.grey))
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
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

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.fromLTRB(20, 30, 20, 12), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  Widget _statusBadge(String label, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));
  Widget _iconAction(IconData icon, Color color) => Container(decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: () {}));
}

// Service Search Delegate
class ServiceSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> services;

  ServiceSearchDelegate(this.services);

  @override
  String get searchFieldLabel => 'Search services...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchBody(context);

  Widget _buildSearchBody(BuildContext context) {
    // Filters the list based on query and hides the "More" button from results
    final results = services
        .where((s) =>
    s["title"].toLowerCase().contains(query.toLowerCase()) &&
        s["title"] != "More")
        .toList();

    if (query.isEmpty) {
      return Container(
        color: const Color(0xFFF6F7F9),
        child: const Center(
          child: Text("Start typing to find services...",
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF6F7F9),
      child: results.isEmpty
          ? const Center(child: Text(
          "No services found", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = results[index];
          return _buildSearchListTile(context, service);
        },
      ),
    );
  }

  Widget _buildSearchListTile(BuildContext context,
      Map<String, dynamic> service) {
    return InkWell(
      onTap: () {
        close(context, null);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ServiceProvidersScreen(serviceName: service["title"]),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Modern Compact Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF33365D).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  service["icon"], color: const Color(0xFF33365D), size: 22),
            ),
            const SizedBox(width: 16),
            // Text Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Available in your area",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(
                Icons.arrow_forward_ios, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}