import 'dart:async';
import 'package:flutter/material.dart';
import 'weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  late Future<List<Map<String, dynamic>>> _historyFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer for 5-minute auto-refresh
  Timer? _fiveMinTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Trigger auto-refresh every 5 minutes
    _fiveMinTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _fetchData(),
    );
  }

  @override
  void dispose() {
    _fiveMinTimer?.cancel();
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      _historyFuture = _weatherService.fetchWeatherHistory();
    });
  }

  /// Map Open-Meteo WMO weather codes to asset image path
  String _getWeatherAssetImage(int weatherCode, double temp) {
    if (weatherCode >= 51 && weatherCode <= 65 || weatherCode >= 80) {
      return 'assets/images/rainy.png';
    } else if (weatherCode >= 95) {
      return 'assets/images/thunderstorm.png';
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      return 'assets/images/cloudy.png';
    }

    if (temp < 15.0) {
      return 'assets/images/cold.png';
    } else if (temp > 28.0) {
      return 'assets/images/hot.png';
    }

    return 'assets/images/sunny.png';
  }

  /// Map WMO weather code to readable summary text
  String _getWeatherSummary(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear skies today.';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy conditions.';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'Expect high rain today.';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorms expected.';
      default:
        return 'Mild weather today.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D0E15),

      // Left Drawer
      drawer: Drawer(
        backgroundColor: const Color(0xFF161824),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0D0E15)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text('Addis Ababa', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),

      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Column(
          children: [
            Text(
              'Addis Ababa, Ethiopia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),

      // Body Content
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amberAccent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white38, size: 50),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final historyList = snapshot.data!;
            final currentNowData = historyList.last;
            final current = currentNowData['current'];
            final units = currentNowData['current_units'];

            final double temp = (current['temperature_2m'] as num).toDouble();
            final int weatherCode = (current['weather_code'] as num).toInt();
            final String imagePath = _getWeatherAssetImage(weatherCode, temp);
            final String summary = _getWeatherSummary(weatherCode);

            return Stack(
              children: [
                // 1. Ambient Background Lighting
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(0.22),
                            Colors.orangeAccent.withOpacity(0.08),
                            Colors.transparent,
                          ],
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Main Scrollable Interface
                RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  color: Colors.amber,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Dynamic 3D Graphic
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.wb_sunny_rounded,
                              size: 130,
                              color: Colors.amber,
                            ),
                          ),
                        ),

                        // Main Temperature
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${temp.round()}',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              '° C',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Summary Text
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Inline Quick Metrics Bar (Wind | Humidity | Precipitation)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInlineStat(
                              icon: Icons.air_rounded,
                              label: '${current['wind_speed_10m']}${units['wind_speed_10m']}',
                            ),
                            _buildInlineStat(
                              icon: Icons.water_drop_outlined,
                              label: '${current['relative_humidity_2m']}${units['relative_humidity_2m']}',
                            ),
                            _buildInlineStat(
                              icon: Icons.wb_sunny_outlined,
                              label: '${current['precipitation']}${units['precipitation']}',
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // Section Header: Hourly Forecast
                        const Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Hourly Forecast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 5 Timeline Horizontal Cards
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(historyList.length, (index) {
                              final cardData = historyList[index];
                              final bool isNowCard = (index == historyList.length - 1);
                              final cardTemp = (cardData['current']['temperature_2m'] as num).round();
                              final cardCode = (cardData['current']['weather_code'] as num).toInt();
                              final cardImagePath = _getWeatherAssetImage(cardCode, cardTemp.toDouble());
                              final timeLabel = isNowCard
                                  ? 'Now'
                                  : (cardData['timestamp_label'] ?? '-${(historyList.length - 1 - index) * 30}m');

                              return Container(
                                width: 95,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isNowCard ? const Color(0xFF1E2235) : const Color(0xFF161824),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isNowCard ? Colors.white.withOpacity(0.3) : Colors.white10,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 42,
                                      width: 42,
                                      child: Image.asset(
                                        cardImagePath,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.wb_sunny,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      timeLabel,
                                      style: TextStyle(
                                        color: isNowCard ? Colors.white : Colors.white54,
                                        fontWeight: isNowCard ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$cardTemp°',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data found', style: TextStyle(color: Colors.white)));
        },
      ),

      // Floating Bottom Navigation Pill Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C29).withOpacity(0.9),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              icon: const Icon(Icons.search_rounded, color: Colors.white38, size: 24),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white38, size: 24),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.white38, size: 24),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineStat({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}