import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'globals.dart';

class AuthServices {
  static Future<http.Response> register(String nom_agence, String email,
      String password, String confirm_pass, String adresse, int code_agence,
      String num_tel, String matri_fisc) async {
    Map<String, dynamic> data = {
      "nom_agence": nom_agence,
      "code_agence": code_agence,
      "adresse": adresse,
      "num_tel": num_tel,
      "matri_fisc": matri_fisc,
      "email": email,
      "password": password,
      "confirm_pass": confirm_pass,
    };
    var body = jsonEncode(data);
    var url = Uri.parse(baseURL + 'auth/register');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);
    return response;
  }

// variable pour stocke token wel Auto_école id
  static final storage = new FlutterSecureStorage();

  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'auth/login');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.body);

    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];
      int userId = json.decode(response.body)['user_id'];
      final storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'user_id', value: userId.toString());
    }

    return response;
  }

}