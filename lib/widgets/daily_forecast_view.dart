import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/app_colors.dart';
import '../utils/weather_helper.dart';

class DailyForecastView extends StatelessWidget {
  final List<DailyPoint> daily;
  final bool isFahrenheit;

  const DailyForecastView({
    super.key,
    required this.daily,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: AppColors.textPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                '7-Day Forecast',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.borderLight,
              height: 16,
            ),
            itemBuilder: (context, index) {
              final item = daily[index];
              final isToday = index == 0;
              final isTomorrow = index == 1;

              final String dayLabel = isToday
                  ? 'Today'
                  : isTomorrow
                      ? 'Tomorrow'
                      : _weekdayToString(item.date.weekday);

              final imagePath = WeatherHelper.getWeatherAssetImage(item.weatherCode);
              final description = WeatherHelper.getWeatherDescription(item.weatherCode);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text(
                        dayLabel,
                        style: TextStyle(
                          color: isToday ? AppColors.accentAmber : AppColors.textPrimary,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset(
                        imagePath,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.wb_sunny_rounded,
                          color: AppColors.accentAmber,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.precipitationSum > 0) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.grain, size: 12, color: Colors.lightBlueAccent),
                          const SizedBox(width: 2),
                          Text(
                            '${item.precipitationSum.toStringAsFixed(1)}mm',
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          WeatherHelper.formatTemperature(item.maxTemp, isFahrenheit: isFahrenheit),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          WeatherHelper.formatTemperature(item.minTemp, isFahrenheit: isFahrenheit),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  String _weekdayToString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
