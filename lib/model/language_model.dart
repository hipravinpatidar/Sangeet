// // To parse this JSON data, do
// //
// //     final languageModel = languageModelFromJson(jsonString);
//
// import 'dart:convert';
//
// LanguageModel languageModelFromJson(String str) => LanguageModel.fromJson(json.decode(str));
//
// String languageModelToJson(LanguageModel data) => json.encode(data.toJson());
//
// class LanguageModel {
//   int status;
//   List<SangeetLanguage> sangeetLanguage;
//
//   LanguageModel({
//     required this.status,
//     required this.sangeetLanguage,
//   });
//
//   factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
//     status: json["status"],
//     sangeetLanguage: List<SangeetLanguage>.from(json["sangeetLanguage"].map((x) => SangeetLanguage.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "sangeetLanguage": List<dynamic>.from(sangeetLanguage.map((x) => x.toJson())),
//   };
// }
//
// class SangeetLanguage {
//   int id;
//   String name;
//   int status;
//   DateTime createdAt;
//   DateTime updatedAt;
//   List<dynamic> translations;
//
//   SangeetLanguage({
//     required this.id,
//     required this.name,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.translations,
//   });
//
//   factory SangeetLanguage.fromJson(Map<String, dynamic> json) => SangeetLanguage(
//     id: json["id"],
//     name: json["name"],
//     status: json["status"],
//     createdAt: DateTime.parse(json["created_at"]),
//     updatedAt: DateTime.parse(json["updated_at"]),
//     translations: List<dynamic>.from(json["translations"].map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "status": status,
//     "created_at": createdAt.toIso8601String(),
//     "updated_at": updatedAt.toIso8601String(),
//     "translations": List<dynamic>.from(translations.map((x) => x)),
//   };
// }


// To parse this JSON data, do
//
//     final languageModel = languageModelFromJson(jsonString);

import 'dart:convert';

LanguageModel languageModelFromJson(String str) => LanguageModel.fromJson(json.decode(str));

String languageModelToJson(LanguageModel data) => json.encode(data.toJson());

class LanguageModel {
  int status;
  List<Datum> data;

  LanguageModel({
    required this.status,
    required this.data,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String enName;
  String name;
  int status;

  Datum({
    required this.id,
    required this.enName,
    required this.name,
    required this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    enName: json["en_name"],
    name: json["name"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "en_name": enName,
    "name": name,
    "status": status,
  };
}
