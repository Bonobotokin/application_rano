// commentaire_state.dart
import 'package:equatable/equatable.dart';
import 'package:application_rano/data/models/commentaire_model.dart';

abstract class CommentaireState extends Equatable {
  const CommentaireState();

  @override
  List<Object> get props => [];
}

class CommentaireInitial extends CommentaireState {}

class CommentaireLoading extends CommentaireState {}

class CommentaireLoaded extends CommentaireState {
  final List<CommentaireModel> commentaires;
  final int idMc;
  final int idSuivie;

  CommentaireLoaded(this.commentaires, this.idMc, this.idSuivie);
}


class CommentaireFailed extends CommentaireState {
  final String error;

  const CommentaireFailed(this.error);

  @override
  List<Object> get props => [error];
}
