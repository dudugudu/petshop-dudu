import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sessao.dart';
import '../../data/pets_repositorio.dart';
import '../../models/pet.dart';
import '../../models/tipo_animal.dart';
import '../../services/inaturalist.dart';
import '../../widgets/avatares.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';

// Cadastro de pet. A espécie é escolhida numa busca no iNaturalist.
class TelaCadastroPet extends StatefulWidget {
  const TelaCadastroPet({super.key});

  @override
  State<TelaCadastroPet> createState() => _TelaCadastroPetState();
}

class _TelaCadastroPetState extends State<TelaCadastroPet> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _busca = TextEditingController();

  // Espera a pessoa parar de digitar antes de consultar a API
  Timer? _temporizador;

  // Conta as buscas. Só a resposta da última busca é mostrada.
  int _consulta = 0;

  bool _buscando = false;
  String? _erroBusca;
  List<TipoAnimal> _resultados = [];

  TipoAnimal? _escolhido;
  String? _erroTipo;
  bool _salvando = false;

  @override
  void dispose() {
    _temporizador?.cancel();
    _nome.dispose();
    _busca.dispose();
    super.dispose();
  }

  void _digitouBusca(String texto) {
    _temporizador?.cancel();
    _temporizador = Timer(const Duration(milliseconds: 500), () => _buscar(texto));
  }

  Future<void> _buscar(String termo) async {
    final String limpo = termo.trim();
    final int consulta = ++_consulta;

    // Com menos de 3 letras, a busca vem vaga demais
    if (limpo.length < 3) {
      setState(() {
        _resultados = [];
        _buscando = false;
        _erroBusca = null;
      });
      return;
    }

    setState(() {
      _buscando = true;
      _erroBusca = null;
    });
    try {
      final List<TipoAnimal> lista = await INaturalist.buscarAnimais(limpo);
      if (!mounted || consulta != _consulta) return;
      setState(() {
        _resultados = lista;
        _buscando = false;
      });
    } catch (_) {
      if (!mounted || consulta != _consulta) return;
      setState(() {
        _buscando = false;
        _erroBusca = 'Não foi possível buscar os animais agora. Verifique a sua internet.';
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;
    final TipoAnimal? tipo = _escolhido;
    if (tipo == null) {
      setState(() => _erroTipo = 'Escolha o tipo do animal na lista.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await RepositorioPets.inserir(
        Pet(
          usuarioId: Sessao.atual.id!,
          nome: _nome.text.trim(),
          tipo: tipo.nomeExibicao,
          taxonId: tipo.id,
          nomeCientifico: tipo.nomeCientifico,
          fotoUrl: tipo.fotoUrl,
          fotoAtribuicao: tipo.atribuicao,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarAviso(context, 'Não foi possível salvar o pet. Tente de novo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final TipoAnimal? escolhido = _escolhido;
    final bool buscou = _busca.text.trim().length >= 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo pet')),
      bottomNavigationBar: BotaoRodape(
        texto: 'Salvar pet',
        icone: const Icon(Icons.check_rounded),
        aoApertar: _salvando ? null : _salvar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: LarguraMaxima(
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SecaoCartao(
                  icone: Icons.pets_rounded,
                  titulo: 'Dados do pet',
                  filhos: [
                    CampoTexto(
                      controller: _nome,
                      rotulo: 'Nome do pet',
                      icone: Icons.badge_outlined,
                      validator: obrigatorio('Informe o nome do pet'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SecaoCartao(
                  icone: Icons.travel_explore_rounded,
                  titulo: 'Tipo do animal',
                  filhos: escolhido != null
                      ? [
                          _CartaoAnimal(
                            tipo: escolhido,
                            destaque: true,
                            acao: TextButton(
                              onPressed: () => setState(() => _escolhido = null),
                              child: const Text('Trocar'),
                            ),
                          ),
                        ]
                      : [
                          TextField(
                            controller: _busca,
                            onChanged: _digitouBusca,
                            decoration: const InputDecoration(
                              hintText: 'Digite o animal (ex.: gato, cão, papagaio)',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          ),
                          if (_buscando) ...[
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(),
                          ],
                          if (_erroBusca != null) ...[
                            const SizedBox(height: 12),
                            Text(_erroBusca!, style: TextStyle(color: esquema.error)),
                          ],
                          if (!_buscando && _erroBusca == null && buscou && _resultados.isEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum animal encontrado com esse nome.',
                              style: texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                            ),
                          ],
                          for (final TipoAnimal resultado in _resultados)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _CartaoAnimal(
                                tipo: resultado,
                                aoTocar: () => setState(() {
                                  _escolhido = resultado;
                                  _erroTipo = null;
                                }),
                                acao: Icon(Icons.chevron_right_rounded, color: esquema.outline),
                              ),
                            ),
                          if (_erroTipo != null) ...[
                            const SizedBox(height: 8),
                            Text(_erroTipo!, style: TextStyle(color: esquema.error)),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            'Espécies e fotos: iNaturalist (inaturalist.org)',
                            style: texto.labelSmall?.copyWith(color: esquema.outline),
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

// Espécie em um cartão: foto, nome, nome científico e uma ação no final
class _CartaoAnimal extends StatelessWidget {
  final TipoAnimal tipo;
  final bool destaque;
  final VoidCallback? aoTocar;
  final Widget acao;

  const _CartaoAnimal({
    required this.tipo,
    required this.acao,
    this.destaque = false,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;

    return Material(
      color: destaque
          ? esquema.primaryContainer.withValues(alpha: 0.5)
          : esquema.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              FotoPet(url: tipo.fotoUrl, tamanho: destaque ? 56 : 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tipo.nomeExibicao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.titleSmall,
                    ),
                    Text(
                      tipo.nomeCientifico,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                    if (destaque && tipo.atribuicao != null)
                      Text(
                        'Foto: ${tipo.atribuicao}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.labelSmall?.copyWith(color: esquema.outline),
                      ),
                  ],
                ),
              ),
              acao,
            ],
          ),
        ),
      ),
    );
  }
}
