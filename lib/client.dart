// Currently uses app.py
import 'dart:convert'; // For json parsing
import 'package:http/http.dart' as http; // To connect to web server


Future<Map<String, dynamic>> getData(String path) async {
  var url = Uri.parse('http://127.0.0.1:8000/$path');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
      throw Exception('error'); // Make this a better error lmao
    }
}