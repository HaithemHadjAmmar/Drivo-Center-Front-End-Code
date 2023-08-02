// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Examen> welcomeFromJson(String str) => List<Examen>.from(json.decode(str).map((x) => Examen.fromJson(x)));

String welcomeToJson(List<Examen> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Examen {
  int id;
  int candidatId;
  DateTime date;
  String heure;
  String type;
  dynamic createdAt;
  dynamic updatedAt;

  Examen({
    required this.id,
    required this.candidatId,
    required this.date,
    required this.heure,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Examen.fromJson(Map<String, dynamic> json) => Examen(
    id: json["id"],
    candidatId: json["candidat_id"],
    date: DateTime.parse(json["date"]),
    heure: json["heure"],
    type: json["type"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "candidat_id": candidatId,
    "date": date.toIso8601String(),
    "heure": heure,
    "type": type,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
