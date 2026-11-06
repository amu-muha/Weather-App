import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart' if (dart.library.io) '../weather_service.dart';
import '../utils/app_colors.dart';

class CitySearchSheet extends StatefulWidget {
  final WeatherService weatherService;
  final ValueChanged<LocationModel> onLocationSelected;

  const CitySearchSheet({
    super.key,
    required this.weatherService,
    required this.onLocationSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required WeatherService weatherService,
    required ValueChanged<LocationModel> onLocationSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => CitySearchSheet(
        weatherService: weatherService,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<LocationModel> _results = [];
  bool _isLoading = false;

  static const List<LocationModel> _quickCities = [
    LocationModel(name: 'Addis Ababa', country: 'Ethiopia', latitude: 8.9806, longitude: 38.7578),
    LocationModel(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
    LocationModel(name: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060),
    LocationModel(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503),
    LocationModel(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
    LocationModel(name: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isLoading = true);
      final list = await widget.weatherService.searchCities(query);
      if (mounted) {
        setState(() {
          _results = list;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
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
            'Search City',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Type city name (e.g. Nairobi, Berlin)...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.accentAmber),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.accentAmber),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: CircularProgressIndicator(color: AppColors.accentAmber),
              ),
            )
          else if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.borderLight,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final loc = _results[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: const Icon(Icons.location_on, color: AppColors.accentAmber),
                    title: Text(loc.name, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(
                      loc.displayName,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    onTap: () {
                      widget.onLocationSelected(loc);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            )
          else if (_controller.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text('No cities found', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else ...[
            const Text(
              'Popular Cities',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickCities.map((city) {
                return ActionChip(
                  label: Text(city.name),
                  labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  backgroundColor: AppColors.cardHighlight,
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () {
                    widget.onLocationSelected(city);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

