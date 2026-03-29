import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:practice_app/services/api_config.dart';

Future<String?> uploadImage(File file) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConfig.baseUrl}/upload"),
    );

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      print(res.body);

      return res.body; // example: "/uploads/xyz.png"
    }
  } catch (e) {
    print("Upload error: $e");
  }

  return null;
}
