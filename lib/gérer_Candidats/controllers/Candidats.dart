// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  Datum data;

  Welcome({
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    data: Datum.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Datum {
  int id;
  int userId;
  String nom;
  String prenom;
  DateTime dateNaissance;
  String cin;
  int numTel;
  String email;
  String adresse;
  String prixHeure;
  String prixHeurePark;
  String prixHeureCode;
  String avance;
  int nbrHeureTotal;
  int nbrHeureTotalPark;
  int nbrHeureTotalCode;
  String password;
  dynamic createdAt;
  dynamic updatedAt;

  Datum({
    required this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.cin,
    required this.numTel,
    required this.email,
    required this.adresse,
    required this.prixHeure,
    required this.prixHeurePark,
    required this.prixHeureCode,
    required this.avance,
    required this.nbrHeureTotal,
    required this.nbrHeureTotalPark,
    required this.nbrHeureTotalCode,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    nom: json["nom"],
    prenom: json["prenom"],
    dateNaissance: DateTime.parse(json["date_naissance"]),
    cin: json["cin"],
    numTel: json["num_tel"],
    email: json["email"],
    adresse: json["adresse"],
    prixHeure: json["prix_heure"],
    prixHeurePark: json["prix_heure_park"],
    prixHeureCode: json["prix_heure_code"],
    avance: json["avance"],
    nbrHeureTotal: json["nbr_heure_total"],
    nbrHeureTotalPark: json["nbr_heure_total_park"],
    nbrHeureTotalCode: json["nbr_heure_total_code"],
    password: json["password"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "nom": nom,
    "prenom": prenom,
    "date_naissance": "${dateNaissance.year.toString().padLeft(4, '0')}-${dateNaissance.month.toString().padLeft(2, '0')}-${dateNaissance.day.toString().padLeft(2, '0')}",
    "cin": cin,
    "num_tel": numTel,
    "email": email,
    "adresse": adresse,
    "prix_heure": prixHeure,
    "prix_heure_park": prixHeurePark,
    "prix_heure_code": prixHeureCode,
    "avance": avance,
    "nbr_heure_total": nbrHeureTotal,
    "nbr_heure_total_park": nbrHeureTotalPark,
    "nbr_heure_total_code": nbrHeureTotalCode,
    "password": password,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}