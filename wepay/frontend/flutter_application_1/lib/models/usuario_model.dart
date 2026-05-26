class UsuarioModel {
  final String email;
  final String? token;

  UsuarioModel({required this.email, this.token});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    if (token != null) 'token': token,
  };
}