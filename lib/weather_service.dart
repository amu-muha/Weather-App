import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  static const String _historyCacheKey = 'weather_history_list';
  final String _apiUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m';

  /// Fetches live data from API, updates local 5-card timeline, and returns snapshot list
  Future<List<Map<String, dynamic>>> fetchWeatherHistory() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> freshData = jsonDecode(response.body);
        freshData['saved_at'] = DateTime.now().toIso8601String();
        freshData['timestamp_label'] = _getFormattedTime();

        return await _updateHistoryCache(freshData);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Return local cache if network call fails
      final cachedList = await _getHistoryCache();
      if (cachedList.isNotEmpty) {
        return cachedList;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _updateHistoryCache(
      Map<String, dynamic> newData) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> history = await _getHistoryCache();

    if (history.isEmpty || _shouldAddSnapshot(history.last)) {
      // More than 30 mins passed: Convert current NOW to past card & append fresh NOW card
      history.add(newData);
    } else {
      // Less than 30 mins passed: Overwrite the active NOW card with fresh 5-min numbers
      history[history.length - 1] = newData;
    }

    // Retain only the 5 most recent snapshots (drops oldest from left side)
    if (history.length > 5) {
      history = history.sublist(history.length - 5);
    }

    final String encoded = jsonEncode(history);
    await prefs.setString(_historyCacheKey, encoded);

    return history;
  }

  /// Reads cached snapshot list from disk
  Future<List<Map<String, dynamic>>> _getHistoryCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedJson = prefs.getString(_historyCacheKey);

    if (cachedJson != null) {
      final List<dynamic> decoded = jsonDecode(cachedJson);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Checks if 30 minutes have elapsed since the last stored snapshot
  bool _shouldAddSnapshot(Map<String, dynamic> lastEntry) {
    if (!lastEntry.containsKey('saved_at')) return true;
    final lastTime = DateTime.parse(lastEntry['saved_at']);
    return DateTime.now().difference(lastTime).inMinutes >= 30;
  }

  /// Formats time string (HH:mm)
  String _getFormattedTime() {
    final now = DateTime.now();
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}