class UserModel {
  final String? id;
  final String? name;
  final String? tagName;
  final int? gender;
  final String? address;
  final String? imageUrl;
  final String? email;
  final String? phoneNumber;
  final String? token;
  final String? refreshToken;
  final String? role;
  final bool requiresTwoFactor;
  final String? message;
  final bool isSuccess;
  final String? errorMessage;

  UserModel({
    this.id,
    this.name,
    this.tagName,
    this.gender,
    this.address,
    this.imageUrl,
    this.email,
    this.phoneNumber,
    this.token,
    this.refreshToken,
    this.role,
    this.requiresTwoFactor = false,
    this.message,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      tagName: json['tagName'],
      gender: json['gender'],
      address: json['address'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      role: json['role'],
      requiresTwoFactor: json['requiresTwoFactor'] ?? false,
      message: json['message'],
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagName': tagName,
      'gender': gender,
      'address': address,
      'imageUrl': imageUrl,
      'email': email,
      'phoneNumber': phoneNumber,
      'token': token,
      'refreshToken': refreshToken,
      'role': role,
      'requiresTwoFactor': requiresTwoFactor,
      'message': message,
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? tagName,
    int? gender,
    String? address,
    String? imageUrl,
    String? email,
    String? phoneNumber,
    String? token,
    String? refreshToken,
    String? role,
    bool? requiresTwoFactor,
    String? message,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tagName: tagName ?? this.tagName,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
      requiresTwoFactor: requiresTwoFactor ?? this.requiresTwoFactor,
      message: message ?? this.message,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoggedIn => isSuccess && token != null && token!.isNotEmpty;
}
