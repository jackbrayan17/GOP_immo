# GOP Immo (Global Property Management)

GOP Immo is a premium Flutter application designed for real estate management in Africa. It centralizes property listings, tenant-owner communication, and financial tracking into a single, offline-reliable platform.

## 🚀 Getting Started

### Prerequisites

To run this project, ensure you have the following installed:
- **Flutter SDK:** ^3.10.0 (Supports SDK >=2.19.0 <4.0.0)
- **Dart SDK:** Included with Flutter
- **Java Development Kit (JDK):** Version 17 or higher (Required for Android builds)
- **Android Studio / Xcode:** For mobile development
- **VS Code / IntelliJ:** Recommended IDEs with Flutter/Dart extensions

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/gp_immo_flutter.git
    cd gp_immo_flutter
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

## 🛠️ Build & Run Instructions

### Running in Development

To run the application on a connected device or emulator:

```bash
flutter run
```

If you have multiple devices, specify one:
```bash
flutter run -d <device_id>
```

For web development:
```bash
flutter run -d chrome
```

### Release Builds

#### Android (APK)
To generate a release APK:
```bash
flutter build apk --release
```
The output file will be located at: `build/app/outputs/flutter-apk/app-release.apk`

#### Android (App Bundle)
To generate an Android App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

#### Web
To build for web deployment:
```bash
flutter build web
```

## 🏗️ Architecture & Tech Stack

- **Framework:** Flutter (Cross-platform)
- **State Management:** Provider
- **Local Database:** SQLite (via `sqflite`)
- **UI Architecture:** Clean, modular structure with Repository Pattern
- **Notifications:** `flutter_local_notifications`

## 📝 Key Features

- **Dashboard:** Real-time property and financial metrics.
- **Marketplace:** Property search with advanced filters.
- **Inbox:** Real-time user-to-user chat.
- **Offline Mode:** Data persistence via SQLite.

## 🛠️ Troubleshooting

- **Android Build Failure:** If you encounter errors related to `bigLargeIcon` or Java versions, ensure your JDK is set to version 17+. The project is configured with core library desugaring to support modern Java features.
- **Dependency Issues:** Run `flutter clean` follow by `flutter pub get` if you notice stale package references.

---
Developed by [Your Name/Team] - GOP Immo Project.
