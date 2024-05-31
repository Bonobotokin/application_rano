
// Événements
abstract class SendDataEvent {}

class StartSendingData extends SendDataEvent {
  final int totalDataToSend;

  StartSendingData({required this.totalDataToSend});
}

class DataSent extends SendDataEvent {}