// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  List<Paiement> data;

  Welcome({
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    data: List<Paiement>.from(json["data"].map((x) => Paiement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Paiement {
  int id;
  int candidatId;
  double montant;
  DateTime datePaiement;
  dynamic createdAt;
  dynamic updatedAt;

  Paiement({
    required this.id,
    required this.candidatId,
    required this.montant,
    required this.datePaiement,
    this.createdAt,
    this.updatedAt,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) => Paiement(
    id: json["id"],
    candidatId: json["candidat_id"],
    montant: json["montant"]?.toDouble(),
    datePaiement: DateTime.parse(json["date_paiement"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "candidat_id": candidatId,
    "montant": montant,
    "date_paiement": datePaiement.toIso8601String(),
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
