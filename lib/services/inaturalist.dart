import '../models/tipo_animal.dart';
import 'api.dart';

// Busca de espécies no iNaturalist (inaturalist.org/pages/api+reference)
class INaturalist {
  // Só animais (taxon 1 = Animalia), só espécies, com nomes em português
  static Future<List<TipoAnimal>> buscarAnimais(String termo) async {
    final Uri uri = Uri.https('api.inaturalist.org', '/v1/taxa', {
      'q': termo.trim(),
      'taxon_id': '1',
      'rank': 'species',
      'is_active': 'true',
      'locale': 'pt-BR',
      'per_page': '15',
    });
    final dados = await buscarJson(uri);
    final List<dynamic> resultados = (dados['results'] as List<dynamic>?) ?? [];
    return resultados
        .map((item) => TipoAnimal.deMapa(item as Map<String, dynamic>))
        .toList();
  }
}
