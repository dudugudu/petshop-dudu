// Uma espécie de animal devolvida pela busca do iNaturalist
class TipoAnimal {
  final int id;
  final String nomeComum; // pode vir vazio
  final String nomeCientifico;
  final String? fotoUrl;
  final String? atribuicao;

  const TipoAnimal({
    required this.id,
    required this.nomeComum,
    required this.nomeCientifico,
    this.fotoUrl,
    this.atribuicao,
  });

  // O nome comum, ou o científico se não houver um comum
  String get nomeExibicao => nomeComum.trim().isNotEmpty ? nomeComum : nomeCientifico;

  factory TipoAnimal.deMapa(Map<String, dynamic> mapa) {
    final Map<String, dynamic>? foto = mapa['default_photo'] as Map<String, dynamic>?;
    return TipoAnimal(
      id: mapa['id'] as int,
      nomeComum: (mapa['preferred_common_name'] ?? '') as String,
      nomeCientifico: (mapa['name'] ?? '') as String,
      fotoUrl: foto?['square_url'] as String?,
      atribuicao: foto?['attribution'] as String?,
    );
  }
}
