import 'package:equatable/equatable.dart';

abstract class CommentaireEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadCommentaire extends CommentaireEvent {
  final int idMc;

  LoadCommentaire(this.idMc);

  @override
  List<Object> get props => [idMc];
}

class AddCommentaire extends CommentaireEvent {
  final int idMc;
  final int idSuivie;
  final String commentaire;

  AddCommentaire({
    required this.idMc,
    required this.idSuivie,
    required this.commentaire,
  });

  @override
  List<Object> get props => [idMc, idSuivie, commentaire];
}