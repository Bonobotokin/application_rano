import 'package:application_rano/data/models/user.dart';

class UserInfo {
  final String? name;
  final String? phoneNumber;
  final String? password;
  final String? cpCommune;
  final int? roleId;
  final String? lastToken;

  UserInfo({
    this.name,
    this.phoneNumber,
    this.password,
    this.cpCommune,
    this.roleId,
    this.lastToken,
  });

  factory UserInfo.fromUser(User user) {
    return UserInfo(
      name: '${user.nomUtilisateur} ${user.prenomUtilisateur}',
      phoneNumber: user.numUtilisateur,
      password: user.password,
      cpCommune: user.cpCommune,
      roleId: user.roleId,
      lastToken: user.lastToken,
    );
  }
}
