import 'package:sqflite/sqflite.dart';
import 'atendimento.dart';

// Esta classe concentra TODO o acesso ao SQLite.
// As telas não escrevem SQL: elas só chamam estes métodos.
class BancoDeDados {
  static Database? _banco;

  // Abre o banco. Se for a primeira vez, cria o arquivo e a tabela.
  static Future<Database> abrir() async {
    // Se o banco já foi aberto antes, reaproveita
    if (_banco != null) {
      return _banco!;
    }

    String pasta = await getDatabasesPath();
    String caminho = '$pasta/petshop.db';

    _banco = await openDatabase(
      caminho,
      version: 1,
      // onCreate só roda UMA vez, quando o arquivo do banco ainda não existe
      onCreate: (db, versao) async {
        await db.execute('''
          CREATE TABLE atendimentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_pet TEXT NOT NULL,
            nome_tutor TEXT NOT NULL,
            servico TEXT NOT NULL,
            data TEXT NOT NULL,
            valor REAL NOT NULL
          )
        ''');
      },
    );
    return _banco!;
  }

  // CREATE - cadastrar um atendimento
  static Future<void> inserir(Atendimento atendimento) async {
    final db = await abrir();
    await db.insert('atendimentos', atendimento.paraMapa());
  }

  // READ - listar atendimentos (com pesquisa opcional por pet ou tutor)
  static Future<List<Atendimento>> listar(String busca) async {
    final db = await abrir();

    // LIKE com % procura o texto em qualquer parte do nome.
    // Se busca for vazio, vira '%%' e traz todos os registros.
    List<Map<String, dynamic>> resultado = await db.query(
      'atendimentos',
      where: 'nome_pet LIKE ? OR nome_tutor LIKE ?',
      whereArgs: ['%$busca%', '%$busca%'],
      orderBy: 'data DESC', // mais recentes primeiro
    );

    // Converte cada Map do banco em um objeto Atendimento
    List<Atendimento> lista = [];
    for (var mapa in resultado) {
      lista.add(Atendimento.deMapa(mapa));
    }
    return lista;
  }

  // UPDATE - editar um atendimento existente
  static Future<void> atualizar(Atendimento atendimento) async {
    final db = await abrir();
    await db.update(
      'atendimentos',
      atendimento.paraMapa(),
      where: 'id = ?',
      whereArgs: [atendimento.id],
    );
  }

  // DELETE - excluir um atendimento
  static Future<void> excluir(int id) async {
    final db = await abrir();
    await db.delete('atendimentos', where: 'id = ?', whereArgs: [id]);
  }

  // Faturamento total calculado pelo SQL (função SUM soma todos os valores)
  static Future<double> calcularFaturamentoTotal() async {
    final db = await abrir();
    var resultado = await db.rawQuery(
      'SELECT SUM(valor) AS total FROM atendimentos',
    );

    // Se a tabela estiver vazia, o SUM devolve nulo
    if (resultado.first['total'] == null) {
      return 0;
    }
    return (resultado.first['total'] as num).toDouble();
  }

  // Quantidade de atendimentos (função COUNT conta as linhas)
  static Future<int> contarAtendimentos() async {
    final db = await abrir();
    var resultado = await db.rawQuery(
      'SELECT COUNT(*) AS quantidade FROM atendimentos',
    );
    return resultado.first['quantidade'] as int;
  }
}