// Um agendamento (atendimento) do pet shop. Cada objeto é uma linha da tabela `atendimentos`.
class Atendimento {
  final int? id;
  final String nomePet;
  final String nomeTutor;
  final String servico;
  final String data; // 2025-03-15
  final String? hora; // 09:30 (null nos atendimentos antigos)
  final double valor;
  final int? usuarioId; // cliente dono do atendimento (null nos antigos)
  final int? petId;

  const Atendimento({
    this.id,
    required this.nomePet,
    required this.nomeTutor,
    required this.servico,
    required this.data,
    required this.valor,
    this.hora,
    this.usuarioId,
    this.petId,
  });

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'nome_pet': nomePet,
      'nome_tutor': nomeTutor,
      'servico': servico,
      'data': data,
      'hora': hora,
      'valor': valor,
      'usuario_id': usuarioId,
      'pet_id': petId,
    };
  }

  factory Atendimento.deMapa(Map<String, dynamic> mapa) {
    return Atendimento(
      id: mapa['id'] as int?,
      nomePet: mapa['nome_pet'] as String,
      nomeTutor: mapa['nome_tutor'] as String,
      servico: mapa['servico'] as String,
      data: mapa['data'] as String,
      hora: mapa['hora'] as String?,
      valor: (mapa['valor'] as num).toDouble(),
      usuarioId: mapa['usuario_id'] as int?,
      petId: mapa['pet_id'] as int?,
    );
  }
}
