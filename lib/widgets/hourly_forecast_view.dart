import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/app_colors.dart';
import '../utils/weather_helper.dart';

class HourlyForecastView extends StatelessWidget {
  final List<HourlyPoint> hourly;
  final bool isFahrenheit;

  const HourlyForecastView({
    super.key,
    required this.hourly,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: AppColors.textPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final item = hourly[index];
              final bool isFirst = index == 0;
              final hourString = isFirst
                  ? 'Now'
                  : '${item.time.hour.toString().padLeft(2, '0')}:00';
              final imagePath = WeatherHelper.getWeatherAssetImage(
                item.weatherCode,
                isDay: item.time.hour >= 6 && item.time.hour < 19,
              );

              return Container(
                width: 92,
                margin: EdgeInsets.only(
                  right: 12,
                  left: index == 0 ? 0 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.cardHighlight : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isFirst ? AppColors.borderActive : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hourString,
                      style: TextStyle(
                        color: isFirst ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      width: 38,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.wb_sunny_rounded,
                          color: AppColors.accentAmber,
                          size: 32,
                        ),
                      ),
                    ),
                    if (item.precipitationProbability > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '${item.precipitationProbability}%',
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 10),
                    Text(
                      WeatherHelper.formatTemperature(item.temperature, isFahrenheit: isFahrenheit),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
