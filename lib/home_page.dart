import 'dart:async';
import 'package:flutter/material.dart';
import 'models/location_model.dart';
import 'models/weather_models.dart';
import 'utils/app_colors.dart';
import 'utils/weather_helper.dart';
import 'weather_service.dart';
import 'widgets/city_search_sheet.dart';
import 'widgets/daily_forecast_view.dart';
import 'widgets/hourly_forecast_view.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/weather_metrics_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<WeatherData> _weatherFuture;
  LocationModel _currentLocation = LocationModel.defaultLocation;
  bool _isFahrenheit = false;
  Timer? _fiveMinTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // Auto-refresh weather every 5 minutes
    _fiveMinTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _refreshWeather(),
    );
  }

  @override
  void dispose() {
    _fiveMinTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final savedLoc = await _weatherService.getSavedLocation();
    final isFahr = await _weatherService.isFahrenheit();

    if (mounted) {
      setState(() {
        _currentLocation = savedLoc;
        _isFahrenheit = isFahr;
        _weatherFuture = _weatherService.getWeatherData(location: savedLoc);
      });
    }
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _weatherService.getWeatherData(
        location: _currentLocation,
        forceRefresh: true,
      );
    });
  }

  void _onLocationSelected(LocationModel location) {
    setState(() {
      _currentLocation = location;
      _weatherFuture = _weatherService.getWeatherData(location: location, forceRefresh: true);
    });
    _weatherService.saveSelectedLocation(location);
  }

  void _openCitySearch() {
    CitySearchSheet.show(
      context: context,
      weatherService: _weatherService,
      onLocationSelected: _onLocationSelected,
    );
  }

  void _openSettings() {
    SettingsSheet.show(
      context: context,
      weatherService: _weatherService,
      isFahrenheit: _isFahrenheit,
      onUnitChanged: (val) {
        setState(() => _isFahrenheit = val);
      },
      onCacheCleared: _refreshWeather,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,

      // Left Drawer
      drawer: Drawer(
        backgroundColor: AppColors.cardDark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.background),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wb_sunny_rounded, color: AppColors.accentAmber, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Weather Forecast',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentLocation.displayName,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
              title: const Text('Search City', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _openCitySearch();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
              title: const Text('Refresh Data', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _refreshWeather();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
              title: const Text('Settings & Units', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
            const Divider(color: AppColors.borderLight),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.textMuted),
              title: const Text('Powered by Open-Meteo', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
          ],
        ),
      ),

      // Custom AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notes_rounded, color: AppColors.textPrimary, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openCitySearch,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: AppColors.accentAmber, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _currentLocation.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: _openCitySearch,
          ),
        ],
      ),

      // Main Body
      body: FutureBuilder<WeatherData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentAmber),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load weather',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardHighlight,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: _refreshWeather,
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final weather = snapshot.data!;
            final current = weather.current;
            final double tempValue = _isFahrenheit
                ? WeatherHelper.toFahrenheit(current.temperature)
                : current.temperature;
            final String imagePath = WeatherHelper.getWeatherAssetImage(
              current.weatherCode,
              isDay: current.isDay,
            );
            final String summary = WeatherHelper.getWeatherSummary(current.weatherCode);

            return Stack(
              children: [
                // Ambient Background Lighting Glow
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.ambientSunGlow,
                      ),
                    ),
                  ),
                ),

                // Main Content
                RefreshIndicator(
                  onRefresh: () async => _refreshWeather(),
                  color: AppColors.accentAmber,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Dynamic Weather Graphic
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.wb_sunny_rounded,
                              size: 130,
                              color: AppColors.accentAmber,
                            ),
                          ),
                        ),

                        // Main Temperature Display
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tempValue.round()}',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              _isFahrenheit ? '° F' : '° C',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        // Summary description
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quick Inline Stats Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInlineStat(
                              icon: Icons.air_rounded,
                              label: '${current.windSpeed.round()} km/h',
                            ),
                            _buildInlineStat(
                              icon: Icons.water_drop_outlined,
                              label: '${current.relativeHumidity}%',
                            ),
                            _buildInlineStat(
                              icon: Icons.grain_rounded,
                              label: '${current.precipitation} mm',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 24-Hour Forecast Horizontal View
                        HourlyForecastView(
                          hourly: weather.hourly,
                          isFahrenheit: _isFahrenheit,
                        ),

                        const SizedBox(height: 28),

                        // Weather Metrics Grid (Feels like, wind, humidity, precipitation)
                        WeatherMetricsGrid(
                          current: current,
                          isFahrenheit: _isFahrenheit,
                        ),

                        const SizedBox(height: 28),

                        // 7-Day Extended Forecast Breakdown
                        DailyForecastView(
                          daily: weather.daily,
                          isFahrenheit: _isFahrenheit,
                        ),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No weather data found', style: TextStyle(color: AppColors.textPrimary)),
          );
        },
      ),

      // Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.navBar.withOpacity(0.92),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.home_rounded, color: Color(0xFF0D0E15), size: 22),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 24),
              onPressed: _openCitySearch,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 24),
              onPressed: _refreshWeather,
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 24),
              onPressed: _openSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineStat({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
