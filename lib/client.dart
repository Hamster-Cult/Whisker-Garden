// Currently uses app.py

import 'dart:convert'; // For json parsing
import 'package:http/http.dart' as http; // To connect to web server

// I'll probably need to update this so it's applicable to all db queries
class Album {
  final int exp;

  const Album({required this.exp});

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'exp': int exp, } => Album(
        exp: exp
      ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

// Get request data.json to get exp value
Future<Album> getEXP() async {
  var url = Uri.parse('http://127.0.0.1:8000/');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
      throw Exception('error'); // Make this a better error lmao
    }
}
