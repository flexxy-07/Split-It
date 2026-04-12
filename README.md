# split_it

A new Flutter project.

## Getting Started

## Local setup notes

### Firebase Android config
This app requires the Firebase Android config file at `android/app/google-services.json`.
It is intentionally ignored by git. Download it from Firebase Console:
- Project Settings -> Your apps -> Android -> Download `google-services.json`
- Place it in `android/app/google-services.json`

### Environment file
Create a `.env` file at the project root (see `.env.example`) and fill in values.
This file is loaded at startup via `flutter_dotenv`.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
