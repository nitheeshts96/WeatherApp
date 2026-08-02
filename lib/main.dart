import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';
import 'about_page.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
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
  final TextEditingController searchController = TextEditingController();

  bool loading = true;

  String errorMessage = '';
  String cityName = 'My Location';

  double temperature = 0;
  double humidity = 0;
  double windSpeed = 0;

  int weatherCode = 0;

  List<dynamic> daily = [];

  String sunrise = '';
  String sunset = '';

  @override
  void initState() {
    super.initState();
    getCurrentLocationWeather();
  }

  // -----------------------------
  // CURRENT LOCATION
  // -----------------------------

  Future<void> getCurrentLocationWeather() async {
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

      await loadWeather(
        position.latitude,
        position.longitude,
        'My Location',
      );
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // -----------------------------
  // SEARCH CITY
  // -----------------------------

  Future<void> searchWeather() async {
    final city = searchController.text.trim();

    if (city.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final location = await weatherService.searchCity(city);

      final latitude = (location['latitude'] as num).toDouble();
      final longitude = (location['longitude'] as num).toDouble();

      final name = location['name'] ?? city;

      await loadWeather(
        latitude,
        longitude,
        name,
      );
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'City not found';
      });
    }
  }

  // -----------------------------
  // LOAD WEATHER
  // -----------------------------

  Future<void> loadWeather(
    double latitude,
    double longitude,
    String locationName,
  ) async {
    try {
      final data = await weatherService.getWeather(
        latitude,
        longitude,
      );

      final current = data['current'];
      final dailyData = data['daily'];

      setState(() {
        cityName = locationName;

        temperature = (current['temperature_2m'] as num).toDouble();

        humidity = (current['relative_humidity_2m'] as num).toDouble();

        windSpeed = (current['wind_speed_10m'] as num).toDouble();

        weatherCode = current['weather_code'] as int;

        daily = List.from(
          List.generate(
            dailyData['time'].length,
            (index) => {
              'date': dailyData['time'][index],
              'code': dailyData['weather_code'][index],
              'max': dailyData['temperature_2m_max'][index],
              'min': dailyData['temperature_2m_min'][index],
              'rain': dailyData['precipitation_probability_max'][index],
              'sunrise': dailyData['sunrise'][index],
              'sunset': dailyData['sunset'][index],
            },
          ),
        );

        if (daily.isNotEmpty) {
          sunrise = formatTime(daily[0]['sunrise']);
          sunset = formatTime(daily[0]['sunset']);
        }

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Unable to load weather';
      });
    }
  }

  // -----------------------------
  // WEATHER DESCRIPTION
  // -----------------------------

  String getWeatherText(int code) {
    if (code == 0) return 'Clear sky';

    if ([1, 2, 3].contains(code)) {
      return 'Cloudy';
    }

    if ([45, 48].contains(code)) {
      return 'Fog';
    }

    if ([51, 53, 55, 56, 57].contains(code)) {
      return 'Drizzle';
    }

    if ([61, 63, 65, 66, 67].contains(code)) {
      return 'Rain';
    }

    if ([71, 73, 75, 77].contains(code)) {
      return 'Snow';
    }

    if ([80, 81, 82].contains(code)) {
      return 'Rain showers';
    }

    if ([95, 96, 99].contains(code)) {
      return 'Thunderstorm';
    }

    return 'Unknown';
  }

  String getWeatherIcon(int code) {
    if (code == 0) return '☀️';

    if ([1, 2, 3].contains(code)) {
      return '☁️';
    }

    if ([45, 48].contains(code)) {
      return '🌫️';
    }

    if ([51, 53, 55, 56, 57].contains(code)) {
      return '🌦️';
    }

    if ([61, 63, 65, 66, 67].contains(code)) {
      return '🌧️';
    }

    if ([71, 73, 75, 77].contains(code)) {
      return '❄️';
    }

    if ([80, 81, 82].contains(code)) {
      return '🌦️';
    }

    if ([95, 96, 99].contains(code)) {
      return '⛈️';
    }

    return '🌤️';
  }

  // -----------------------------
  // FORMAT DATE
  // -----------------------------

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[parsed.weekday - 1];
  }

  String formatTime(String value) {
    final date = DateTime.parse(value);

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  // -----------------------------
  // UI
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: getCurrentLocationWeather,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      searchWeather();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: getCurrentLocationWeather,
                  icon: const Icon(
                    Icons.my_location,
                  ),
                  tooltip: 'Current location',
                ),
              ],
            ),

            const SizedBox(height: 20),

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

  // -----------------------------
  // WEATHER UI
  // -----------------------------

  Widget _buildWeather() {
    return Column(
      children: [
        Text(
          cityName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        Text(
          getWeatherIcon(weatherCode),
          style: const TextStyle(
            fontSize: 85,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          '${temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 55,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          getWeatherText(weatherCode),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),

        const SizedBox(height: 30),

        // INFO CARDS

        Row(
          children: [
            Expanded(
              child: _infoCard(
                '💧',
                'Humidity',
                '${humidity.toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                '💨',
                'Wind',
                '${windSpeed.toStringAsFixed(1)} km/h',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // SUNRISE / SUNSET

        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      '🌅',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('Sunrise'),
                    Text(
                      sunrise,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      '🌇',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('Sunset'),
                    Text(
                      sunset,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        ...daily.map(
          (day) => _forecastCard(day),
        ),
      ],
    );
  }

  // -----------------------------
  // INFO CARD
  // -----------------------------

  Widget _infoCard(
    String icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 5),
            Text(title),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // FORECAST CARD
  // -----------------------------

  Widget _forecastCard(
    Map<String, dynamic> day,
  ) {
    final code = day['code'] as int;

    final max = (day['max'] as num).toDouble();

    final min = (day['min'] as num).toDouble();

    final rain = day['rain'] as num;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 45,
              child: Text(
                formatDate(day['date']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              getWeatherIcon(code),
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                getWeatherText(code),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${max.toStringAsFixed(0)}° / '
                  '${min.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '🌧️ $rain%',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // ERROR
  // -----------------------------

  Widget _buildError() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⚠️',
              style: TextStyle(
                fontSize: 60,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getCurrentLocationWeather,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
