// Um pet de um cliente. A espécie vem da API do iNaturalist.
class Pet {
  final int? id;
  final int usuarioId;
  final String nome;
  final String tipo; // nome do animal, em português quando existir
  final int? taxonId;
  final String? nomeCientifico;
  final String? fotoUrl;
  final String? fotoAtribuicao; // crédito obrigatório da foto

  const Pet({
    this.id,
    required this.usuarioId,
    required this.nome,
    required this.tipo,
    this.taxonId,
    this.nomeCientifico,
    this.fotoUrl,
    this.fotoAtribuicao,
  });

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'tipo': tipo,
      'taxon_id': taxonId,
      'nome_cientifico': nomeCientifico,
      'foto_url': fotoUrl,
      'foto_atribuicao': fotoAtribuicao,
    };
  }

  factory Pet.deMapa(Map<String, dynamic> mapa) {
    return Pet(
      id: mapa['id'] as int?,
      usuarioId: mapa['usuario_id'] as int,
      nome: mapa['nome'] as String,
      tipo: mapa['tipo'] as String,
      taxonId: mapa['taxon_id'] as int?,
      nomeCientifico: mapa['nome_cientifico'] as String?,
      fotoUrl: mapa['foto_url'] as String?,
      fotoAtribuicao: mapa['foto_atribuicao'] as String?,
    );
  }
}
