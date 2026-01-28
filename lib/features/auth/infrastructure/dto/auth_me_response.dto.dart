/// DTO de respuesta del endpoint [GET /api/auth/me].
///
/// Contiene los datos del usuario autenticado y, si aplica, del perfil sponsor.
/// Usado para redirección post-login y control de acceso según rol y estado del sponsor.
class AuthMeResponseDto {
  final AuthMeUserDto user;
  final AuthMeSponsorDto? sponsor;

  const AuthMeResponseDto({
    required this.user,
    this.sponsor,
  });

  factory AuthMeResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthMeResponseDto(
      user: AuthMeUserDto.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
      sponsor: json['sponsor'] != null
          ? AuthMeSponsorDto.fromJson(
              json['sponsor'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// DTO para los datos del usuario en la respuesta de auth/me.
class AuthMeUserDto {
  final String id;
  final String name;
  final String email;
  final String role;

  const AuthMeUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Crea el DTO desde JSON.
  ///
  /// [json] debe contener: id, name, email, role (user | sponsor | admin).
  factory AuthMeUserDto.fromJson(Map<String, dynamic> json) {
    return AuthMeUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: (json['role'] as String?) ?? 'user',
    );
  }
}

/// DTO para los datos del sponsor en la respuesta de auth/me.
///
/// Solo presente si [AuthMeUserDto.role] es `sponsor` y existe perfil sponsor.
class AuthMeSponsorDto {
  final String id;
  final String status;
  final String? businessName;

  const AuthMeSponsorDto({
    required this.id,
    required this.status,
    this.businessName,
  });

  /// Crea el DTO desde JSON.
  ///
  /// [json] debe contener: id, status (pending | approved | rejected | disabled), businessName (opcional).
  factory AuthMeSponsorDto.fromJson(Map<String, dynamic> json) {
    return AuthMeSponsorDto(
      id: json['id'] as String,
      status: json['status'] as String,
      businessName: json['businessName'] as String?,
    );
  }
}
