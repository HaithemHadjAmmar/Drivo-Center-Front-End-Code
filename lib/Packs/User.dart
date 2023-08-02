// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  bool ok;
  Data data;

  Welcome({
    required this.ok,
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    ok: json["ok"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String nomAgence;
  String codeAgence;
  String email;
  String adresse;
  String numTel;
  String matriFisc;
  dynamic createdAt;
  dynamic updatedAt;

  Data({
    required this.id,
    required this.nomAgence,
    required this.codeAgence,
    required this.email,
    required this.adresse,
    required this.numTel,
    required this.matriFisc,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    nomAgence: json["nom_agence"],
    codeAgence: json["code_agence"],
    email: json["email"],
    adresse: json["adresse"],
    numTel: json["num_tel"],
    matriFisc: json["matri_fisc"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nom_agence": nomAgence,
    "code_agence": codeAgence,
    "email": email,
    "adresse": adresse,
    "num_tel": numTel,
    "matri_fisc": matriFisc,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
