import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Notifications",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
          body: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue, // Or any color that fits your theme
                    child: Icon(Icons.wallet, color: Colors.white),
                  ),
                  title: const Text(
                    "Booking confirmed",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Your appointment was confirmed successfully."),
                  trailing: const Text(
                    "2h ago",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // Add navigation or marking as read here
                  },
                ),
              );
            },
          )
    );
  }
}
