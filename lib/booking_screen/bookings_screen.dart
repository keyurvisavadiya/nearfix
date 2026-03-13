import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix/booking_screen/booking_screen_details.dart';

const Color _primary = Color(0xFF33365D);
const Color _accent = Color(0xFF6366F1);
const Color _bg = Color(0xFFF6F7FB);

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  bool isUpcoming = true;
  bool isLoading = true;
  List<dynamic> allBookings = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fetchBookings();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 9;
      final url =
          "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/get_all_bookings.php?user_id=$userId";
      final response = await http.get(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        setState(() {
          allBookings = decoded['data'] ?? [];
          isLoading = false;
        });
        _animController.forward(from: 0);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<dynamic> get _filteredBookings {
    return allBookings.where((b) {
      final String s = (b['status'] ?? '').toString().toLowerCase().trim();
      if (isUpcoming) {
        return s == 'pending' || s == 'confirmed' || s == '';
      } else {
        return s == 'completed' || s == 'cancelled';
      }
    }).toList()..sort(
      (a, b) => (int.tryParse(b['id'].toString()) ?? 0).compareTo(
        int.tryParse(a['id'].toString()) ?? 0,
      ),
    );
  }

  // Status config
  _StatusConfig _statusConfig(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return _StatusConfig(
          color: const Color(0xFF22C55E),
          bg: const Color(0xFFDCFCE7),
          icon: Icons.check_circle_rounded,
        );
      case 'completed':
        return _StatusConfig(
          color: const Color(0xFF6366F1),
          bg: const Color(0xFFEEEDFD),
          icon: Icons.task_alt_rounded,
        );
      case 'cancelled':
        return _StatusConfig(
          color: const Color(0xFFEF4444),
          bg: const Color(0xFFFEE2E2),
          icon: Icons.cancel_rounded,
        );
      case 'pending':
      default:
        return _StatusConfig(
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFEF3C7),
          icon: Icons.schedule_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Bookings",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${allBookings.length} total bookings",
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B6D88)),
              ),
            ],
          ),
          GestureDetector(
            onTap: _fetchBookings,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _tabBtn("Upcoming", isUpcoming, Icons.upcoming_rounded, () {
              setState(() => isUpcoming = true);
              _animController.forward(from: 0);
            }),
            _tabBtn("History", !isUpcoming, Icons.history_rounded, () {
              setState(() => isUpcoming = false);
              _animController.forward(from: 0);
            }),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(String label, bool active, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: active ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : const Color(0xFFB0B2C8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFFB0B2C8),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEBF5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No bookings here",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your bookings will appear here",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6D88)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          final String status = (b['status'] ?? 'Pending').toString();
          final config = _statusConfig(status);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 60)),
            curve: Curves.easeOut,
            builder: (context, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - val)),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _bookingCard(b, status, config),
            ),
          );
        },
      ),
    );
  }

  // ── Booking Card ───────────────────────────────────────────

  Widget _bookingCard(Map b, String status, _StatusConfig config) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsUI(bookingId: b['id'].toString()),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top strip with status color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: config.bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(config.icon, color: config.color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: config.color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "REF# ${b['id']}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B6D88),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEBF5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: _primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['service_name'] ?? 'Service',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1C3A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b['provider_name'] ?? 'Provider',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B6D88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${b['amount'] ?? '—'}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),

                  // Date + action buttons
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFF6B6D88),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        b['booking_date'] ?? 'TBD',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B6D88),
                        ),
                      ),
                      const Spacer(),
                      // Action buttons
                      if (status.toLowerCase() == 'completed') ...[
                        _outlineBtn("Rate", Icons.star_rounded, () {
                          debugPrint("Rating ${b['id']}");
                        }),
                        const SizedBox(width: 8),
                      ],
                      _solidBtn(
                        isUpcoming ? "Details" : "View",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingDetailsUI(bookingId: b['id'].toString()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _solidBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEDFD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: _accent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: _accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusConfig {
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusConfig({
    required this.color,
    required this.bg,
    required this.icon,
  });
}
