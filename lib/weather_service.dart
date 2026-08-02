import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Search a city and return latitude/longitude
  Future<Map<String, dynamic>> searchCity(String city) async {
    final url = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': city.trim(),
        'count': '1',
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('City search status: ${response.statusCode}');
      print('City search response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'City search failed (${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body);

      if (data['results'] == null ||
          data['results'] is! List ||
          data['results'].isEmpty) {
        throw Exception('City not found');
      }

      return Map<String, dynamic>.from(data['results'][0]);
    } catch (e) {
      print('City search error: $e');
      rethrow;
    }
  }

  // Get current + 7-day weather
  Future<Map<String, dynamic>> getWeather(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
            'precipitation_probability_max,sunrise,sunset',
        'timezone': 'auto',
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Weather status: ${response.statusCode}');
      print('Weather response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }

        throw Exception('Invalid weather data received');
      }

      throw Exception(
        'Weather request failed (${response.statusCode})',
      );
    } catch (e) {
      print('Weather error: $e');
      rethrow;
    }
  }
}
