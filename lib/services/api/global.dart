import 'dart:convert';

import 'package:booksum/services/interfaces/global.dart';
import 'package:http/http.dart' as http;

class ApiConnectionClient<T> implements ConnectionClient<T> {
  final String apiUrl;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  ApiConnectionClient(this.apiUrl,
      {required this.fromMap, required this.toMap});

  @override
  Future<void> writeMany(List<T> items) async {
    await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(items.map(toMap).toList()),
    );
  }

  @override
  Future<List<T>> readMany() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return List<T>.from(jsonDecode(response.body).map(fromMap));
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }
}
