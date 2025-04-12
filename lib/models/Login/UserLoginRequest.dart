import '../BaseModel.dart';

class UserLoginRequest extends BaseModel {
  final String username;
  final String password;

  // Constructor
  UserLoginRequest({
    required this.username,
    required this.password,
  });

  // Implementación del método toJson
  @override
  Map<String, dynamic> toJson() {
    return {
      'email': username,
      'password': password,
    };
  }

  // Implementación del método fromJson (factoría)
  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }
}
