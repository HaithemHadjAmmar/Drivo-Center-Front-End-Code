import 'dart:convert';
import 'package:auto_ecole/g%C3%A9rer_Candidats/controllers/Candidats.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../Screens/login_screen.dart';
import '../../Services/globals.dart';
import 'Seance.dart';



class CandidatServices {
  //partie candidat




//updata Candidat
  static Future<http.Response> updateCandidatById(String id, String nom,
      String prenom, DateTime dateNaissance, String cin,int numTel, String adresse,
      String email,String prix_heure_code, String prixHeure,String prix_heure_park, String avance,int nbr_heure_total_code, int nbr_heure_total,
      int nbr_heure_total_park, String password) async {
    final url = Uri.parse(baseURL + 'update/candidat/$id');
    final headers = {
      'Content-Type': 'application/json',
    };

    // Format the date as Y-m-d
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateNaissance);

    final data = {
      "nom": nom,
      "prenom": prenom,
      "date_naissance": formattedDate,
      "cin": cin,
      "num_tel": numTel,
      "email": email,
      "adresse": adresse,
      "prix_heure_code":prix_heure_code,
      "prix_heure": prixHeure,
      "prix_heure_park":prix_heure_park,
      "avance": avance,
      "nbr_heure_total_code":nbr_heure_total_code,
      "nbr_heure_total":nbr_heure_total,
      "nbr_heure_total_park":nbr_heure_total_park,
      "password": password,
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      print(response.body);
      return response;
    } catch (e) {
      print('Error updating candidate: $e');
      rethrow;
    }
  }


  // delete Candidat
  static Future<http.Response> deleteCandidate(String id) async {
    var url = Uri.parse(baseURL + 'delete/candidats/$id');
    http.Response response = await http.delete(
      url,
      headers: headers,
    );
    print(response.body);
    return response;
  }


  //recherche Candidat
  static Future<List<dynamic>> searchCandidats(String query) async {
    var url = Uri.parse(baseURL + 'search/candidats?query=$query');
    http.Response response = await http.get(
      url,
      headers: headers,
    );
    print(response.body);
    return jsonDecode(response.body);
  }

  // Partie Seance
//ajouter Seance
  static Future<http.Response> addSeance(
      int candidatId,
      DateTime date,
      String heureDebut,
      int nbrHeure,
      String type,
      ) async {
    final url = Uri.parse(baseURL + '/candidats/seances');
    final headers = {'Content-Type': 'application/json'};

    // Format the date as Y-m-d
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final data = {
      'candidat_id': candidatId,
      'date': formattedDate,
      'heure_debut': heureDebut,
      'nbr_heure': nbrHeure,
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