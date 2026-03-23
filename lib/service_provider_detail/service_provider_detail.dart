import 'package:flutter/material.dart';
import 'package:nearfix/booking_screen/scheduling_screen.dart';

const Color _primary = Color(0xFF33365D);
const Color _bg      = Color(0xFFF6F7FB);

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
      "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/";

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
        widget.provider['profile_photo_path'] ??
        widget.provider['photo'] ??
        "";
    final String charges =
        widget.provider['visiting_charges']?.toString() ?? "0";

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, photoPath, name, title),
                  const SizedBox(height: 16),
                  _buildStatsRow(experience),
                  const SizedBox(height: 14),
                  _buildPriceSection(charges),
                  const SizedBox(height: 14),
                  _buildAboutSection(name, aboutMe),
                  const SizedBox(height: 14),
                  _buildReviewCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(name, title, providerId, charges),
        ],
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, String photoPath, String name, String title) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1F3E), Color(0xFF33365D), Color(0xFF282B52)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Arc decoration
          Positioned.fill(child: CustomPaint(painter: _ArcPainter())),
          // Content column
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                // Photo LEFT — name + profession RIGHT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: photoPath.isNotEmpty
                                ? Image.network(
                                    "$_baseUrl$photoPath",
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _avatarFallback(),
                                  )
                                : _avatarFallback(),
                          ),
                        ),
                        // Online dot
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Name + profession
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -.4,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0x33FFFFFF)),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xCCFFFFFF),
                                fontWeight: FontWeight.w600,
                                letterSpacing: .3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFFEAEBF5),
        child: const Icon(Icons.person, size: 50, color: _primary),
      );

  // ── STATS ROW ────────────────────────────────────────────────────
  Widget _buildStatsRow(String exp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEFF8), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 24,
                offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 1)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statCell("4.9", "RATING",
                  Icons.star_rounded,
                  const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
              const VerticalDivider(
                  width: 1, thickness: 1, color: Color(0xFFEEEFF5)),
              _statCell("$exp Yrs", "EXPERIENCE",
                  Icons.workspace_premium_rounded,
                  _primary, const Color(0xFFEAEBF5)),
              const VerticalDivider(
                  width: 1, thickness: 1, color: Color(0xFFEEEFF5)),
              _statCell("Verified", "STATUS",
                  Icons.verified_rounded,
                  const Color(0xFF22C55E), const Color(0xFFDCFCE7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCell(String value, String label, IconData icon,
      Color color, Color bgColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration:
                  BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9B9DB8),
                letterSpacing: .8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PRICE ────────────────────────────────────────────────────────
  Widget _buildPriceSection(String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEFF8), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 24,
                offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.currency_rupee_rounded,
                  color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 16),
            // Label + sub
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Visiting Charges",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6D88),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "One-time inspection fee",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9B9DB8),
                    ),
                  ),
                ],
              ),
            ),
            // Price badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                "₹$price",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                  letterSpacing: -.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ABOUT ────────────────────────────────────────────────────────
  Widget _buildAboutSection(String name, String bio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEFF8), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 24,
                offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent-bar label
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "ABOUT $name".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9B9DB8),
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bio — same text, better line height + colour
            Text(
              bio,
              style: const TextStyle(
                color: Color(0xFF4A4D6A),
                height: 1.75,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── REVIEW CARD ──────────────────────────────────────────────────
  Widget _buildReviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEFF8), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 24,
                offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent-bar label
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "REVIEWS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9B9DB8),
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating summary row
            Row(
              children: [
                // Big score
                const Text(
                  "4.9",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (_) => const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 18),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Based on 124 reviews",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B9DB8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF0F0F8), height: 1),
            const SizedBox(height: 16),

            // Review tile
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E9F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "User Review",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1A1C3A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "2 days ago",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9B9DB8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "\"Excellent work! Prompt and very professional.\"",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A4D6A),
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM BAR ───────────────────────────────────────────────────
  Widget _buildBottomBar(
      String name, String job, String providerId, String amount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, -4)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
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
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C1F3E), Color(0xFF33365D)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: 64,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Book Now  •  ₹$amount",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x0FFFFFFF);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
          Offset(size.width * .88, size.height * .2), 40.0 + i * 30, p1);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}