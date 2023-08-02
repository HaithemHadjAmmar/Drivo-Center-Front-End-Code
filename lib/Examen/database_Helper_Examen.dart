import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Services/globals.dart';
import 'package:http/http.dart' as http;

class Examen {
  static Future<http.Response> addSeance(
      {required int candidatId,
        required DateTime date,
        required String heure,
        required String type}) async {
    final url = Uri.parse(baseURL + '/candidats/examen');
    final headers = {'Content-Type': 'application/json'};

    // Format the date as Y-m-d
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final data = {
      'candidat_id': candidatId,
      'date': formattedDate,
      'heure': heure,
      'type': type,
    };

    final body = json.encode(data);
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
