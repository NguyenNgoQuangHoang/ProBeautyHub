class UserModel {
  final String? token;
  final String? refreshToken;
  final String? name;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? role;
  final bool requiresTwoFactor;
  final String? message;
  final bool isSuccess;
  final String? errorMessage;

  UserModel({
    this.token,
    this.refreshToken,
    this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.role,
    this.requiresTwoFactor = false,
    this.message,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      role: json['role'],
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      message: json['message'],
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'requiresTwoFactor': requiresTwoFactor,
      'message': message,
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }

  bool get isLoggedIn => isSuccess && token != null && token!.isNotEmpty;
}
