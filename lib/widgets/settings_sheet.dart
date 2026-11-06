import 'package:flutter/material.dart';
import '../services/weather_service.dart' if (dart.library.io) '../weather_service.dart';
import '../utils/app_colors.dart';

class SettingsSheet extends StatefulWidget {
  final WeatherService weatherService;
  final bool isFahrenheit;
  final ValueChanged<bool> onUnitChanged;
  final VoidCallback onCacheCleared;

  const SettingsSheet({
    super.key,
    required this.weatherService,
    required this.isFahrenheit,
    required this.onUnitChanged,
    required this.onCacheCleared,
  });

  static Future<void> show({
    required BuildContext context,
    required WeatherService weatherService,
    required bool isFahrenheit,
    required ValueChanged<bool> onUnitChanged,
    required VoidCallback onCacheCleared,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SettingsSheet(
        weatherService: weatherService,
        isFahrenheit: isFahrenheit,
        onUnitChanged: onUnitChanged,
        onCacheCleared: onCacheCleared,
      ),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _isFahrenheit;

  @override
  void initState() {
    super.initState();
    _isFahrenheit = widget.isFahrenheit;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Settings & Preferences',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Temperature Unit Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.thermostat, color: AppColors.accentAmber),
                    SizedBox(width: 12),
                    Text(
                      'Temperature Unit',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _isFahrenheit ? '°F' : '°C',
                      style: const TextStyle(
                        color: AppColors.accentAmber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isFahrenheit,
                      activeColor: AppColors.accentAmber,
                      onChanged: (val) async {
                        setState(() => _isFahrenheit = val);
                        await widget.weatherService.setFahrenheit(val);
                        widget.onUnitChanged(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Clear Cache Option
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text(
                'Clear Weather Cache',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
              subtitle: const Text(
                'Removes stored offline weather data',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () {
                  widget.onCacheCleared();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weather cache refreshed!'),
                      backgroundColor: AppColors.cardHighlight,
                    ),
                  );
                },
                child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attribution
          const Center(
            child: Text(
              'Weather data provided by Open-Meteo API\nFlutter Weather App v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
