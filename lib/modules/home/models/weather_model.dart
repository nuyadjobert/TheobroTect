class WeatherModel {
  final String city;
  final double temperature;
  final String condition;
  final bool isRainy;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.isRainy,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final mainCondition = json['weather'][0]['main'];

    return WeatherModel(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: mainCondition,
      isRainy: mainCondition == 'Rain' || mainCondition == 'Thunderstorm',
    );
  }
}
