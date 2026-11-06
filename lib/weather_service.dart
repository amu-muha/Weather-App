import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/location_model.dart';
import 'models/weather_models.dart';

class WeatherService {
  static const String _weatherCachePrefix = 'cached_weather_';
  static const String _savedLocationKey = 'saved_selected_location';
  static const String _tempUnitKey = 'is_fahrenheit_unit';

  final http.Client _client;
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches comprehensive weather for a given [location] (or stored location if null).
  /// Falls back to offline cached data if the network is unavailable.
  Future<WeatherData> getWeatherData({
    LocationModel? location,
    bool forceRefresh = false,
  }) async {
    final activeLocation = location ?? await getSavedLocation();
    final cacheKey = '$_weatherCachePrefix${activeLocation.latitude}_${activeLocation.longitude}';

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${activeLocation.latitude}'
        '&longitude=${activeLocation.longitude}'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,is_day'
        '&hourly=temperature_2m,weather_code,precipitation_probability'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,uv_index_max'
        '&timezone=auto',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final weatherData = WeatherData.fromOpenMeteoJson(
          json: data,
          location: activeLocation,
        );

        // Cache latest fetched data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(weatherData.toJson()));

        return weatherData;
      } else {
        throw Exception('Failed to load weather data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: load from SharedPreferences cache
      final cached = await _getCachedWeatherData(cacheKey);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  /// Searches global cities using Open-Meteo's free Geocoding API
  Future<List<LocationModel>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeComponent(cleanQuery)}&count=10&language=en&format=json',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results == null) return [];

        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // If search fails or times out, return empty list
    }
    return [];
  }

  /// Saves the active city in persistent preferences
  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedLocationKey, jsonEncode(location.toJson()));
  }

  /// Retrieves the persisted city, defaulting to Addis Ababa
  Future<LocationModel> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_savedLocationKey);
      if (savedStr != null) {
        return LocationModel.fromJson(jsonDecode(savedStr) as Map<String, dynamic>);
      }
    } catch (_) {}
    return LocationModel.defaultLocation;
  }

  /// Temperature unit preference (Celsius vs Fahrenheit)
  Future<bool> isFahrenheit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tempUnitKey) ?? false;
  }

  Future<void> setFahrenheit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tempUnitKey, value);
  }

  Future<WeatherData?> _getCachedWeatherData(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(cacheKey);
      if (cachedStr != null) {
        final decoded = jsonDecode(cachedStr) as Map<String, dynamic>;
        return WeatherData.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  /// Legacy helper method preserved for backward-compatibility
  Future<List<Map<String, dynamic>>> fetchWeatherHistory() async {
    final weather = await getWeatherData();
    return [
      {
        'current': weather.current.toJson(),
        'current_units': {
          'wind_speed_10m': ' km/h',
          'relative_humidity_2m': '%',
          'precipitation': ' mm',
        },
        'saved_at': weather.fetchedAt.toIso8601String(),
        'timestamp_label': 'Now',
      }
    ];
  }
}
