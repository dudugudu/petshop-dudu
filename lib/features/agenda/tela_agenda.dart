import 'package:flutter/material.dart';

import '../../core/formatadores.dart';
import '../../core/sessao.dart';
import '../../data/atendimentos_repositorio.dart';
import '../../models/atendimento.dart';
import '../../widgets/comuns.dart';
import '../auth/navegacao.dart';
import 'calendario.dart';
import 'tela_formulario.dart';

// Agenda com calendário. O admin vê e edita todos os agendamentos.
// O cliente vê só os dos seus pets, sem poder editar.
class TelaAgenda extends StatefulWidget {
  const TelaAgenda({super.key});

  @override
  State<TelaAgenda> createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  DateTime _dia = somenteData(DateTime.now());
  List<Atendimento> _todos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final List<Atendimento> lista = await RepositorioAtendimentos.agenda(
      usuarioId: Sessao.ehAdmin ? null : Sessao.atual.id,
    );
    if (!mounted) return;
    setState(() {
      _todos = lista;
      _carregando = false;
    });
  }

  // Agendamentos do dia escolhido, do mais cedo para o mais tarde
  List<Atendimento> get _doDia {
    final String dia = dataParaTexto(_dia);
    return _todos.where((a) => a.data == dia).toList()
      ..sort((a, b) => (a.hora ?? '99:99').compareTo(b.hora ?? '99:99'));
  }

  Future<void> _abrirFormulario([Atendimento? atendimento]) async {
    final String? mensagem = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => TelaFormulario(atendimento: atendimento)),
    );
    if (!mounted) return;
    if (mensagem != null) mostrarAviso(context, mensagem);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final bool admin = Sessao.ehAdmin;
    final List<Atendimento> doDia = _doDia;
    final DateTime hoje = somenteData(DateTime.now());
    final String data = formatarData(dataParaTexto(_dia));
    final String titulo = _dia == hoje ? 'Hoje · $data' : data;

    return Scaffold(
      appBar: AppBar(
        title: Text(admin ? 'Agenda' : 'Agenda dos meus pets'),
        actions: const [BotaoSair(), SizedBox(width: 4)],
      ),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo agendamento'),
            )
          : null,
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : LarguraMaxima(
              largura: 720,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          child: CalendarioAgenda(
                            atendimentos: _todos,
                            diaSelecionado: _dia,
                            aoSelecionarDia: (dia) => setState(() => _dia = somenteData(dia)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(child: Text(titulo, style: texto.titleMedium)),
                          Etiqueta(
                            icone: Icons.event_note_outlined,
                            texto: doDia.length == 1
                                ? '1 agendamento'
                                : '${doDia.length} agendamentos',
                            fundo: esquema.secondaryContainer,
                            cor: esquema.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (doDia.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: EstadoVazio(
                          icone: Icons.event_available_outlined,
                          titulo: 'Nenhum agendamento neste dia',
                          mensagem: admin
                              ? 'Toque em "Novo agendamento" para marcar um atendimento.'
                              : 'Quando houver um agendamento para os seus pets, ele aparece aqui.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      sliver: SliverList.builder(
                        itemCount: doDia.length,
                        itemBuilder: (context, indice) => _CartaoAgendamento(
                          atendimento: doDia[indice],
                          admin: admin,
                          aoTocar: admin ? () => _abrirFormulario(doDia[indice]) : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

// Horário em destaque, pet, tutor e serviço. Valor só aparece para o admin.
class _CartaoAgendamento extends StatelessWidget {
  final Atendimento atendimento;
  final bool admin;
  final VoidCallback? aoTocar;

  const _CartaoAgendamento({required this.atendimento, required this.admin, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: esquema.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    atendimento.hora ?? '--:--',
                    style: texto.titleMedium?.copyWith(
                      color: esquema.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        atendimento.nomePet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.titleMedium,
                      ),
                      Text(
                        admin ? 'Tutor: ${atendimento.nomeTutor}' : atendimento.servico,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                      if (admin) ...[
                        const SizedBox(height: 6),
                        Etiqueta(
                          icone: Icons.spa_outlined,
                          texto: atendimento.servico,
                          fundo: esquema.secondaryContainer,
                          cor: esquema.onSecondaryContainer,
                        ),
                      ],
                    ],
                  ),
                ),
                if (admin)
                  Text(
                    formatarMoeda(atendimento.valor),
                    style: texto.titleSmall?.copyWith(
                      color: esquema.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
