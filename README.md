# 📍 Geofence Location Reminder (SwiftUI + Realm + MapKit)

A smart iOS app built with **SwiftUI**, **MapKit**, and **Realm** that lets users set **location-based reminders**.  
When you enter or leave a defined area (geofence), the app notifies you instantly.

---

## 🚀 Features

- 🗺️ Interactive **Map View** using `MapKit`
- 📍 **Add reminders** tied to real-world locations
- 🔔 **Local notifications** when entering or exiting geofence zones
- 💾 **Persistent storage** using `Realm`
- 🏷️ **Nearby POIs (Points of Interest)** fetched using OpenStreetMap (Overpass API)
- ⚙️ Simple, modern **SwiftUI interface**
- 🎯 Adjustable **reminder radius** with real-time feedback

---

## 🧠 Tech Stack

| Component | Technology |
|------------|-------------|
| UI Framework | SwiftUI |
| Database | RealmSwift |
| Map & Location | MapKit, CoreLocation |
| Notifications | UserNotifications |
| API | Overpass API (for fetching nearby POIs) |

---

## 🧩 Architecture

The app follows the **MVVM (Model–View–ViewModel)** pattern:

- **Model:** `Reminder`, `POI`
- **ViewModel:** `MapViewModel`, `RemindersViewModel`, `LocationsViewModel`
- **View:** `ContentView`, `CreateReminderSheet`, `MapViewRepresentable`, `RadiusSelector`
- **Services:** `LocationService`, `RealmService`, `NotificationService`

---

## ⚙️ Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/samizafar68/GeofenceLocationReminder.git
