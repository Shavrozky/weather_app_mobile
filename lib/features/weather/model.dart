class GeoResult {
  final String name;
  final String country;
  final double lat;
  final double lon;

  GeoResult({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory GeoResult.fromJson(Map<String, dynamic> j) {
    return GeoResult(
      name: (j['name'] ?? '').toString(),
      country: (j['country'] ?? '').toString(),
      lat: (j['latitude'] as num).toDouble(),
      lon: (j['longitude'] as num).toDouble(),
    );
  }
}

class WeatherData {
  final double currentTemp;
  final double currentWind;
  final int weatherCode;
  final List<String> days; // ISO date strings
  final List<double> minTemps;
  final List<double> maxTemps;

  WeatherData({
    required this.currentTemp,
    required this.currentWind,
    required this.weatherCode,
    required this.days,
    required this.minTemps,
    required this.maxTemps,
  });
}
