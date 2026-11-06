import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whether_app/models/weather_models.dart';
import 'package:flutter_whether_app/widgets/daily_forecast_view.dart';
import 'package:flutter_whether_app/widgets/hourly_forecast_view.dart';
import 'package:flutter_whether_app/widgets/weather_metrics_grid.dart';

void main() {
  testWidgets('WeatherMetricsGrid renders all 4 key metric tiles', (tester) async {
    final current = CurrentWeather(
      temperature: 22.0,
      apparentTemperature: 21.0,
      relativeHumidity: 55,
      precipitation: 1.2,
      weatherCode: 0,
      windSpeed: 14.5,
      windDirection: 90,
      isDay: true,
      time: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherMetricsGrid(
            current: current,
            isFahrenheit: false,
          ),
        ),
      ),
    );

    expect(find.text('Feels Like'), findsOneWidget);
    expect(find.text('21°C'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('15 km/h'), findsOneWidget);
    expect(find.text('Precipitation'), findsOneWidget);
    expect(find.text('1.2 mm'), findsOneWidget);
  });

  testWidgets('HourlyForecastView renders list of hours and temperature', (tester) async {
    final hourly = [
      HourlyPoint(
        time: DateTime.now(),
        temperature: 20.0,
        weatherCode: 0,
        precipitationProbability: 0,
      ),
      HourlyPoint(
        time: DateTime.now().add(const Duration(hours: 1)),
        temperature: 22.0,
        weatherCode: 1,
        precipitationProbability: 30,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyForecastView(
            hourly: hourly,
            isFahrenheit: false,
          ),
        ),
      ),
    );

    expect(find.text('Hourly Forecast'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
    expect(find.text('20°C'), findsOneWidget);
    expect(find.text('22°C'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
  });

  testWidgets('DailyForecastView renders 7-day forecast items', (tester) async {
    final daily = [
      DailyPoint(
        date: DateTime.now(),
        weatherCode: 0,
        maxTemp: 25.0,
        minTemp: 15.0,
        precipitationSum: 0.0,
        uvIndexMax: 5.0,
      ),
      DailyPoint(
        date: DateTime.now().add(const Duration(days: 1)),
        weatherCode: 61,
        maxTemp: 22.0,
        minTemp: 14.0,
        precipitationSum: 3.5,
        uvIndexMax: 4.0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyForecastView(
            daily: daily,
            isFahrenheit: false,
          ),
        ),
      ),
    );

    expect(find.text('7-Day Forecast'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('25°C'), findsOneWidget);
    expect(find.text('15°C'), findsOneWidget);
    expect(find.text('3.5mm'), findsOneWidget);
  });
}
