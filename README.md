# ToDo With Appwrite

[![Flutter](https://img.shields.io/badge/Flutter-3.6.1%2B-blue?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.6.1%2B-0175C2?logo=dart)](https://dart.dev/)
[![Appwrite](https://img.shields.io/badge/Backend-Appwrite-F02E65?logo=appwrite)](https://appwrite.io/)

> A cross-platform task-management application built with Flutter and Appwrite.

## 🎥 Video Demo

[Watch the ToDo With Appwrite demo on YouTube](YOUR_YOUTUBE_VIDEO_LINK_HERE)

<!-- Replace YOUR_YOUTUBE_VIDEO_LINK_HERE with the actual YouTube URL. -->

## 📌 Overview

ToDo With Appwrite is a Flutter task-management application that helps users create, organize, update, and complete daily tasks. The application uses Appwrite for authentication and cloud database functionality while also providing local caching and notifications for a smoother offline-friendly experience.

## ✨ Features

- User registration and login with Appwrite authentication
- Email verification support
- Create, edit, delete, and complete tasks
- Add task descriptions, due dates, colors, and notification reminders
- Local notifications for scheduled reminders
- Offline support through cached task data
- Network connectivity checking and retry handling
- Persistent login sessions using shared preferences
- Introductory first-launch screen
- Flutter BLoC state management
- Cross-platform Flutter project structure for Android, iOS, web, and desktop targets

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend:** Appwrite
- **State management:** `flutter_bloc`
- **Local storage:** `shared_preferences`
- **Notifications:** `flutter_local_notifications`
- **Date and time:** `intl`, `timezone`
- **Connectivity:** `connectivity_plus`
- **UI interactions:** `flutter_slidable`

## 📂 Project Structure

```text
midterm/
├── android/                 # Android platform configuration
├── ios/                     # iOS platform configuration
├── lib/
│   ├── backend/             # Appwrite configuration and controllers
│   ├── bloc/                # Todo events, states, and BLoC logic
│   ├── model/               # Data models
│   ├── screen/              # Application screens
│   ├── service/             # Notifications and connectivity services
│   ├── theme/               # App colors and styling
│   └── widgets/             # Reusable UI components
├── assets/                  # Application assets
├── pubspec.yaml             # Flutter dependencies and project metadata
└── README.md
```

## 🚀 Getting Started

### Prerequisites

Before running the project, install:

- [Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK compatible with the version specified in `pubspec.yaml`
- Android Studio or Xcode, depending on the target platform
- An Appwrite project with an account service and database collection configured

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/BuiDongTanDat/ToDo_with_Appwrite.git
   cd ToDo_with_Appwrite/midterm
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Review the Appwrite configuration in:

   ```text
   lib/backend/appwrite_config.dart
   ```

   Update the Appwrite endpoint, project ID, database ID, and collection ID if you are using your own Appwrite project.

4. Run the application:

   ```bash
   flutter run
   ```

## 🔐 Appwrite Configuration

The application requires the following Appwrite resources:

- Appwrite endpoint
- Project ID
- Database ID
- Todo collection ID
- Appropriate collection permissions for authenticated users

For production deployments, avoid committing sensitive configuration or credentials directly to the repository. Use environment-specific configuration where appropriate.

## 🧪 Useful Commands

```bash
# Check connected devices
flutter devices

# Run static analysis
flutter analyze

# Run tests
flutter test

# Build an Android APK
flutter build apk
```

## 📱 Supported Platforms

The project includes Flutter platform folders for:

- Android
- iOS
- Web
- Windows
- macOS
- Linux

Platform-specific notification permissions and Appwrite callback configuration may be required before deployment.

## 🤝 Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a feature branch.
3. Make and test your changes.
4. Open a pull request with a clear description of the changes.

## 📄 License

No license has been specified for this project yet.
