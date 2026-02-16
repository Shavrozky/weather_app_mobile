import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_controller.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final _ctrl = TextEditingController(text: 'Balikpapan');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String weatherCodeLabel(int code) {
    // Minimal mapping (you can expand later)
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Cloudy';
    if (code >= 45 && code <= 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Drizzle/Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Weather code $code';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => ref
                        .read(weatherControllerProvider.notifier)
                        .searchCity(v),
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => ref
                            .read(weatherControllerProvider.notifier)
                            .searchCity(_ctrl.text),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state.loading) const LinearProgressIndicator(),

            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],

            if (state.data != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.cityLabel ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.data!.currentTemp.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(weatherCodeLabel(state.data!.weatherCode)),
                          Text(
                            'Wind: ${state.data!.currentWind.toStringAsFixed(1)} km/h',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: state.data!.days.length,
                  itemBuilder: (context, i) {
                    final day = state.data!.days[i];
                    final minT = state.data!.minTemps[i];
                    final maxT = state.data!.maxTemps[i];

                    return ListTile(
                      title: Text(day),
                      subtitle: Text('Min: ${minT.toStringAsFixed(1)}°C'),
                      trailing: Text('Max: ${maxT.toStringAsFixed(1)}°C'),
                    );
                  },
                ),
              ),
            ] else ...[
              const Spacer(),
              const Text('Search a city to see the forecast.'),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}
