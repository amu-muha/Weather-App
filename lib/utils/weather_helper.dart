class WeatherHelper {
  /// Converts Celsius temperature to Fahrenheit
  static double toFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Formats a temperature with correct unit symbol
  static String formatTemperature(double celsius, {bool isFahrenheit = false}) {
    final double value = isFahrenheit ? toFahrenheit(celsius) : celsius;
    return '${value.round()}°${isFahrenheit ? 'F' : 'C'}';
  }

  /// Map Open-Meteo WMO weather codes to appropriate asset images
  static String getWeatherAssetImage(int weatherCode, {bool isDay = true}) {
    if (weatherCode == 0) {
      return isDay ? 'assets/images/sunny.png' : 'assets/images/night_rain.png';
    } else if (weatherCode >= 1 && weatherCode <= 2) {
      return 'assets/images/partly_cloudy.png';
    } else if (weatherCode == 3 || (weatherCode >= 45 && weatherCode <= 48)) {
      return 'assets/images/cloudy.png';
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return isDay ? 'assets/images/rainy.png' : 'assets/images/night_rain.png';
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      return 'assets/images/cloudy.png';
    } else if (weatherCode >= 80 && weatherCode <= 82) {
      return isDay ? 'assets/images/rainy.png' : 'assets/images/night_rain.png';
    } else if (weatherCode >= 95) {
      return 'assets/images/thunderstorm.png';
    }
    return isDay ? 'assets/images/sunny.png' : 'assets/images/cloudy.png';
  }

  /// Map WMO weather code to readable description text
  static String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snowfall';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Partly Cloudy';
    }
  }

  /// Map WMO weather code to advice / summary string
  static String getWeatherSummary(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear skies today. Enjoy the sunshine!';
      case 1:
      case 2:
        return 'Partly cloudy conditions. Great weather for a stroll.';
      case 3:
        return 'Overcast today with dense cloud cover.';
      case 45:
      case 48:
        return 'Foggy conditions. Drive carefully!';
      case 51:
      case 53:
      case 55:
        return 'Light drizzle expected throughout the day.';
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'High rain expected. Don\'t forget an umbrella!';
      case 71:
      case 73:
      case 75:
        return 'Snow showers expected today.';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorms detected. Seek indoor shelter.';
      default:
        return 'Mild weather today.';
    }
  }

  /// Converts wind direction in degrees to a compass cardinal direction
  static String getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index % directions.length];
  }
}
