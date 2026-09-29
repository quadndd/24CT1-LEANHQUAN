import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = '382 Trưng nữ Vương';
  final apiKey = 'AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao';
  String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&region=vn&key=$apiKey';
  final response = await http.get(Uri.parse(url));
  print('Status: \');
  print('Body: \');
}
