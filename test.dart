
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var response = await http.post(
    Uri.parse('https://kvdewjfidrbktwapphph.supabase.co/rest/v1/rides'),
    headers: {
      'apikey': 'sb_publishable_LSbKgmKQJpuS06wkKOIrNQ_N9oxMP9e',
      'Authorization': 'Bearer sb_publishable_LSbKgmKQJpuS06wkKOIrNQ_N9oxMP9e',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: jsonEncode({
      'customer_id': 1,
      'status': 'test',
      'pickup_lat': 10.0
    })
  );
  print(response.statusCode);
  print(response.body);
}

