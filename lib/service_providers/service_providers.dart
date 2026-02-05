import 'package:flutter/material.dart';

import '../service_provider_detail/service_provider_detail.dart';
// Import your detail screen file here
// import 'service_provider_detail_screen.dart';

class ServiceProvidersScreen extends StatelessWidget {
  final String serviceName;
  static const Color primaryColor = Color(0xFF33365D);

  const ServiceProvidersScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Professional",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("3 experts found", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProviderCard(
            context,
            name: "Sarah Jenkins",
            subTitle: "Expert Cleaner",
            price: "\$25/hr",
            rating: "4.9",
            jobs: "250+ Jobs",
            isVerified: true,
            imageColor: const Color(0xFFE0E7FF),
          ),
          _buildProviderCard(
            context,
            name: "Michael Ross",
            subTitle: "Plumbing & Repair",
            price: "\$40/hr",
            rating: "4.8",
            jobs: "180+ Jobs",
            isVerified: true,
            imageColor: const Color(0xFFFFE4E6),
          ),
          _buildProviderCard(
            context,
            name: "David Kim",
            subTitle: "Electrician",
            price: "\$35/hr",
            rating: "4.5",
            jobs: "15+ Jobs",
            isVerified: false,
            imageColor: const Color(0xFFFEF3C7),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
      BuildContext context, {
        required String name,
        required String subTitle,
        required String price,
        required String rating,
        required String jobs,
        required bool isVerified,
        required Color imageColor,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the Detail Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceProviderDetailScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: imageColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.black26),
                  ),
                  Positioned(
                    bottom: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(rating,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                        Text(price,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      ],
                    ),
                    Text(subTitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTag(jobs),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          _buildTag("Verified"),
                        ],
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

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Placeholder for the detail screen to avoid errors

