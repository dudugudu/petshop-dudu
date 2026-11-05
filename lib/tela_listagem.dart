import 'package:flutter/material.dart';
import 'atendimento.dart';
import 'banco_de_dados.dart';
import 'tela_formulario.dart';
import 'tela_resumo.dart';

class TelaListagem extends StatefulWidget {
  const TelaListagem({super.key});

  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  // Controller do campo de pesquisa
  final TextEditingController _pesquisaController = TextEditingController();

  // Lista que aparece na tela
  List<Atendimento> _atendimentos = [];

  // initState roda uma vez, quando a tela é criada
  @override
  void initState() {
    super.initState();
    _carregarAtendimentos();
  }

  // Libera o controller da memória quando a tela for fechada
  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // Busca no banco (usando o texto digitado na pesquisa) e atualiza a tela
  Future<void> _carregarAtendimentos() async {
    List<Atendimento> lista = await BancoDeDados.listar(
      _pesquisaController.text.trim(),
    );
    setState(() {
      _atendimentos = lista;
    });
  }

  // Abre a tela de cadastro (atendimento == null) ou de edição (com atendimento)
  Future<void> _abrirFormulario({Atendimento? atendimento}) async {
    // await espera a tela de formulário fechar (Navigator.pop)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaFormulario(atendimento: atendimento),
      ),
    );
    // Quando voltar, recarrega a lista para mostrar as mudanças
    _carregarAtendimentos();
  }

  void _abrirResumo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaResumo()),
    );
  }

  // Pergunta se o usuário quer mesmo excluir
  Future<void> _confirmarExclusao(Atendimento atendimento) async {
    bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atendimento'),
        content: Text('Deseja excluir o atendimento de ${atendimento.nomePet}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await BancoDeDados.excluir(atendimento.id!);
      _carregarAtendimentos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'Resumo financeiro',
            onPressed: _abrirResumo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por pet ou tutor',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // A cada letra digitada, a lista é filtrada
              onChanged: (texto) => _carregarAtendimentos(),
            ),
          ),

          // Lista de atendimentos
          Expanded(
            child: _atendimentos.isEmpty
                ? const Center(child: Text('Nenhum atendimento encontrado.'))
                : ListView.builder(
                    itemCount: _atendimentos.length,
                    itemBuilder: (context, indice) {
                      Atendimento atendimento = _atendimentos[indice];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            '${atendimento.nomePet} (${atendimento.servico})',
                          ),
                          subtitle: Text(
                            'Tutor: ${atendimento.nomeTutor}\n'
                            '${formatarData(atendimento.data)} - '
                            '${formatarMoeda(atendimento.valor)}',
                          ),
                          isThreeLine: true,
                          // Tocar no item abre a edição
                          onTap: () => _abrirFormulario(atendimento: atendimento),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarExclusao(atendimento),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}