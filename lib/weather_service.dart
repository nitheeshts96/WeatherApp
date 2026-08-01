import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Search a city and return latitude/longitude
  Future<Map<String, dynamic>> searchCity(String city) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}'
      '&count=1'
      '&language=en'
      '&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Unable to search city');
    }

    final data = jsonDecode(response.body);

    if (data['results'] == null || data['results'].isEmpty) {
      throw Exception('City not found');
    }

    return data['results'][0];
  }

  // Get current + 7-day weather
  Future<Map<String, dynamic>> getWeather(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max,sunrise,sunset'
      '&timezone=auto',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load weather');
  }
}
