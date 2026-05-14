import 'package:weather_app1/domain/repositories/weather_repository.dart';

/// Normalizes user input for cache keys and API `q` parameters.
abstract final class SearchQueryNormalizer {
  static String normalize(String raw) {
    String s = raw.trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }
}

/// Ranks [CitySuggestion] for display. Does **not** drop API rows (avoids empty
/// lists when the backend matched differently than a naive substring filter).
abstract final class CitySuggestionRanker {
  static List<CitySuggestion> sort(
    List<CitySuggestion> items,
    String rawQuery,
  ) {
    final String q = SearchQueryNormalizer.normalize(rawQuery).toLowerCase();
    if (q.isEmpty) {
      return List<CitySuggestion>.from(items);
    }
    final List<CitySuggestion> copy = List<CitySuggestion>.from(items);
    copy.sort((CitySuggestion a, CitySuggestion b) {
      final int cmp = _score(a, q).compareTo(_score(b, q));
      if (cmp != 0) {
        return cmp;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  /// Lower is better.
  static int _score(CitySuggestion c, String q) {
    final String name = c.name.toLowerCase();
    final String haystack = c.searchHaystack.toLowerCase();
    if (name == q) {
      return 0;
    }
    if (name.startsWith(q)) {
      return 1;
    }
    if (haystack.startsWith(q)) {
      return 2;
    }
    if (name.contains(q)) {
      return 3;
    }
    if (haystack.contains(q)) {
      return 4;
    }
    return 5;
  }
}
