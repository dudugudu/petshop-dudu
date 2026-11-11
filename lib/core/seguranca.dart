import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

// Senhas nunca são guardadas em texto puro: usamos PBKDF2 com SHA-256 e um sal aleatório.
class Seguranca {
  static const int _iteracoes = 10000;

  // Formato guardado no banco: pbkdf2:iterações:sal:chave
  static String gerarHash(String senha) {
    final Random aleatorio = Random.secure();
    final List<int> sal = List.generate(16, (_) => aleatorio.nextInt(256));
    final List<int> chave = _pbkdf2(utf8.encode(senha), sal, _iteracoes);
    return 'pbkdf2:$_iteracoes:${base64Encode(sal)}:${base64Encode(chave)}';
  }

  static bool conferir(String senha, String hashGuardado) {
    final List<String> partes = hashGuardado.split(':');
    if (partes.length != 4 || partes[0] != 'pbkdf2') {
      return false;
    }
    final List<int> calculada = _pbkdf2(
      utf8.encode(senha),
      base64Decode(partes[2]),
      int.parse(partes[1]),
    );
    return _iguais(calculada, base64Decode(partes[3]));
  }

  // PBKDF2 com saída de 32 bytes (o tamanho do SHA-256)
  static List<int> _pbkdf2(List<int> senha, List<int> sal, int iteracoes) {
    final Hmac hmac = Hmac(sha256, senha);
    List<int> u = hmac.convert([...sal, 0, 0, 0, 1]).bytes;
    final List<int> resultado = [...u];
    for (int i = 1; i < iteracoes; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < resultado.length; j++) {
        resultado[j] ^= u[j];
      }
    }
    return resultado;
  }

  // Compara sem parar no primeiro byte diferente
  static bool _iguais(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    int diferenca = 0;
    for (int i = 0; i < a.length; i++) {
      diferenca |= a[i] ^ b[i];
    }
    return diferenca == 0;
  }
}
