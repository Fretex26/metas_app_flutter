import 'package:metas_app/features/auth/domain/entities/app_user.dart';

AppUser appUserFromJson(Map<String, dynamic> json) {
  return AppUser(
    uid: json['uid'] ?? '',
    email: json['email'] ?? '',
  );
}

Map<String, dynamic> appUserToJson(AppUser user) {
  return {
    'uid': user.uid,
    'email': user.email,
  };
}