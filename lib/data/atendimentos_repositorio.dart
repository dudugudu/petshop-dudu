import '../models/atendimento.dart';
import 'banco_de_dados.dart';

// Consultas da tabela de atendimentos
class RepositorioAtendimentos {
  // Cria se ainda não tem id, senão atualiza
  static Future<void> salvar(Atendimento atendimento) async {
    final db = await BancoDeDados.abrir();
    if (atendimento.id == null) {
      await db.insert('atendimentos', atendimento.paraMapa());
    } else {
      await db.update(
        'atendimentos',
        atendimento.paraMapa(),
        where: 'id = ?',
        whereArgs: [atendimento.id],
      );
    }
  }

  static Future<void> excluir(int id) async {
    final db = await BancoDeDados.abrir();
    await db.delete('atendimentos', where: 'id = ?', whereArgs: [id]);
  }

  // Lista da aba de atendimentos. A busca procura no nome do pet ou do tutor.
  static Future<List<Atendimento>> buscar(String texto) async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.query(
      'atendimentos',
      where: 'nome_pet LIKE ? OR nome_tutor LIKE ?',
      whereArgs: ['%$texto%', '%$texto%'],
      orderBy: 'data DESC, hora DESC',
    );
    return linhas.map(Atendimento.deMapa).toList();
  }

  // Agenda em ordem de data e horário. Com usuarioId, traz só os daquele cliente.
  static Future<List<Atendimento>> agenda({int? usuarioId}) async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.query(
      'atendimentos',
      where: usuarioId == null ? null : 'usuario_id = ?',
      whereArgs: usuarioId == null ? null : [usuarioId],
      orderBy: 'data ASC, hora ASC',
    );
    return linhas.map(Atendimento.deMapa).toList();
  }

  static Future<double> faturamentoTotal() async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.rawQuery('SELECT SUM(valor) AS total FROM atendimentos');
    final Object? total = linhas.first['total'];
    return total == null ? 0 : (total as num).toDouble();
  }

  static Future<int> quantidade() async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.rawQuery('SELECT COUNT(*) AS quantidade FROM atendimentos');
    return linhas.first['quantidade'] as int;
  }
}
