import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../Services/globals.dart';
import '../Screens/login_screen.dart';
import 'User.dart';

class UserServices {


 // Update Auto école by id
 static Future<int> updateUserById(
     int id,
     String nomAgence,
     String codeAgence,
     String email,
     String adresse,
     String numTel,
     String matriFisc,
     ) async {
  final url = Uri.parse(baseURL + 'update/user/$id');
  final headers = {
   'Content-Type': 'application/json',
  };
  final data = {
   "nomAgence": nomAgence,
   "codeAgence": codeAgence,
   "email": email,
   "adresse": adresse,
   "numTel": numTel,
   "matriFisc": matriFisc,
  };

  final response = await http.put(
   url,
   headers: headers,
   body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
   throw Exception('Failed to update user');
  }

  final rowsUpdated = int.parse(response.body);
  return rowsUpdated;
 }
}
