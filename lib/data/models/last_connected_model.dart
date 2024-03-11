class LastConnectedModel {
  final int id;
  final int id_utilisateur;
  final int is_connected;

  LastConnectedModel({
    required this.id,
    required this.id_utilisateur,
    required this.is_connected
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_utilisateur': id_utilisateur,
      'is_connected': is_connected,
    };
  }
}