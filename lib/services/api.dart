import 'dart:convert';

import 'package:http/http.dart' as http;

// Pedido GET em JSON com identificação do app e tempo limite.
// Lança exceção se a internet falhar ou o site responder com erro.
Future<dynamic> buscarJson(Uri uri) async {
  final http.Response resposta = await http
      .get(
        uri,
        headers: const {
          'User-Agent': 'PetShopApp/1.0 (aplicativo educacional)',
          'Accept': 'application/json',
        },
      )
      .timeout(const Duration(seconds: 10));

  if (resposta.statusCode != 200) {
    throw Exception('${uri.host} respondeu ${resposta.statusCode}');
  }
  return jsonDecode(utf8.decode(resposta.bodyBytes));
}
