import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whether_app/models/location_model.dart';
import 'package:flutter_whether_app/models/weather_models.dart';
import 'package:flutter_whether_app/utils/weather_helper.dart';

void main() {
  group('LocationModel Tests', () {
    test('Default location is Addis Ababa', () {
      const loc = LocationModel.defaultLocation;
      expect(loc.name, 'Addis Ababa');
      expect(loc.country, 'Ethiopia');
      expect(loc.latitude, 8.9806);
      expect(loc.longitude, 38.7578);
    });

    test('Json serialization and deserialization roundtrip', () {
      const original = LocationModel(
        name: 'Tokyo',
        country: 'Japan',
        latitude: 35.6762,
        longitude: 139.6503,
        admin1: 'Tokyo Prefecture',
      );

      final json = original.toJson();
      final fromJson = LocationModel.fromJson(json);

      expect(fromJson.name, 'Tokyo');
      expect(fromJson.country, 'Japan');
      expect(fromJson.latitude, 35.6762);
      expect(fromJson.longitude, 139.6503);
      expect(fromJson.admin1, 'Tokyo Prefecture');
      expect(fromJson.displayName, 'Tokyo, Tokyo Prefecture, Japan');
    });
  });

  group('WeatherHelper Tests', () {
    test('Celsius to Fahrenheit conversion', () {
      expect(WeatherHelper.toFahrenheit(0), 32);
      expect(WeatherHelper.toFahrenheit(100), 212);
      expect(WeatherHelper.toFahrenheit(20).round(), 68);
    });

    test('Format temperature outputs correct units', () {
      expect(WeatherHelper.formatTemperature(25, isFahrenheit: false), '25°C');
      expect(WeatherHelper.formatTemperature(25, isFahrenheit: true), '77°F');
    });

    test('Weather asset image matches conditions', () {
      expect(WeatherHelper.getWeatherAssetImage(0, isDay: true), 'assets/images/sunny.png');
      expect(WeatherHelper.getWeatherAssetImage(0, isDay: false), 'assets/images/night_rain.png');
      expect(WeatherHelper.getWeatherAssetImage(2), 'assets/images/partly_cloudy.png');
      expect(WeatherHelper.getWeatherAssetImage(3), 'assets/images/cloudy.png');
      expect(WeatherHelper.getWeatherAssetImage(61), 'assets/images/rainy.png');
      expect(WeatherHelper.getWeatherAssetImage(95), 'assets/images/thunderstorm.png');
    });

    test('Wind direction cardinal conversion', () {
      expect(WeatherHelper.getWindDirection(0), 'N');
      expect(WeatherHelper.getWindDirection(90), 'E');
      expect(WeatherHelper.getWindDirection(180), 'S');
      expect(WeatherHelper.getWindDirection(270), 'W');
    });
  });

  group('WeatherData Model Parsing', () {
    test('Correctly parses Open-Meteo json format', () {
      final mockJson = {
        'current': {
          'temperature_2m': 21.5,
          'apparent_temperature': 20.8,
          'relative_humidity_2m': 64,
          'precipitation': 0.0,
          'weather_code': 1,
          'wind_speed_10m': 12.4,
          'wind_direction_10m': 180,
          'is_day': 1,
          'time': '2026-11-06T12:00',
        },
        'hourly': {
          'time': ['2026-11-06T12:00', '2026-11-06T13:00'],
          'temperature_2m': [21.5, 22.0],
          'weather_code': [1, 2],
          'precipitation_probability': [10, 20],
        },
        'daily': {
          'time': ['2026-11-06'],
          'weather_code': [1],
          'temperature_2m_max': [24.0],
          'temperature_2m_min': [14.0],
          'precipitation_sum': [0.5],
          'uv_index_max': [6.2],
        }
      };

      final weather = WeatherData.fromOpenMeteoJson(
        json: mockJson,
        location: LocationModel.defaultLocation,
      );

      expect(weather.location.name, 'Addis Ababa');
      expect(weather.current.temperature, 21.5);
      expect(weather.current.apparentTemperature, 20.8);
      expect(weather.current.relativeHumidity, 64);
      expect(weather.current.isDay, true);
      expect(weather.daily.length, 1);
      expect(weather.daily.first.maxTemp, 24.0);
    });
  });
}
