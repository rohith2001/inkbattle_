import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  int? id;
  String? name;
  String? profilePicture;
  String? provider;
  String? providerId;
  String? guestToken;
  int? coins;
  String? avatar;
  String? language;
  String? country;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.profilePicture,
    this.provider,
    this.providerId,
    this.guestToken,
    this.coins,
    this.avatar,
    this.language,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        profilePicture: json["profilePicture"],
        provider: json["provider"],
        providerId: json["providerId"],
        guestToken: json["guestToken"],
        coins: json["coins"],
        avatar: json["avatar"],
        language: json["language"],
        country: json["country"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profilePicture": profilePicture,
        "provider": provider,
        "providerId": providerId,
        "guestToken": guestToken,
        "coins": coins,
        "avatar": avatar,
        "language": language,
        "country": country,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class AuthResponse {
  int? userId;
  String? token;
  bool? isNew;

  AuthResponse({
    this.userId,
    this.token,
    this.isNew,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json["userId"],
        token: json["token"],
        isNew: json["isNew"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "token": token,
        "isNew": isNew,
      };
}

class UserResponse {
  UserModel? user;

  UserResponse({this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
      };
}
