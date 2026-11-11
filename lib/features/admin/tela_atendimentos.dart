import 'package:flutter/material.dart';

import '../../core/formatadores.dart';
import '../../data/atendimentos_repositorio.dart';
import '../../models/atendimento.dart';
import '../../widgets/avatares.dart';
import '../../widgets/cabecalho.dart';
import '../../widgets/comuns.dart';
import '../agenda/tela_formulario.dart';
import '../auth/navegacao.dart';
import 'tela_resumo.dart';

// Lista de todos os atendimentos, com busca, totais e ações de editar e excluir
class TelaAtendimentos extends StatefulWidget {
  const TelaAtendimentos({super.key});

  @override
  State<TelaAtendimentos> createState() => _TelaAtendimentosState();
}

class _TelaAtendimentosState extends State<TelaAtendimentos> {
  final TextEditingController _busca = TextEditingController();
  List<Atendimento> _lista = [];
  double _faturamento = 0;
  int _quantidade = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizarTudo();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregarLista() async {
    final List<Atendimento> lista = await RepositorioAtendimentos.buscar(_busca.text.trim());
    if (!mounted) return;
    setState(() {
      _lista = lista;
      _carregando = false;
    });
  }

  Future<void> _carregarTotais() async {
    final double total = await RepositorioAtendimentos.faturamentoTotal();
    final int quantidade = await RepositorioAtendimentos.quantidade();
    if (!mounted) return;
    setState(() {
      _faturamento = total;
      _quantidade = quantidade;
    });
  }

  Future<void> _atualizarTudo() async {
    await _carregarLista();
    await _carregarTotais();
  }

  Future<void> _abrirFormulario([Atendimento? atendimento]) async {
    final String? mensagem = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => TelaFormulario(atendimento: atendimento)),
    );
    if (!mounted) return;
    if (mensagem != null) mostrarAviso(context, mensagem);
    await _atualizarTudo();
  }

  Future<void> _excluir(Atendimento atendimento) async {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded, color: esquema.error, size: 32),
        title: const Text('Excluir atendimento'),
        content: Text('Deseja excluir o atendimento de ${atendimento.nomePet}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: esquema.error,
              foregroundColor: esquema.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await RepositorioAtendimentos.excluir(atendimento.id!);
    if (!mounted) return;
    mostrarAviso(context, 'Atendimento excluído.');
    await _atualizarTudo();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;
    final double topo = MediaQuery.paddingOf(context).top;
    final double largura = MediaQuery.sizeOf(context).width;
    final double margem = largura > 760 ? (largura - 720) / 2 : 16;
    final bool buscando = _busca.text.trim().isNotEmpty;
    final OutlineInputBorder semLinha = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo atendimento'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: topo + 276,
            title: const Text('Atendimentos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                tooltip: 'Resumo financeiro',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaResumo()),
                ),
              ),
              const BotaoSair(),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FundoGradiente(
              child: Padding(
                padding: EdgeInsets.fromLTRB(margem, topo + kToolbarHeight + 8, margem, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visão geral',
                      style: texto.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricaVidro(
                            icone: Icons.payments_outlined,
                            rotulo: 'Faturamento',
                            valor: formatarMoeda(_faturamento),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricaVidro(
                            icone: Icons.event_available_outlined,
                            rotulo: 'Atendimentos',
                            valor: '$_quantidade',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: EdgeInsets.fromLTRB(margem, 4, margem, 16),
                child: TextField(
                  controller: _busca,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar pet ou tutor',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search_rounded),
                    prefixIconColor: Colors.white,
                    suffixIconColor: Colors.white,
                    suffixIcon: buscando
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _busca.clear();
                              setState(() {});
                              _carregarLista();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: semLinha,
                    enabledBorder: semLinha,
                    focusedBorder: semLinha,
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _carregarLista();
                  },
                ),
              ),
            ),
          ),

          if (_carregando)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),

          if (!_carregando && _lista.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: buscando
                  ? EstadoVazio(
                      icone: Icons.search_off_rounded,
                      titulo: 'Nenhum resultado',
                      mensagem: 'Não encontramos nada para "${_busca.text.trim()}".',
                    )
                  : EstadoVazio(
                      icone: Icons.pets_rounded,
                      titulo: 'Nenhum atendimento ainda',
                      mensagem: 'Cadastre o primeiro atendimento do seu pet shop.',
                      textoBotao: 'Cadastrar atendimento',
                      aoApertar: () => _abrirFormulario(),
                    ),
            ),

          if (!_carregando && _lista.isNotEmpty)
            SliverPadding(
              // Espaço embaixo para o último item não ficar atrás do botão +
              padding: EdgeInsets.fromLTRB(margem, 16, margem, 100),
              sliver: SliverList.builder(
                itemCount: _lista.length,
                itemBuilder: (context, indice) {
                  final Atendimento atendimento = _lista[indice];
                  // Cada item entra deslizando de baixo, com fade
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(atendimento.id),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, valor, filho) => Opacity(
                      opacity: valor,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - valor)),
                        child: filho,
                      ),
                    ),
                    child: _CartaoAtendimento(
                      atendimento: atendimento,
                      aoTocar: () => _abrirFormulario(atendimento),
                      aoExcluir: () => _excluir(atendimento),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Avatar, pet, tutor, serviço, data, valor e botão de excluir
class _CartaoAtendimento extends StatelessWidget {
  final Atendimento atendimento;
  final VoidCallback aoTocar;
  final VoidCallback aoExcluir;

  const _CartaoAtendimento({
    required this.atendimento,
    required this.aoTocar,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final Color cinza = esquema.onSurfaceVariant;
    final String data = atendimento.hora == null
        ? formatarData(atendimento.data)
        : '${formatarData(atendimento.data)} · ${atendimento.hora}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPet(
                  nome: atendimento.nomePet,
                  raio: 26,
                  tag: tagAvatar(atendimento.id!),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 15, color: cinza),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              atendimento.nomeTutor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: texto.bodyMedium?.copyWith(color: cinza),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Etiqueta(
                            icone: Icons.spa_outlined,
                            texto: atendimento.servico,
                            fundo: esquema.secondaryContainer,
                            cor: esquema.onSecondaryContainer,
                          ),
                          Etiqueta(
                            icone: Icons.calendar_today_outlined,
                            texto: data,
                            fundo: esquema.surfaceContainerHigh,
                            cor: cinza,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatarMoeda(atendimento.valor),
                      style: texto.titleMedium?.copyWith(
                        color: esquema.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: esquema.error),
                      tooltip: 'Excluir',
                      visualDensity: VisualDensity.compact,
                      onPressed: aoExcluir,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
