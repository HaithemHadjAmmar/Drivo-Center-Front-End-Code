import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Services/globals.dart';




//select Candidat

Future<List<dynamic>> getPack() async {
    var url = Uri.parse(baseURL + 'get/pack');
    http.Response response = await http.get(
     url,
     headers: headers,
    );
     print(response.body);
     return jsonDecode(response.body);
}
