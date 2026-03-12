# NearFix — Flutter Customer Application

> On-Demand Home Services Platform | Flutter SDK | PHP Backend via Ngrok

---

## Overview

NearFix connects customers with local home service providers. Users can browse service categories, view provider profiles, schedule appointments, manage addresses, track bookings, and chat with providers.

This is **App 1 of 2** — the customer-facing Flutter app. The backend is PHP APIs tunnelled via Ngrok.

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — onboarding/login/home routing
├── authentication/
│   ├── sign_in.dart                 # Login screen
│   ├── sign_up.dart                 # Registration screen
│   └── auth_provider.dart           # AuthService (ChangeNotifier)
├── home_screen/
│   └── home_screen.dart             # Dashboard — categories, providers, upcoming booking
├── service_providers/
│   └── service_providers.dart       # Provider list filtered by category
├── service_provider_detail/
│   └── service_provider_detail.dart # Provider profile + Book Now CTA
├── booking_screen/
│   ├── bookings_screen.dart         # Upcoming / Past bookings tabs
│   ├── booking_screen_details.dart  # Full booking detail view
│   └── scheduling_screen.dart       # Date, notes, address, confirm booking
├── address_screen/
│   ├── address_screen.dart          # View saved addresses
│   └── add_address_form_screen.dart # Add new address form
├── chat_screen/
│   ├── chat_screen_tile.dart        # Chat list
│   └── chatscreen.dart              # Individual chat thread
├── notifications/
│   └── notifications.dart           # Notifications screen
├── payment_screen/
│   └── ghost_payment_screen.dart    # Placeholder payment screen
├── profile_screen/
│   ├── profile_screen.dart          # User profile
│   ├── edit_profile.dart            # Edit profile
│   └── help_support_screen.dart     # Help & Support
└── all_service_providers/
    └── all_service_providers.dart   # Full service category grid
```

---

## Screens & Features

| Screen | Description |
|--------|-------------|
| Onboarding | Shown on first launch only (`onboarding_seen` flag) |
| Sign In / Sign Up | Email + password auth via PHP API |
| Home | Service grid, recommended providers, upcoming booking card |
| Service Providers | Provider list filtered by category |
| Provider Detail | Profile, rating, visiting charge, Book Now |
| Scheduling | Date picker, notes, address selection, booking submission |
| Bookings | Upcoming (pending/confirmed) and Past (completed/cancelled) tabs |
| Address | View and add saved addresses (Home / Work / Other) |
| Chat | Chat tile list + individual thread (UI only) |
| Notifications | Notifications list |
| Payment | Placeholder — not yet integrated |
| Profile | View/edit profile, Help & Support, Logout |
