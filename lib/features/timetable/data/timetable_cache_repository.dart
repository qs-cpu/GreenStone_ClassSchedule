import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_provider.dart';
import '../domain/timetable.dart';

final timetableCacheRepositoryProvider = Provider<TimetableCacheRepository>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TimetableCacheRepository(prefs);
});

class TimetableCacheRepository {
  TimetableCacheRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'offline_timetable';
  static const _listKey = '$_prefix:list';
  static const _selectedIdKey = '$_prefix:selected_id';
  static const _updatedAtKey = '$_prefix:updated_at';

  String _detailKey(String id) => '$_prefix:detail:$id';

  String? getSelectedTimetableId() => _prefs.getString(_selectedIdKey);

  DateTime? getUpdatedAt() {
    final value = _prefs.getString(_updatedAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> setSelectedTimetableId(String? id) async {
    if (id == null || id.isEmpty) {
      await _prefs.remove(_selectedIdKey);
      return;
    }
    await _prefs.setString(_selectedIdKey, id);
  }

  List<Timetable> getTimetables() {
    final raw = _prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((item) => Timetable.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Timetable? getTimetableDetail(String id) {
    final raw = _prefs.getString(_detailKey(id));
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Timetable.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> cacheTimetables(List<Timetable> timetables) async {
    final sorted = [...timetables]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _prefs.setString(
      _listKey,
      jsonEncode(sorted.map((timetable) => timetable.toJson()).toList()),
    );
    await _touch();
  }

  Future<void> cacheTimetableDetail(Timetable timetable) async {
    await _prefs.setString(
      _detailKey(timetable.id),
      jsonEncode(timetable.toJson()),
    );
    await _upsertListItem(timetable);
    await _touch();
  }

  Future<void> _upsertListItem(Timetable timetable) async {
    final list = getTimetables();
    final index = list.indexWhere((item) => item.id == timetable.id);
    final summary = timetable.copyWith(courses: const []);

    if (index >= 0) {
      list[index] = summary;
    } else {
      list.add(summary);
    }
    await cacheTimetables(list);
  }

  Future<void> _touch() async {
    await _prefs.setString(_updatedAtKey, DateTime.now().toIso8601String());
  }
}
