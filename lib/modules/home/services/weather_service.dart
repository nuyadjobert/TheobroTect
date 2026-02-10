import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // Replace with your API key after it activates
  static const String _apiKey = '5dc5ca58bd8a7e031cf12b4fc49d3009';

  Future<WeatherModel> fetchWeatherByCity(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      print('Failed response: ${response.body}');
      throw Exception('Failed to load weather');
    }
  }
}
