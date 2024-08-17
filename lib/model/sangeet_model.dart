// To parse this JSON data, do
//
//     final sangeetModel = sangeetModelFromJson(jsonString);

import 'dart:convert';

SangeetModel sangeetModelFromJson(String str) => SangeetModel.fromJson(json.decode(str));

String sangeetModelToJson(SangeetModel data) => json.encode(data.toJson());

class SangeetModel {
  int status;
  List<Sangeet> sangeet;

  SangeetModel({
    required this.status,
    required this.sangeet,
  });

  factory SangeetModel.fromJson(Map<String, dynamic> json) => SangeetModel(
    status: json["status"],
    sangeet: List<Sangeet>.from(json["sangeet"].map((x) => Sangeet.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "sangeet": List<dynamic>.from(sangeet.map((x) => x.toJson())),
  };
}

class Sangeet {
  int id;
  String title;
  String singerName;
  String audio;
  String lyrics;
  String image;
  String backgroundImage;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  List<dynamic> translations;

  Sangeet({
    required this.id,
    required this.title,
    required this.singerName,
    required this.audio,
    required this.lyrics,
    required this.image,
    required this.backgroundImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.translations,
  });

  factory Sangeet.fromJson(Map<String, dynamic> json) => Sangeet(
    id: json["id"],
    title: json["title"],
    singerName: json["singer_name"],
    audio: json["audio"],
    lyrics: json["lyrics"],
    image: json["image"],
    backgroundImage: json["background_image"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    translations: List<dynamic>.from(json["translations"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "singer_name": singerName,
    "audio": audio,
    "lyrics": lyrics,
    "image": image,
    "background_image": backgroundImage,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "deleted_at": deletedAt,
    "translations": List<dynamic>.from(translations.map((x) => x)),
  };
}
