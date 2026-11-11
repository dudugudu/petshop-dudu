import 'package:sqflite/sqflite.dart';

import '../core/seguranca.dart';

// Abre o banco SQLite e cria/atualiza as tabelas.
// As consultas ficam nos repositórios (atendimentos, usuários e pets).
class BancoDeDados {
  // Conta de administração criada no banco. Troque a senha antes de usar de verdade.
  static const String emailAdmin = 'admin@petshop.com';
  static const String senhaAdmin = 'admin123';

  static const int _versao = 2;

  static Future<Database>? _abertura;

  // Abre o banco só uma vez e reaproveita a conexão
  static Future<Database> abrir() {
    _abertura ??= _abrir();
    return _abertura!;
  }

  static Future<Database> _abrir() async {
    final String pasta = await getDatabasesPath();
    return openDatabase(
      '$pasta/petshop.db',
      version: _versao,
      onCreate: (db, _) async {
        await _criarTabelaAtendimentos(db);
        await _criarTabelaUsuarios(db);
        await _criarTabelaPets(db);
        await _criarAdmin(db);
      },
      // Bancos da versão 1 só ganham tabelas e colunas novas. Os dados antigos ficam.
      onUpgrade: (db, versaoAntiga, _) async {
        if (versaoAntiga < 2) {
          await _criarTabelaUsuarios(db);
          await _criarTabelaPets(db);
          await db.execute('ALTER TABLE atendimentos ADD COLUMN usuario_id INTEGER');
          await db.execute('ALTER TABLE atendimentos ADD COLUMN pet_id INTEGER');
          await db.execute('ALTER TABLE atendimentos ADD COLUMN hora TEXT');
          await _criarAdmin(db);
        }
      },
    );
  }

  static Future<void> _criarTabelaAtendimentos(Database db) async {
    await db.execute('''
      CREATE TABLE atendimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_pet TEXT NOT NULL,
        nome_tutor TEXT NOT NULL,
        servico TEXT NOT NULL,
        data TEXT NOT NULL,
        valor REAL NOT NULL,
        usuario_id INTEGER,
        pet_id INTEGER,
        hora TEXT
      )
    ''');
  }

  static Future<void> _criarTabelaUsuarios(Database db) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        perfil TEXT NOT NULL,
        telefone TEXT,
        cep TEXT,
        logradouro TEXT,
        numero TEXT,
        complemento TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT
      )
    ''');
  }

  static Future<void> _criarTabelaPets(Database db) async {
    await db.execute('''
      CREATE TABLE pets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        taxon_id INTEGER,
        nome_cientifico TEXT,
        foto_url TEXT,
        foto_atribuicao TEXT
      )
    ''');
  }

  // Cria a conta de administração, se ela ainda não existir
  static Future<void> _criarAdmin(Database db) async {
    final List<Map<String, Object?>> existente = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [emailAdmin],
    );
    if (existente.isEmpty) {
      await db.insert('usuarios', {
        'nome': 'Administrador',
        'email': emailAdmin,
        'senha_hash': Seguranca.gerarHash(senhaAdmin),
        'perfil': 'admin',
      });
    }
  }
}
