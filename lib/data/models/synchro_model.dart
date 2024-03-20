class SynchroModel {
  int? id;
  int? missionId;
  int? status;
  String? lastSync;

  SynchroModel({
    this.id,
    this.missionId,
    this.status,
    this.lastSync,
  });

  factory SynchroModel.fromJson(Map<String, dynamic> json) {
    return SynchroModel(
      id: json['id'],
      missionId: json['mission_id'],
      status: json['status'],
      lastSync: json['last_sync'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mission_id': missionId,
      'status': status,
      'last_sync': lastSync,
    };
  }
}