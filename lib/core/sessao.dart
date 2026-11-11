import '../models/usuario.dart';

// Quem está usando o app agora. Fica só na memória: ao fechar o app, é preciso entrar de novo.
class Sessao {
  static Usuario? _usuario;

  static Usuario get atual => _usuario ?? (throw StateError('Ninguém está logado.'));

  static bool get ehAdmin => _usuario?.ehAdmin ?? false;

  static void iniciar(Usuario usuario) => _usuario = usuario;

  static void encerrar() => _usuario = null;
}
