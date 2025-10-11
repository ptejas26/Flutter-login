class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String createdAt;
  final String updatedAt;
  final int version;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'age': age,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final String authToken;
  final String refreshToken;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.authToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: User.fromJson(json['data']['user'] ?? {}),
      authToken: json['data']['authToken'] ?? '',
      refreshToken: json['data']['refreshToken'] ?? '',
    );
  }
}
