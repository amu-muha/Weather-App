import 'location_model.dart';

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final bool isDay;
  final DateTime time;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.isDay,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind_direction_10m'] as num?)?.toInt() ?? 0,
      isDay: ((json['is_day'] as num?)?.toInt() ?? 1) == 1,
      time: json['time'] != null ? DateTime.tryParse(json['time']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature_2m': temperature,
      'apparent_temperature': apparentTemperature,
      'relative_humidity_2m': relativeHumidity,
      'precipitation': precipitation,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
      'wind_direction_10m': windDirection,
      'is_day': isDay ? 1 : 0,
      'time': time.toIso8601String(),
    };
  }
}

class HourlyPoint {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyPoint({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  factory HourlyPoint.fromLists({
    required String timeStr,
    required num tempNum,
    required num codeNum,
    num? precipProb,
  }) {
    return HourlyPoint(
      time: DateTime.tryParse(timeStr) ?? DateTime.now(),
      temperature: tempNum.toDouble(),
      weatherCode: codeNum.toInt(),
      precipitationProbability: precipProb?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weather_code': weatherCode,
      'precipitation_probability': precipitationProbability,
    };
  }

  factory HourlyPoint.fromJson(Map<String, dynamic> json) {
    return HourlyPoint(
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      precipitationProbability: (json['precipitation_probability'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyPoint {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double precipitationSum;
  final double uvIndexMax;

  const DailyPoint({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationSum,
    required this.uvIndexMax,
  });

  factory DailyPoint.fromLists({
    required String dateStr,
    required num codeNum,
    required num maxTempNum,
    required num minTempNum,
    num? precipSumNum,
    num? uvIndexMaxNum,
  }) {
    return DailyPoint(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      weatherCode: codeNum.toInt(),
      maxTemp: maxTempNum.toDouble(),
      minTemp: minTempNum.toDouble(),
      precipitationSum: precipSumNum?.toDouble() ?? 0.0,
      uvIndexMax: uvIndexMaxNum?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weather_code': weatherCode,
      'max_temp': maxTemp,
      'min_temp': minTemp,
      'precipitation_sum': precipitationSum,
      'uv_index_max': uvIndexMax,
    };
  }

  factory DailyPoint.fromJson(Map<String, dynamic> json) {
    return DailyPoint(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble() ?? 0.0,
      uvIndexMax: (json['uv_index_max'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeatherData {
  final LocationModel location;
  final CurrentWeather current;
  final List<HourlyPoint> hourly;
  final List<DailyPoint> daily;
  final DateTime fetchedAt;

  const WeatherData({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  factory WeatherData.fromOpenMeteoJson({
    required Map<String, dynamic> json,
    required LocationModel location,
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final currentWeather = CurrentWeather.fromJson(currentJson);

    final hourlyJson = json['hourly'] as Map<String, dynamic>?;
    final List<HourlyPoint> hourlyPoints = [];
    if (hourlyJson != null) {
      final times = (hourlyJson['time'] as List?)?.cast<String>() ?? [];
      final temps = (hourlyJson['temperature_2m'] as List?) ?? [];
      final codes = (hourlyJson['weather_code'] as List?) ?? [];
      final probs = (hourlyJson['precipitation_probability'] as List?) ?? [];

      final now = DateTime.now();
      for (int i = 0; i < times.length; i++) {
        final pointTime = DateTime.tryParse(times[i]);
        // Include hours starting from current hour up to next 24 hours
        if (pointTime != null && pointTime.isAfter(now.subtract(const Duration(hours: 1)))) {
          hourlyPoints.add(
            HourlyPoint.fromLists(
              timeStr: times[i],
              tempNum: temps.length > i ? (temps[i] as num) : 0,
              codeNum: codes.length > i ? (codes[i] as num) : 0,
              precipProb: probs.length > i ? (probs[i] as num?) : 0,
            ),
          );
          if (hourlyPoints.length >= 24) break;
        }
      }
    }

    final dailyJson = json['daily'] as Map<String, dynamic>?;
    final List<DailyPoint> dailyPoints = [];
    if (dailyJson != null) {
      final dates = (dailyJson['time'] as List?)?.cast<String>() ?? [];
      final codes = (dailyJson['weather_code'] as List?) ?? [];
      final maxTemps = (dailyJson['temperature_2m_max'] as List?) ?? [];
      final minTemps = (dailyJson['temperature_2m_min'] as List?) ?? [];
      final precipSums = (dailyJson['precipitation_sum'] as List?) ?? [];
      final uvIndices = (dailyJson['uv_index_max'] as List?) ?? [];

      for (int i = 0; i < dates.length; i++) {
        dailyPoints.add(
          DailyPoint.fromLists(
            dateStr: dates[i],
            codeNum: codes.length > i ? (codes[i] as num) : 0,
            maxTempNum: maxTemps.length > i ? (maxTemps[i] as num) : 0,
            minTempNum: minTemps.length > i ? (minTemps[i] as num) : 0,
            precipSumNum: precipSums.length > i ? (precipSums[i] as num?) : 0,
            uvIndexMaxNum: uvIndices.length > i ? (uvIndices[i] as num?) : 0,
          ),
        );
      }
    }

    return WeatherData(
      location: location,
      current: currentWeather,
      hourly: hourlyPoints,
      daily: dailyPoints,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'daily': daily.map((d) => d.toJson()).toList(),
      'fetched_at': fetchedAt.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: (json['hourly'] as List<dynamic>?)
              ?.map((e) => HourlyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      daily: (json['daily'] as List<dynamic>?)
              ?.map((e) => DailyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fetchedAt: DateTime.tryParse(json['fetched_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

