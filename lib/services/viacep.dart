import 'api.dart';

// Endereço encontrado pelo CEP
class EnderecoCep {
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;

  const EnderecoCep({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });
}

// Consulta de CEP no ViaCEP (viacep.com.br)
class ViaCep {
  // Devolve o endereço, ou null se o CEP não existir
  static Future<EnderecoCep?> buscar(String cep) async {
    final String numeros = cep.replaceAll(RegExp(r'\D'), '');
    final dados = await buscarJson(Uri.parse('https://viacep.com.br/ws/$numeros/json/'));

    if (dados['erro'] == true) {
      return null;
    }
    return EnderecoCep(
      logradouro: (dados['logradouro'] ?? '') as String,
      bairro: (dados['bairro'] ?? '') as String,
      cidade: (dados['localidade'] ?? '') as String,
      uf: (dados['uf'] ?? '') as String,
    );
  }
}
