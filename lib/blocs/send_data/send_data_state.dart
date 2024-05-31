
// États
abstract class SendDataState {}

class SendDataInitial extends SendDataState {}

class SendingInProgress extends SendDataState {
  final int sentData;
  final int totalDataToSend;

  SendingInProgress({required this.sentData, required this.totalDataToSend});
}

class SendDataLoading extends SendDataState {}

class SendDataSuccess extends SendDataState {}

class SendDataFailure extends SendDataState {
  final String error;

  SendDataFailure(this.error);
}


class SendDataComplete extends SendDataState {}

