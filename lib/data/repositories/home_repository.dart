import 'package:application_rano/data/models/home_model.dart'; // Importez votre modèle HomeModel
import 'package:application_rano/data/repositories/local/home_repository_locale.dart';

class HomeRepository {
  final String baseUrl;

  HomeRepository({required this.baseUrl});

  Future<HomeModel> fetchHomePageData(String accessToken) async {
    try {
      final List<HomeModel> homeModels =
          await HomeRepositoryLocale().getAcceuilData();
      return homeModels.first; // Prenez le premier élément de la liste
    } catch (e) {
      // En cas d'erreur lors de la requête HTTP, lancez une exception avec le message d'erreur
      throw Exception('Failed to fetch home page data: $e');
    }
  }
}
