import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<void> savePlate(String plateNumber, String details) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/save'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'plate_number': plateNumber,
        'details': details,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save plate');
    }
  }

  static Future<Map<String, dynamic>> matchPlate(String plateNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/match'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'plate_number': plateNumber,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to match plate');
    }
  }
}
