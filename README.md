# 🌦️ Flutter Weather App

A modern, high-performance Flutter weather application featuring real-time meteorological forecasts, dynamic 24-hour timelines, 7-day extended projections, global city search, and instant offline caching.

---

## ✨ Features

- **Global City Search & Geocoding**: Search and view real-time weather for any city worldwide using Open-Meteo's geocoding engine with debounced autocomplete and quick-select presets.
- **24-Hour Hourly Timeline**: Interactive horizontal forecast displaying condition icons, hourly progression, and rain probability metrics.
- **7-Day Extended Forecast**: Complete week outlook showcasing daily highs, lows, weather condition descriptions, and precipitation sums.
- **In-Depth Weather Metrics**: Clean grid tiles showing "Feels Like" temperature, humidity levels, wind speed & compass direction, and rain accumulation.
- **Unit Customization**: Seamless toggle between Celsius (°C) and Fahrenheit (°F) with persistent user preference storage.
- **Offline First Architecture**: Automatically caches weather snapshots in `SharedPreferences` to ensure full app functionality even when disconnected.
- **Ambient Dark Theme UI**: Built with Material 3 styling, edge-to-edge transparent system bars, ambient solar radial glows, and floating navigation pills.
- **Auto-Refresh**: Live data updates every 5 minutes automatically, with pull-to-refresh on demand.

---

## 🏗️ Architecture & Project Structure

The project follows clean architecture principles, separating models, presentation widgets, data services, and design tokens:

```text
Weather-App/
├── lib/
│   ├── main.dart                      # App entry point, system overlay & theme definition
│   ├── home_page.dart                 # Primary dashboard screen & coordinator
│   ├── weather_service.dart           # Open-Meteo API client, geocoding & SharedPreferences cache
│   ├── models/
│   │   ├── location_model.dart        # Strongly-typed location model with serialization
│   │   └── weather_models.dart        # WeatherData, CurrentWeather, HourlyPoint & DailyPoint
│   ├── utils/
│   │   ├── app_colors.dart            # Unified design system color tokens & ambient gradients
│   │   └── weather_helper.dart        # WMO code translations, unit conversions & asset mappers
│   └── widgets/
│       ├── city_search_sheet.dart     # Modal bottom sheet for searching & selecting cities
│       ├── daily_forecast_view.dart   # 7-day extended forecast breakdown widget
│       ├── hourly_forecast_view.dart  # 24-hour horizontal scrolling forecast cards
│       ├── settings_sheet.dart        # Settings modal for °C/°F units & cache control
│       └── weather_metrics_grid.dart  # Responsive 2x2 grid for detailed metrics
├── assets/images/                     # 3D Weather illustration assets
├── test/
│   ├── models_and_utils_test.dart     # Unit tests for models, serialization & helpers
│   ├── widgets_test.dart              # Component widget tests for UI elements
│   └── widget_test.dart               # App smoke test
└── pubspec.yaml                       # Dependencies & Flutter asset declarations
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.12.0` or higher
- Dart SDK `^3.0.0`
- Android / iOS emulator, browser, or connected physical device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/Weather-App.git
   cd Weather-App
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run all unit and widget tests:

```bash
flutter test
```

Test coverage includes:
- JSON deserialization and serialization round-trips for `LocationModel` and `WeatherData`.
- Accurate WMO weather code mapping to asset paths and human-readable summaries.
- Celsius to Fahrenheit unit conversions.
- Component rendering for `WeatherMetricsGrid`, `HourlyForecastView`, and `DailyForecastView`.

---

## 🌐 Data Sources & Attribution

- **Weather Forecast Data**: [Open-Meteo Free Weather API](https://open-meteo.com/) (No API key required)
- **Geocoding & City Search**: [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api)
