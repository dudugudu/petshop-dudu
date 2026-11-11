import '../core/seguranca.dart';
import '../models/usuario.dart';
import 'banco_de_dados.dart';

// Consultas da tabela de contas: cadastro, login e lista de clientes
class RepositorioUsuarios {
  static Future<Usuario?> buscarPorEmail(String email) async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    return linhas.isEmpty ? null : Usuario.deMapa(linhas.first);
  }

  // Devolve a conta se e-mail e senha conferirem, senão null
  static Future<Usuario?> autenticar(String email, String senha) async {
    final Usuario? usuario = await buscarPorEmail(email);
    if (usuario == null || !Seguranca.conferir(senha, usuario.senhaHash)) {
      return null;
    }
    return usuario;
  }

  static Future<Usuario> cadastrarCliente({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String cep,
    required String logradouro,
    required String numero,
    required String complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    final db = await BancoDeDados.abrir();
    final Usuario novo = Usuario(
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senhaHash: Seguranca.gerarHash(senha),
      perfil: Usuario.perfilCliente,
      telefone: _limpo(telefone),
      cep: cep.replaceAll(RegExp(r'\D'), ''),
      logradouro: logradouro.trim(),
      numero: numero.trim(),
      complemento: _limpo(complemento),
      bairro: bairro.trim(),
      cidade: cidade.trim(),
      uf: uf.trim().toUpperCase(),
    );
    await db.insert('usuarios', novo.paraMapa());
    return (await buscarPorEmail(novo.email))!;
  }

  static Future<List<Usuario>> listarClientes() async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.query(
      'usuarios',
      where: 'perfil = ?',
      whereArgs: [Usuario.perfilCliente],
      orderBy: 'nome COLLATE NOCASE',
    );
    return linhas.map(Usuario.deMapa).toList();
  }

  // Texto vazio vira null
  static String? _limpo(String texto) => texto.trim().isEmpty ? null : texto.trim();
}
