import 'dart:convert';

ThemeModel themeModelFromJson(String str) =>
    ThemeModel.fromJson(json.decode(str));

String themeModelToJson(ThemeModel data) => json.encode(data.toJson());

class ThemeModel {
  int? id;
  String? title;
  List<WordModel>? words;
  DateTime? createdAt;
  DateTime? updatedAt;

  ThemeModel({
    this.id,
    this.title,
    this.words,
    this.createdAt,
    this.updatedAt,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) => ThemeModel(
        id: json["id"],
        title: json["title"],
        words: json["Words"] == null
            ? null
            : List<WordModel>.from(
                json["Words"].map((x) => WordModel.fromJson(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "Words": words?.map((x) => x.toJson()).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class WordModel {
  int? id;
  int? themeId;
  String? text;
  DateTime? createdAt;
  DateTime? updatedAt;

  WordModel({
    this.id,
    this.themeId,
    this.text,
    this.createdAt,
    this.updatedAt,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
        id: json["id"],
        themeId: json["themeId"],
        text: json["text"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "themeId": themeId,
        "text": text,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class ThemeListResponse {
  List<ThemeModel>? themes;

  ThemeListResponse({this.themes});

  factory ThemeListResponse.fromJson(Map<String, dynamic> json) =>
      ThemeListResponse(
        themes: json["themes"] == null
            ? null
            : List<ThemeModel>.from(
                json["themes"].map((x) => ThemeModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "themes": themes?.map((x) => x.toJson()).toList(),
      };
}

class RandomWordResponse {
  WordModel? word;

  RandomWordResponse({this.word});

  factory RandomWordResponse.fromJson(Map<String, dynamic> json) =>
      RandomWordResponse(
        word: json["word"] == null ? null : WordModel.fromJson(json["word"]),
      );

  Map<String, dynamic> toJson() => {
        "word": word?.toJson(),
      };
}
