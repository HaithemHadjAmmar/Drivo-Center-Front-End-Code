// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  bool success;
  List<Datum> data;

  Welcome({
    required this.success,
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String nom;
  int prix;
  DateTime dure;
  String description;
  String image;

  Datum({
    required this.id,
    required this.nom,
    required this.prix,
    required this.dure,
    required this.description,
    required this.image,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    nom: json["nom"],
    prix: json["prix"],
    dure: DateTime.parse(json["durée"]),
    description: json["description"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nom": nom,
    "prix": prix,
    "durée": dure.toIso8601String(),
    "description": description,
    "image": image,
  };
}
