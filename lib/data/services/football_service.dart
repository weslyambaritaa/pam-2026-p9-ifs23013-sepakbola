import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class FootballService {
  static Future<Map<String, dynamic>> getFootballs(int page) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.footballs}?page=$page&per_page=10"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load football clubs");
    }
  }

  static Future<void> generateFootballs(String league, int total) async {
    final response = await http.post(
      Uri.parse(ApiConstants.generate),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "league": league,
        "total": total
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate");
    }
  }
}