import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'open_meteo_api.dart';
import 'model.dart';

final apiProvider = Provider((ref) => OpenMeteoApi());

class WeatherState {
  final bool loading;
  final String? error;
  final String? cityLabel;
  final WeatherData? data;

  const WeatherState({
    this.loading = false,
    this.error,
    this.cityLabel,
    this.data,
  });

  WeatherState copyWith({
    bool? loading,
    String? error,
    String? cityLabel,
    WeatherData? data,
  }) {
    return WeatherState(
      loading: loading ?? this.loading,
      error: error,
      cityLabel: cityLabel ?? this.cityLabel,
      data: data ?? this.data,
    );
  }
}

class WeatherController extends StateNotifier<WeatherState> {
  WeatherController(this._api) : super(const WeatherState());

  final OpenMeteoApi _api;

  Future<void> searchCity(String city) async {
    final q = city.trim();
    if (q.isEmpty) return;

    state = state.copyWith(loading: true, error: null);

    try {
      final geo = await _api.geocodeCity(q);
      final weather = await _api.fetchForecast(lat: geo.lat, lon: geo.lon);

      state = WeatherState(
        loading: false,
        cityLabel: '${geo.name}, ${geo.country}',
        data: weather,
      );
    } catch (e) {
      state = WeatherState(loading: false, error: e.toString());
    }
  }
}

final weatherControllerProvider =
    StateNotifierProvider<WeatherController, WeatherState>(
      (ref) => WeatherController(ref.read(apiProvider)),
    );
