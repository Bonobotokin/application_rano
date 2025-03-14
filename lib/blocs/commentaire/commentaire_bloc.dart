import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commentaire_event.dart';
import 'commentaire_state.dart';
import 'package:application_rano/data/repositories/commentaire/commentaire_repository_locale.dart';

class CommentaireBLoc extends Bloc<CommentaireEvent, CommentaireState> {
  final CommentaireRepositoryLocale commentaireRepositoryLocale;

  CommentaireBLoc({required this.commentaireRepositoryLocale})
      : super(CommentaireInitial()) {
    on<LoadCommentaire>(_onLoadCommentaire);
    on<AddCommentaire>(_onAddCommentaire);
  }

  void _onLoadCommentaire(LoadCommentaire event, Emitter<CommentaireState> emit) async {
    try {
      emit(CommentaireLoading());
      final result = await commentaireRepositoryLocale.getCommentaireData(event.idMc);
      debugPrint("liste COmmentaire $result");
      final commentaires = result['commentaires'];
      final idSuivie = result['idSuivie'];
      emit(CommentaireLoaded(commentaires, event.idMc, idSuivie));

    } catch (error) {
      debugPrint(error.toString());
      emit(CommentaireFailed('Failed to load Commentaire: $error'));
    }
  }

  void _onAddCommentaire(AddCommentaire event, Emitter<CommentaireState> emit) async {
    try {
      // Add the comment to the repository
      debugPrint("data ${event.idMc}");
      await commentaireRepositoryLocale.addCommentaire(
        event.idMc,
        event.idSuivie,
        event.commentaire,
      );

      // Reload the comments after adding
      final result = await commentaireRepositoryLocale.getCommentaireData(event.idMc);
      debugPrint("data Teste $result");
      final commentaires = result['commentaires'];
      final idSuivie = result['idSuivie'];
      emit(CommentaireLoading());
      emit(CommentaireLoaded(commentaires, event.idMc, idSuivie));
    } catch (error) {
      emit(CommentaireFailed('Failed to add Commentaire: $error'));
    }
  }


}
