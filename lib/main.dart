import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService weatherService = WeatherService();

  bool loading = true;
  String errorMessage = '';

  double temperature = 0;
  double humidity = 0;
  double windSpeed = 0;
  int weatherCode = 0;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final data = await weatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      final current = data['current'];

      setState(() {
        temperature = (current['temperature_2m'] as num).toDouble();
        humidity = (current['relative_humidity_2m'] as num).toDouble();
        windSpeed = (current['wind_speed_10m'] as num).toDouble();
        weatherCode = current['weather_code'] as int;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  String getWeatherText(int code) {
    if (code == 0) return 'Clear sky';
    if ([1, 2, 3].contains(code)) return 'Cloudy';
    if ([45, 48].contains(code)) return 'Fog';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67].contains(code)) return 'Rain';
    if ([71, 73, 75, 77].contains(code)) return 'Snow';
    if ([80, 81, 82].contains(code)) return 'Rain showers';
    if ([95, 96, 99].contains(code)) return 'Thunderstorm';

    return 'Unknown';
  }

  String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if ([1, 2, 3].contains(code)) return '☁️';
    if ([45, 48].contains(code)) return '🌫️';
    if ([51, 53, 55, 56, 57].contains(code)) return '🌦️';
    if ([61, 63, 65, 66, 67].contains(code)) return '🌧️';
    if ([71, 73, 75, 77].contains(code)) return '❄️';
    if ([80, 81, 82].contains(code)) return '🌦️';
    if ([95, 96, 99].contains(code)) return '⛈️';

    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: getWeather,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (loading)
              const SizedBox(
                height: 500,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage.isNotEmpty)
              _buildError()
            else
              _buildWeather(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          getWeatherIcon(weatherCode),
          style: const TextStyle(fontSize: 90),
        ),
        const SizedBox(height: 20),
        Text(
          '${temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 55,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          getWeatherText(weatherCode),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _infoCard(
                icon: '💧',
                title: 'Humidity',
                value: '${humidity.toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _infoCard(
                icon: '💨',
                title: 'Wind',
                value: '${windSpeed.toStringAsFixed(1)} km/h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: getWeather,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Weather'),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⚠️',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to get weather',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getWeather,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
