// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    bool? status;
    String? message;
    Data? data;

    LoginModel({
        this.status,
        this.message,
        this.data,
    });

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    User? user;
    String? token;

    Data({
        this.user,
        this.token,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "token": token,
    };
}

class User {
    String? id;
    dynamic gramName;
    String? gramImg;
    dynamic district;
    dynamic taluka;
    String? fullName;
    String? mobileNo;
    String? email;
    DateTime? createdAt;

    User({
        this.id,
        this.gramName,
        this.gramImg,
        this.district,
        this.taluka,
        this.fullName,
        this.mobileNo,
        this.email,
        this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        gramName: json["gram_name"],
        gramImg: json["gram_img"],
        district: json["district"],
        taluka: json["taluka"],
        fullName: json["full_name"],
        mobileNo: json["mobile_no"],
        email: json["email"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "gram_name": gramName,
        "gram_img": gramImg,
        "district": district,
        "taluka": taluka,
        "full_name": fullName,
        "mobile_no": mobileNo,
        "email": email,
        "createdAt": createdAt?.toIso8601String(),
    };
}
