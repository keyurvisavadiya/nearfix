import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service_provider_detail/service_provider_detail.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final String serviceName;
  const ServiceProvidersScreen({super.key, required this.serviceName});

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  static const Color primaryColor = Color(0xFF33365D);
  final String baseUrl = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/";

  List<dynamic> _providers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);
    try {
      // 1. Check/Request Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Get User Position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      // 3. Call the NEW PHP script with coordinates
      final String queryUrl =
          "${baseUrl}get_nearby_providers.php" +
              "?category=${widget.serviceName}" +
              "&lat=${position.latitude}" +
              "&lng=${position.longitude}";
      print("USER LOCATION: ${position.latitude}, ${position.longitude}");

      final response = await http.get(Uri.parse(queryUrl),
          headers: {"ngrok-skip-browser-warning": "true"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _providers = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "No experts found within 8km";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: Please enable location services";
        _isLoading = false;
      });
    }
  }

  // --- PRICE FORMATTING HELPER ---
  String _formatPrice(dynamic price) {
    if (price == null || price.toString() == "0" || price.toString() == "0.00") {
      return "Free Visit";
    }
    double p = double.tryParse(price.toString()) ?? 0;
    return "₹${p.toInt()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.serviceName, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("${_providers.length} experts found", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildProviderList(),
    );
  }

  Widget _buildProviderList() {
    if (_errorMessage != null && _providers.isEmpty) {
      return Center(child: Text(_errorMessage!));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];

        // 1. Extract the distance sent by the PHP script
        // We use double.tryParse to be safe, then format to 1 decimal place
        double distanceValue = double.tryParse(provider['distance'].toString()) ?? 0.0;
        String distanceLabel = "${distanceValue.toStringAsFixed(1)} km away";

        return _buildProviderCard(
          context,
          providerData: provider,
          name: provider['full_name'] ?? "Expert",
          // 2. Change subTitle to show the distance
          subTitle: distanceLabel,
          price: _formatPrice(provider['visiting_charges']),
          rating: "4.9",
          imageUrl: baseUrl + (provider['profile_photo_path'] ?? ""),
          isVerified: true,
        );
      },
    );
  }

  Widget _buildProviderCard(BuildContext context, {
    required Map<String, dynamic> providerData,
    required String name,
    required String subTitle,
    required String price,
    required String rating,
    required String imageUrl,
    required bool isVerified,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceProviderDetailScreen(provider: providerData))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              _buildImageStack(imageUrl, rating),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                        // --- PRICE DISPLAY ---
                        Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                      ],
                    ),
                    Text(subTitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTag("Verified Partner"),
                        const SizedBox(width: 6),
                        if (isVerified) const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Keeping existing helpers: _buildImageStack, _buildTag)
  Widget _buildImageStack(String url, String rating) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url, height: 75, width: 75, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(height: 75, width: 75, color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey)),
          ),
        ),
        Positioned(
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
            child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 12), const SizedBox(width: 2), Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}