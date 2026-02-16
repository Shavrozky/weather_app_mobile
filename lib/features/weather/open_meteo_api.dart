import '../../core/dio_client.dart';
import 'model.dart';

class OpenMeteoApi {
  // Geocoding (search city -> lat/lon)
  Future<GeoResult> geocodeCity(String city) async {
    final r = await dio.get(
      'https://geocoding-api.open-meteo.com/v1/search',
      queryParameters: {
        'name': city,
        'count': 1,
        'language': 'en',
        'format': 'json',
      },
    );

    final data = r.data as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? [];
    if (results.isEmpty) {
      throw Exception('City not found: $city');
    }
    return GeoResult.fromJson(results.first as Map<String, dynamic>);
  }

  // Forecast (current + daily)
  Future<WeatherData> fetchForecast({
    required double lat,
    required double lon,
  }) async {
    final r = await dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      },
    );

    final m = r.data as Map<String, dynamic>;
    final current = m['current'] as Map<String, dynamic>;
    final daily = m['daily'] as Map<String, dynamic>;

    final days = (daily['time'] as List).map((e) => e.toString()).toList();
    final maxTemps = (daily['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (daily['temperature_2m_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return WeatherData(
      currentTemp: (current['temperature_2m'] as num).toDouble(),
      currentWind: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      days: days,
      minTemps: minTemps,
      maxTemps: maxTemps,
    );
  }
}
