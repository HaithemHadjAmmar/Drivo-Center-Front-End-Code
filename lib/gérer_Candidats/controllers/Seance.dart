// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Seance> welcomeFromJson(String str) => List<Seance>.from(json.decode(str).map((x) => Seance.fromJson(x)));

String welcomeToJson(List<Seance> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Seance {
  int id;
  int candidatId;
  DateTime date;
  String heureDebut;
  int nbrHeure;
  String type;
  dynamic createdAt;
  dynamic updatedAt;

  Seance({
    required this.id,
    required this.candidatId,
    required this.date,
    required this.heureDebut,
    required this.nbrHeure,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Seance.fromJson(Map<String, dynamic> json) => Seance(
    id: json["id"],
    candidatId: json["candidat_id"],
    date: DateTime.parse(json["date"]),
    heureDebut: json["heure_debut"],
    nbrHeure: json["nbr_heure"],
    type: json["type"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "candidat_id": candidatId,
    "date": date.toIso8601String(),
    "heure_debut": heureDebut,
    "nbr_heure": nbrHeure,
    "type": type,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
