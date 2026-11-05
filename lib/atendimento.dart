// Classe que representa UM atendimento do pet shop.
// Cada objeto desta classe corresponde a UMA linha da tabela do SQLite.
class Atendimento {
  int? id; // o id é criado pelo banco, por isso pode ser nulo (int?)
  String nomePet;
  String nomeTutor;
  String servico;
  String data; // guardada como texto no formato 2025-03-15 (ano-mês-dia)
  double valor;

  Atendimento({
    this.id,
    required this.nomePet,
    required this.nomeTutor,
    required this.servico,
    required this.data,
    required this.valor,
  });

  // Converte o objeto em Map para poder salvar no banco.
  // As chaves precisam ter o mesmo nome das colunas da tabela.
  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'nome_pet': nomePet,
      'nome_tutor': nomeTutor,
      'servico': servico,
      'data': data,
      'valor': valor,
    };
  }

  // Faz o caminho contrário: transforma o Map que veio do banco em objeto.
  factory Atendimento.deMapa(Map<String, dynamic> mapa) {
    return Atendimento(
      id: mapa['id'],
      nomePet: mapa['nome_pet'],
      nomeTutor: mapa['nome_tutor'],
      servico: mapa['servico'],
      data: mapa['data'],
      valor: (mapa['valor'] as num).toDouble(),
    );
  }
}

// ---------- Funções auxiliares de formatação ----------

// Transforma um DateTime em texto para salvar no banco: 2025-03-15
String dataParaTexto(DateTime data) {
  String mes = data.month.toString().padLeft(2, '0');
  String dia = data.day.toString().padLeft(2, '0');
  return '${data.year}-$mes-$dia';
}

// Transforma o texto do banco (2025-03-15) em texto para mostrar: 15/03/2025
String formatarData(String dataDoBanco) {
  List<String> partes = dataDoBanco.split('-');
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}

// Transforma 50.5 em "R$ 50,50"
String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}