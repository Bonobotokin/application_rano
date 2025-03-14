import 'package:application_rano/blocs/commentaire/commentaire_state.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/commentaire/commentaire_bloc.dart';
import 'package:application_rano/blocs/commentaire/commentaire_event.dart';
import 'package:application_rano/data/models/commentaire_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';

class CommentairePage extends StatefulWidget {
  const CommentairePage({super.key});

  @override
  CommentairePageState createState() => CommentairePageState();
}

class CommentairePageState extends State<CommentairePage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late int _idMc;
  late int _idSuivie;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 2,
          authState: authState,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Commentaires",
                      style: TextStyle(
                        color: Color(0xdd2e3131),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<CommentaireBLoc, CommentaireState>(
                  builder: (context, state) {
                    if (state is CommentaireLoading) {
                      return _buildLoadingState();
                    } else if (state is CommentaireLoaded) {
                      return _buildCommentaireList(state.commentaires);
                    } else if (state is CommentaireFailed) {
                      return Center(child: Text('Erreur: ${state.error}'));
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<CommentaireBLoc, CommentaireState>(
                    builder: (context, state) {
                      if (state is CommentaireLoaded) {
                        _idMc = state.idMc; // Assurez-vous que _idMc est correctement assigné
                        _idSuivie = state.idSuivie; // Assurez-vous que _idSuivie est correctement assigné
                      }
                      return _buildNewCommentaireField(state);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCommentaireList(List<CommentaireModel> commentaires) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: commentaires.length,
      itemBuilder: (context, index) {
        final commentaire = commentaires[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          elevation: 3,
          child: ListTile(
            title: Text(commentaire.commentaireSuivie),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(commentaire.dateSuivie),
            ),
            leading: const Icon(
              Icons.comment,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewCommentaireField(CommentaireState state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1.0,
                ),
                color: Colors.white,
              ),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  labelText: 'Nouveau commentaire',
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                maxLines: 5,
                minLines: 1,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                BlocProvider.of<CommentaireBLoc>(context).add(
                  AddCommentaire(
                    idMc: _idMc,
                    idSuivie: _idSuivie,
                    commentaire: _commentController.text,
                  ),
                );
                _commentController.clear();
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
