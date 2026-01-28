/// Representa la sesión actual del usuario tras [GET /auth/me].
///
/// Incluye datos de usuario y, si [role] es sponsor, el perfil sponsor con [status].
/// Usado para redirección post-login y control de acceso en la app.
class AuthMeSession {
  final AuthMeUser user;
  final AuthMeSponsor? sponsor;

  const AuthMeSession({
    required this.user,
    this.sponsor,
  });

  bool get isAdmin => user.role == 'admin';
  bool get isSponsor => user.role == 'sponsor';
  bool get isUser => user.role == 'user';

  bool get isSponsorPending => sponsor != null && sponsor!.status == 'pending';
  bool get isSponsorApproved => sponsor != null && sponsor!.status == 'approved';
  bool get isSponsorRejectedOrDisabled =>
      sponsor != null &&
      (sponsor!.status == 'rejected' || sponsor!.status == 'disabled');
}

class AuthMeUser {
  final String id;
  final String name;
  final String email;
  final String role;

  const AuthMeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AuthMeSponsor {
  final String id;
  final String status;
  final String? businessName;

  const AuthMeSponsor({
    required this.id,
    required this.status,
    this.businessName,
  });
}
