class User {
  int? id_utilisateur;
  String? nomUtilisateur;
  String? prenomUtilisateur;
  String? numUtilisateur;
  String? password;
  String? cpCommune;
  int? roleId;
  String? lastToken;

  User({
    this.id_utilisateur,
    this.nomUtilisateur,
    this.prenomUtilisateur,
    this.numUtilisateur,
    this.password,
    this.cpCommune,
    this.roleId,
    this.lastToken,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id_utilisateur: map['id_utilisateur'],
      nomUtilisateur: map['nom_utilisateur'],
      prenomUtilisateur: map['prenom_utilisateur'],
      numUtilisateur: map['num_utilisateur'],
      password: map['password'],
      cpCommune: map['cp_commune'],
      roleId: map['role_id'],
      lastToken: map['last_token'],
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id_utilisateur: json['id_utilisateur'] ?? 0, // Utilisez une valeur par défaut ou un traitement spécial pour gérer les valeurs nulles si nécessaire
      nomUtilisateur: json['nom_utilisateur'],
      prenomUtilisateur: json['prenom_utilisateur'],
      numUtilisateur: json['num_utilisateur'],
      password: json['password'],
      cpCommune: json['cp_commune'],
      roleId: json['role_id'],
      lastToken: json['last_token'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': id_utilisateur,
      'nom_utilisateur': nomUtilisateur,
      'prenom_utilisateur': prenomUtilisateur,
      'num_utilisateur': numUtilisateur,
      'password': password,
      'cp_commune': cpCommune,
      'role_id': roleId,
      'last_token': lastToken,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id_utilisateur': id_utilisateur,
      'nom_utilisateur': nomUtilisateur,
      'prenom_utilisateur': prenomUtilisateur,
      'num_utilisateur': numUtilisateur,
      'password': password,
      'cp_commune': cpCommune,
      'role_id': roleId,
      'last_token': lastToken,
    };
  }

  Map<String, dynamic> toMapExcludingId() {
    return {
      'nom_utilisateur': nomUtilisateur,
      'prenom_utilisateur': prenomUtilisateur,
      'num_utilisateur': numUtilisateur,
      'password': password,
      'cp_commune': cpCommune,
      'role_id': roleId,
      'last_token': lastToken,
    };
  }

  @override
  String toString() {
    return 'User{id: $id_utilisateur, nomUtilisateur: $nomUtilisateur,mdp: $password ,AccessTOken: $lastToken,...}';
  }
}
