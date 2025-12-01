class ErrorModel {
  String? status;
  String? message;

  ErrorModel({
    this.status,
    this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        status: json['status'] as String?,
        message: json['message'] as String?,
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'message': message,
      };
}
