import 'package:flutter/material.dart';
import 'package:nearfix/booking_screen/scheduling_screen.dart';

const Color _primary = Color(0xFF33365D);
const Color _bg = Color(0xFFF6F7FB);

class ServiceProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final double latitude;
  final double longitude;

  const ServiceProviderDetailScreen({
    super.key,
    required this.provider,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ServiceProviderDetailScreen> createState() =>
      _ServiceProviderDetailScreenState();
}

class _ServiceProviderDetailScreenState
    extends State<ServiceProviderDetailScreen> {
  final String _baseUrl =
      "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/";

  @override
  Widget build(BuildContext context) {
    final String providerId = widget.provider['id']?.toString() ?? "0";
    final String name =
        widget.provider['full_name'] ?? widget.provider['name'] ?? "Provider";
    final String title =
        widget.provider['job_title'] ??
        widget.provider['title'] ??
        "Professional";
    final String aboutMe =
        widget.provider['about_me'] ??
        "No biography provided by this professional.";
    final String experience =
        widget.provider['experience_years']?.toString() ??
        widget.provider['experience']?.toString() ??
        "0";
    final String photoPath =
        widget.provider['profile_photo_path'] ?? widget.provider['photo'] ?? "";
    final String charges =
        widget.provider['visiting_charges']?.toString() ?? "0";

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, photoPath, name, title),
                  const SizedBox(height: 20),
                  _buildStatsRow(experience),
                  const SizedBox(height: 8),
                  _buildPriceSection(charges),
                  _buildSectionTitle("About $name"),
                  _buildAboutText(aboutMe),
                  _buildSectionTitle("Reviews"),
                  _buildReviewCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomBar(name, title, providerId, charges),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    String photoPath,
    String name,
    String title,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),

        // Avatar + name
        Positioned(
          bottom: -70,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: photoPath.isNotEmpty
                      ? Image.network(
                          "$_baseUrl$photoPath",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6D88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() => Container(
    color: const Color(0xFFEAEBF5),
    child: const Icon(Icons.person, size: 50, color: _primary),
  );

  // ── Stats ─────────────────────────────────────────────────

  Widget _buildStatsRow(String exp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _statItem("4.9", "RATING", Icons.star_rounded, Color(0xFFF59E0B)),
            _divider(),
            _statItem(
              "$exp Yrs",
              "EXPERIENCE",
              Icons.workspace_premium_rounded,
              _primary,
            ),
            _divider(),
            _statItem(
              "Verified",
              "STATUS",
              Icons.verified_rounded,
              Color(0xFF22C55E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C3A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B6D88),
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE5E7EB));

  // ── Price ─────────────────────────────────────────────────

  Widget _buildPriceSection(String price) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "Visiting Charges",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              "₹$price",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _primary,
        ),
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────

  Widget _buildAboutText(String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        bio,
        style: const TextStyle(
          color: Color(0xFF444466),
          height: 1.7,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Review ────────────────────────────────────────────────

  Widget _buildReviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAEBF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18, color: _primary),
                ),
                const SizedBox(width: 10),
                const Text(
                  "User Review",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1C3A),
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (_) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "\"Excellent work! Prompt and very professional.\"",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6D88),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────

  Widget _buildBottomBar(
    String name,
    String job,
    String providerId,
    String amount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduleServiceScreen(
                serviceName: job,
                providerId: providerId,
                visitingCharge: amount,
                latitude: widget.latitude,
                longitude: widget.longitude,
              ),
          )
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Book Now  •  ₹$amount",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
