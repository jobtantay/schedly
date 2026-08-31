# ✈️ Schedly

A mobile trip planning app built with Flutter and Supabase.
Plan your trips, organize activities, track budgets, and never miss a departure again.

🌐 **Live Demo:** https://schedly-lake.vercel.app

---

## Features

- 🔐 Email authentication (sign up / log in)
- 🧳 Create and manage trips with destination, dates, and budget
- 📍 Location autocomplete powered by OpenStreetMap
- 🗺️ Interactive map pin for each destination
- ✅ Per-trip checklist
- 📅 Calendar view with trip markers
- 📜 Trip history
- 🔔 Local reminders before trip dates
- ✏️ Edit and delete trips

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Supabase (PostgreSQL + Auth) |
| Maps | flutter_map + OpenStreetMap |
| Location Search | Nominatim API (free) |
| Notifications | flutter_local_notifications |
| Routing | go_router |
| State Management | Provider |
| Deployment | Vercel (web) |

---

## Getting Started

### Prerequisites
- Flutter SDK
- A Supabase account

### Setup
1. Clone the repo
```bash
   git clone https://github.com/yourusername/schedly.git
   cd schedly
```

2. Install dependencies
```bash
   flutter pub get
```

3. Add your Supabase credentials in `lib/core/supabase/supabase_config.dart`
```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

4. Run the app
```bash
   flutter run
```

---

## Screenshots
<img width="946" height="2046" alt="image" src="https://github.com/user-attachments/assets/b3d986be-82e4-4305-9700-bc1ef3bc8ca4" />
<img width="946" height="2046" alt="image" src="https://github.com/user-attachments/assets/b7c03348-68b6-4b93-a51d-fa798bc83557" />
<img width="946" height="2046" alt="image" src="https://github.com/user-attachments/assets/0f583b95-4d6e-4653-bf21-de2c284a6008" />



---

## License

MIT
