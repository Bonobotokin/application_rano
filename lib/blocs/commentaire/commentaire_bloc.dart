import 'package:flutter_bloc/flutter_bloc.dart';
import 'commentaire_event.dart';
import 'commentaire_state.dart';
import 'package:application_rano/data/models/commentaire_model.dart';
import 'package:application_rano/data/repositories/commentaire/CommentaireRepositoryLocale.dart';

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
      print("liste COmmentaire ${result}");
      final commentaires = result['commentaires'];
      final idSuivie = result['idSuivie'];
      emit(CommentaireLoaded(commentaires, event.idMc, idSuivie));

    } catch (error) {
      print(error);
      emit(CommentaireFailed('Failed to load Commentaire: $error'));
    }
  }

  void _onAddCommentaire(AddCommentaire event, Emitter<CommentaireState> emit) async {
    try {
      // Add the comment to the repository
      print("data ${event.idMc}");
      await commentaireRepositoryLocale.addCommentaire(
        event.idMc,
        event.idSuivie,
        event.commentaire,
      );

      // Reload the comments after adding
      final result = await commentaireRepositoryLocale.getCommentaireData(event.idMc);
      print("data Teste ${result}");
      final commentaires = result['commentaires'];
      final idSuivie = result['idSuivie'];
      emit(CommentaireLoading());
      emit(CommentaireLoaded(commentaires, event.idMc, idSuivie));
    } catch (error) {
      emit(CommentaireFailed('Failed to add Commentaire: $error'));
    }
  }


}
