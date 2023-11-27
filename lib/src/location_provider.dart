import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:memo/api_key.dart'; // not in repo

final locationProvider = FutureProvider.autoDispose
    .family<http.Response, String>((ref, String query) async {
  final url =
      "https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(query)}&key=$apiKey&limit=5&no_annotations=1";
  // final url = '127.0.0.1:3000/';
  final response = await http.get(Uri.parse(url));
  return response;
});
