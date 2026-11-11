// Uma conta do app. 'admin' gerencia a loja; 'cliente' acompanha os próprios pets e agendamentos.
class Usuario {
  static const String perfilAdmin = 'admin';
  static const String perfilCliente = 'cliente';

  final int? id;
  final String nome;
  final String email;
  final String senhaHash;
  final String perfil;
  final String? telefone;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;

  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.perfil,
    this.telefone,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
  });

  bool get ehAdmin => perfil == perfilAdmin;

  // Endereço em uma linha, sem os campos vazios
  String get enderecoCompleto {
    final String? cidadeUf = cidade != null && uf != null ? '$cidade/$uf' : cidade ?? uf;
    return [logradouro, numero, complemento, bairro, cidadeUf]
        .whereType<String>()
        .map((parte) => parte.trim())
        .where((parte) => parte.isNotEmpty)
        .join(', ');
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'perfil': perfil,
      'telefone': telefone,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    };
  }

  factory Usuario.deMapa(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa['id'] as int?,
      nome: mapa['nome'] as String,
      email: mapa['email'] as String,
      senhaHash: mapa['senha_hash'] as String,
      perfil: mapa['perfil'] as String,
      telefone: mapa['telefone'] as String?,
      cep: mapa['cep'] as String?,
      logradouro: mapa['logradouro'] as String?,
      numero: mapa['numero'] as String?,
      complemento: mapa['complemento'] as String?,
      bairro: mapa['bairro'] as String?,
      cidade: mapa['cidade'] as String?,
      uf: mapa['uf'] as String?,
    );
  }
}
