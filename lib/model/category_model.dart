// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

CategoryModel categoryModelFromJson(String str) => CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  int status;
  List<SangeetCategory> sangeetCategory;

  CategoryModel({
    required this.status,
    required this.sangeetCategory,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    status: json["status"],
    sangeetCategory: List<SangeetCategory>.from(json["sangeetCategory"].map((x) => SangeetCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "sangeetCategory": List<dynamic>.from(sangeetCategory.map((x) => x.toJson())),
  };
}

class SangeetCategory {
  int id;
  String name;
  String image;
  String banner;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> translations;

  SangeetCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.banner,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory SangeetCategory.fromJson(Map<String, dynamic> json) => SangeetCategory(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    banner: json["banner"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    translations: List<dynamic>.from(json["translations"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "banner": banner,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "translations": List<dynamic>.from(translations.map((x) => x)),
  };
}
