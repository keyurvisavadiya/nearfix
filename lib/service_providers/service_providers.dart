import 'dart:convert';
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

  // Update this to your current ngrok URL
  final String baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/";

  List<dynamic> _providers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    try {
      // Passing category to PHP script
      final response = await http.get(
        Uri.parse("${baseUrl}get_providers.php?category=${widget.serviceName}"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _providers = data['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "No experts found for ${widget.serviceName}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Connection Error. Please check your server.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.serviceName,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("${_providers.length} experts found", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_errorMessage != null && _providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchProviders,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];
        // Ensuring we use the correct keys from your PHP response
        return _buildProviderCard(
          context,
          providerData: provider, // Passing the full map
          name: provider['name'] ?? "Expert",
          subTitle: provider['title'] ?? widget.serviceName,
          price: "₹350/hr",
          rating: "4.9",
          imageUrl: baseUrl + (provider['photo'] ?? ""),
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
        onTap: () {
          // Fixed navigation: passing the current provider map to the detail screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ServiceProviderDetailScreen(provider: providerData)
              )
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4)
              )
            ],
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
                        Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)
                        ),
                        Text(
                            price,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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

  Widget _buildImageStack(String url, String rating) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            height: 75,
            width: 75,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 75,
              width: 75,
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6)
      ),
      child: Text(
          label,
          style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w600)
      ),
    );
  }
}