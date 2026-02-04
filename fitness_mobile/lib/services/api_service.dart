import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    // Web-ben a jelenlegi host-ot használja, egyébként az IP-t
    if (html.window.location.origin.contains('localhost')) {
      return 'http://192.168.1.64:8080/api';
    }
    return 'http://192.168.1.64:8080/api';
  }

  static Future<List<dynamic>> getWods() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/wods'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) ?? [];
      } else {
        throw Exception('Hiba a WOD-ok lekérésekor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // WOD részletei
  static Future<dynamic> getWodDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wods/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a WOD lekérésekor');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // Felhasználó adatai
  static Future<dynamic> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a profil lekérésekor');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // Workout logolása
  static Future<dynamic> logWorkout(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a workout logolása során');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // WOD generálás (csak generálás, mentés nélkül)
  static Future<dynamic> generateWod(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wods/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a WOD generálása során: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // WOD generálás és mentés
  static Future<dynamic> generateAndSaveWod(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wods/generate-and-save'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a WOD mentése során');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }

  // Workout результат mentése
  static Future<dynamic> saveWorkoutResult(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wod-results'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hiba a workout mentése során: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hiba: $e');
    }
  }
}
