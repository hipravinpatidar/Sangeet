import 'dart:convert';
import 'package:http/http.dart' as https;

class ApiService {
  // Category API
  Future<Map<String, dynamic>> getCategory(String url) async {
    final response = await https.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return jsonBody;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // SubCategory API
  Future getSubCategory(String url) async {
    final response = await https.get(Uri.parse(url));
    final jsonBody = jsonDecode(response.body);
    return jsonBody;
  }

  // Sangeet API
  Future fetchSangeetData(String url) async {
    final response = await https.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody;
    } else {
      throw Exception('Failed to load sangeet data');
    }
  }

  // All Ctegory API
  Future getAllCategory(String url) async {
    final response = await https.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody;
    } else {
      throw Exception('Failed to load All Category');
    }
  }

  // Language API
  Future getLanguage(String url) async {
    final response = await https.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody;
    }
  }
}
