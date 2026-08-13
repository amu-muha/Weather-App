# Flutter Weather App

A modern Flutter weather dashboard for Addis Ababa, Ethiopia. The app fetches live weather data from the Open-Meteo API, displays a clean dark-mode interface, and caches recent snapshots locally for offline access.

## Features

- Real-time weather information for Addis Ababa
- Dark-themed weather UI with animated status visuals
- Hourly forecast cards for recent weather snapshots
- Auto-refresh support for updated conditions
- Local caching using SharedPreferences for graceful offline fallback

## Tech Stack

- Flutter
- Dart
- Open-Meteo API
- SharedPreferences

## Project Structure

- `lib/main.dart` – app entry point and app shell
- `lib/home_page.dart` – primary dashboard UI and weather rendering logic
- `lib/weather_service.dart` – API calls and local cache handling
- `assets/images/` – weather condition illustration assets
- `test/` – widget and app tests

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed and configured
- An Android emulator, iOS simulator, or a physical device
- Internet access for live weather data

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd flutter_whether_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. To run tests:
   ```bash
   flutter test
   ```

## API

This project uses the Open-Meteo API to fetch current weather and related metrics for the configured location.

## Notes

- Weather data is cached locally to keep the app usable when the network is unavailable.
- The app is configured for the Addis Ababa coordinates used in the weather service.
- Weather conditions are mapped to local asset illustrations in the `assets/images` directory.
