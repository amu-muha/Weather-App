import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/app_colors.dart';
import '../utils/weather_helper.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final CurrentWeather current;
  final bool isFahrenheit;

  const WeatherMetricsGrid({
    super.key,
    required this.current,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, color: AppColors.textPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Weather Details',
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildMetricTile(
              icon: Icons.thermostat_outlined,
              label: 'Feels Like',
              value: WeatherHelper.formatTemperature(
                current.apparentTemperature,
                isFahrenheit: isFahrenheit,
              ),
              subtitle: current.apparentTemperature > current.temperature
                  ? 'Warmer than actual'
                  : 'Cooler than actual',
            ),
            _buildMetricTile(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${current.relativeHumidity}%',
              subtitle: current.relativeHumidity > 70 ? 'High humidity' : 'Comfortable',
            ),
            _buildMetricTile(
              icon: Icons.air_rounded,
              label: 'Wind',
              value: '${current.windSpeed.round()} km/h',
              subtitle: 'Direction: ${WeatherHelper.getWindDirection(current.windDirection)}',
            ),
            _buildMetricTile(
              icon: Icons.grain_rounded,
              label: 'Precipitation',
              value: '${current.precipitation} mm',
              subtitle: current.precipitation > 0 ? 'Rain recorded' : 'No rain',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentAmber, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
