import 'dart:convert';

class FilterUtils {
  /// Updates or adds a filter in the given filters list.
  ///
  static String encodeFilter(List<Map<String, dynamic>> filter) {
    return jsonEncode(filter);
  }

  static void updateFilters(
    List<Map<String, dynamic>> filter,
    List<Map<String, dynamic>> newEntries,
  ) {
    for (var entry in newEntries) {
      // Ignore null values

      String key = entry.keys.first;
      dynamic value = entry.values.first;

      bool keyExists = false;

      for (var map in filter) {
        if (map.containsKey(key)) {
          if (value == null ||
              (value is String && value.isEmpty) ||
              (value is List && value.isEmpty)) {
            filter.remove(map); // Remove entry if value is empty or empty array
          } else {
            map[key] = value; // Update existing value
          }
          keyExists = true;
          break;
        }
      }

      if (!keyExists) {
        filter.add({key: value}); // Add new entry
      }
    }
  }
}
