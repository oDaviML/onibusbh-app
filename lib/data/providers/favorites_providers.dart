import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/line_summary_dto.dart';
import '../models/stop_dto.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(sharedPreferencesProvider));
});

final favoriteLinesProvider =
    NotifierProvider<FavoriteLinesNotifier, List<LineSummaryDto>>(() {
      return FavoriteLinesNotifier();
    });

final favoriteStopsProvider =
    NotifierProvider<FavoriteStopsNotifier, List<StopDto>>(() {
      return FavoriteStopsNotifier();
    });

class FavoritesRepository {
  final SharedPreferences _prefs;
  static const _linesKey = 'favorite_lines_v1';
  static const _stopsKey = 'favorite_stops_v1';

  FavoritesRepository(this._prefs);

  List<LineSummaryDto> getFavoriteLines() {
    final list = _prefs.getStringList(_linesKey) ?? [];
    return list
        .map((jsonStr) => LineSummaryDto.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveFavoriteLines(List<LineSummaryDto> lines) async {
    final list = lines.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_linesKey, list);
  }

  List<StopDto> getFavoriteStops() {
    final list = _prefs.getStringList(_stopsKey) ?? [];
    return list
        .map((jsonStr) => StopDto.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveFavoriteStops(List<StopDto> stops) async {
    final list = stops.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_stopsKey, list);
  }
}

class FavoriteLinesNotifier extends Notifier<List<LineSummaryDto>> {
  @override
  List<LineSummaryDto> build() {
    return ref.watch(favoritesRepositoryProvider).getFavoriteLines();
  }

  void toggleFavorite(LineSummaryDto line) {
    if (isFavorite(line.routeId)) {
      state = state.where((e) => e.routeId != line.routeId).toList();
    } else {
      state = [...state, line];
    }
    ref.read(favoritesRepositoryProvider).saveFavoriteLines(state);
  }

  bool isFavorite(String routeId) => state.any((e) => e.routeId == routeId);
}

class FavoriteStopsNotifier extends Notifier<List<StopDto>> {
  @override
  List<StopDto> build() {
    return ref.watch(favoritesRepositoryProvider).getFavoriteStops();
  }

  void toggleFavorite(StopDto stop) {
    if (isFavorite(stop.id)) {
      state = state.where((e) => e.id != stop.id).toList();
    } else {
      state = [...state, stop];
    }
    ref.read(favoritesRepositoryProvider).saveFavoriteStops(state);
  }

  bool isFavorite(String stopId) => state.any((e) => e.id == stopId);
}
