import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static Future<List<LocationSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SchedlyApp/1.0',
        },
      );

      if (response.statusCode != 200) return [];

      final List data = jsonDecode(response.body);

      return data.map((item) {
        return LocationSuggestion(
          displayName: item['display_name'],
          latitude: double.parse(item['lat']),
          longitude: double.parse(item['lon']),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}