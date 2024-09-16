import 'dart:convert';

CategoryModel categoryModelFromJson(String str) => CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  int status;
  List<Datum> data;

  CategoryModel({
    required this.status,
    required this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
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
  String hiName;
  String image;
  String banner;

  Datum({
    required this.id,
    required this.enName,
    required this.hiName,
    required this.image,
    required this.banner,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    enName: json["en_name"],
    hiName: json["hi_name"],
    image: json["image"],
    banner: json["banner"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "en_name": enName,
    "hi_name": hiName,
    "image": image,
    "banner": banner,
  };
}
