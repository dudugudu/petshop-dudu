import '../models/pet.dart';
import 'banco_de_dados.dart';

// Consultas da tabela de pets
class RepositorioPets {
  static Future<List<Pet>> listarDoUsuario(int usuarioId) async {
    final db = await BancoDeDados.abrir();
    final linhas = await db.query(
      'pets',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'nome COLLATE NOCASE',
    );
    return linhas.map(Pet.deMapa).toList();
  }

  static Future<void> inserir(Pet pet) async {
    final db = await BancoDeDados.abrir();
    await db.insert('pets', pet.paraMapa());
  }

  static Future<void> excluir(int id) async {
    final db = await BancoDeDados.abrir();
    await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }
}
