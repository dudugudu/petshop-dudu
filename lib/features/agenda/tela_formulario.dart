import 'package:flutter/material.dart';

import '../../core/formatadores.dart';
import '../../data/atendimentos_repositorio.dart';
import '../../data/pets_repositorio.dart';
import '../../data/usuarios_repositorio.dart';
import '../../models/atendimento.dart';
import '../../models/pet.dart';
import '../../models/usuario.dart';
import '../../widgets/avatares.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';

// Novo agendamento ou edição. O agendamento fica ligado a um cliente e a um pet dele.
class TelaFormulario extends StatefulWidget {
  final Atendimento? atendimento;

  const TelaFormulario({super.key, this.atendimento});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _servico = TextEditingController();
  final TextEditingController _data = TextEditingController();
  final TextEditingController _hora = TextEditingController();
  final TextEditingController _valor = TextEditingController();

  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;

  List<Usuario> _clientes = [];
  bool _carregandoClientes = true;
  Usuario? _cliente;

  List<Pet> _pets = [];
  bool _carregandoPets = false;
  Pet? _pet;

  // Conta as trocas de cliente. Só a última resposta de pets é usada.
  int _consultaPets = 0;

  bool get _editando => widget.atendimento != null;

  @override
  void initState() {
    super.initState();
    final Atendimento? atual = widget.atendimento;
    if (atual != null) {
      _servico.text = atual.servico;
      _valor.text = atual.valor.toStringAsFixed(2).replaceAll('.', ',');
      _dataSelecionada = DateTime.parse(atual.data);
      _data.text = formatarData(atual.data);
      final String? hora = atual.hora;
      if (hora != null) {
        _horaSelecionada = textoParaHora(hora);
        _hora.text = hora;
      }
    }
    _carregarClientes();
  }

  @override
  void dispose() {
    for (final controller in [_servico, _data, _hora, _valor]) {
      controller.dispose();
    }
    super.dispose();
  }

  // Na edição, também escolhe o cliente e o pet que já estavam no agendamento
  Future<void> _carregarClientes() async {
    final List<Usuario> lista = await RepositorioUsuarios.listarClientes();
    if (!mounted) return;
    setState(() {
      _clientes = lista;
      _carregandoClientes = false;
    });

    final int? clienteId = widget.atendimento?.usuarioId;
    final Usuario? cliente = lista.where((c) => c.id == clienteId).firstOrNull;
    if (cliente != null) {
      await _escolherCliente(cliente, petInicial: widget.atendimento?.petId);
    }
  }

  Future<void> _escolherCliente(Usuario cliente, {int? petInicial}) async {
    final int consulta = ++_consultaPets;
    setState(() {
      _cliente = cliente;
      _pets = [];
      _pet = null;
      _carregandoPets = true;
    });

    final List<Pet> pets = await RepositorioPets.listarDoUsuario(cliente.id!);
    if (!mounted || consulta != _consultaPets) return;
    setState(() {
      _pets = pets;
      _carregandoPets = false;
      _pet = pets.where((p) => p.id == petInicial).firstOrNull;
    });
  }

  Future<void> _escolherData() async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (escolhida == null) return;
    setState(() {
      _dataSelecionada = escolhida;
      _data.text = formatarData(dataParaTexto(escolhida));
    });
  }

  Future<void> _escolherHora() async {
    final TimeOfDay? escolhida = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Horário do atendimento',
    );
    if (escolhida == null) return;
    setState(() {
      _horaSelecionada = escolhida;
      _hora.text = horaParaTexto(escolhida);
    });
  }

  String? _validarValor(String? texto) {
    final String? vazio = obrigatorio('Informe o valor')(texto);
    if (vazio != null) return vazio;
    final double? valor = double.tryParse(texto!.replaceAll(',', '.'));
    return valor == null || valor <= 0 ? 'Informe um valor válido, maior que zero' : null;
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    final Usuario cliente = _cliente!;
    final Pet pet = _pet!;
    await RepositorioAtendimentos.salvar(
      Atendimento(
        id: widget.atendimento?.id,
        usuarioId: cliente.id,
        petId: pet.id,
        nomePet: pet.nome,
        nomeTutor: cliente.nome,
        servico: _servico.text.trim(),
        data: dataParaTexto(_dataSelecionada!),
        hora: horaParaTexto(_horaSelecionada!),
        valor: double.parse(_valor.text.replaceAll(',', '.')),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, _editando ? 'Agendamento atualizado.' : 'Agendamento cadastrado.');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final int? id = widget.atendimento?.id;

    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar agendamento' : 'Novo agendamento')),
      bottomNavigationBar: BotaoRodape(
        texto: _editando ? 'Salvar alterações' : 'Agendar atendimento',
        icone: Icon(_editando ? Icons.check_rounded : Icons.add_rounded),
        aoApertar: _salvar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: LarguraMaxima(
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AvatarPet(
                    nome: _pet?.nome ?? '',
                    raio: 44,
                    tag: id == null ? null : tagAvatar(id),
                  ),
                ),
                const SizedBox(height: 20),

                SecaoCartao(
                  icone: Icons.pets_rounded,
                  titulo: 'Cliente e pet',
                  filhos: [
                    DropdownButtonFormField<int>(
                      key: ValueKey('cliente-${_cliente?.id}'),
                      initialValue: _cliente?.id,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cliente (tutor)',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      hint: Text(
                        _carregandoClientes
                            ? 'Carregando clientes...'
                            : (_clientes.isEmpty ? 'Nenhum cliente cadastrado' : 'Escolha o cliente'),
                      ),
                      items: [
                        for (final Usuario cliente in _clientes)
                          DropdownMenuItem<int>(
                            value: cliente.id,
                            child: Text(cliente.nome, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (id) {
                        final Usuario? escolhido = _clientes.where((c) => c.id == id).firstOrNull;
                        if (escolhido != null) _escolherCliente(escolhido);
                      },
                      validator: (valor) => valor == null ? 'Escolha o cliente' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      key: ValueKey('pet-${_cliente?.id}-${_pet?.id}'),
                      initialValue: _pet?.id,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pet',
                        prefixIcon: Icon(Icons.pets_outlined),
                      ),
                      hint: Text(
                        _cliente == null
                            ? 'Escolha antes o cliente'
                            : (_carregandoPets ? 'Carregando pets...' : 'Escolha o pet'),
                      ),
                      items: [
                        for (final Pet pet in _pets)
                          DropdownMenuItem<int>(
                            value: pet.id,
                            child: Text(
                              '${pet.nome} (${pet.tipo})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) => setState(() => _pet = _pets.where((p) => p.id == id).firstOrNull),
                      validator: (valor) => valor == null ? 'Escolha o pet' : null,
                    ),
                    if (_cliente != null && !_carregandoPets && _pets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Este cliente ainda não cadastrou nenhum pet.',
                          style: texto.bodySmall?.copyWith(color: esquema.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                SecaoCartao(
                  icone: Icons.receipt_long_rounded,
                  titulo: 'Atendimento',
                  filhos: [
                    CampoTexto(
                      controller: _servico,
                      rotulo: 'Serviço (ex.: banho, tosa, consulta)',
                      icone: Icons.spa_outlined,
                      validator: obrigatorio('Informe o serviço'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CampoTexto(
                            controller: _data,
                            rotulo: 'Data',
                            icone: Icons.calendar_month_outlined,
                            somenteLeitura: true,
                            aoTocar: _escolherData,
                            validator: obrigatorio('Selecione a data'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CampoTexto(
                            controller: _hora,
                            rotulo: 'Horário',
                            icone: Icons.schedule_rounded,
                            somenteLeitura: true,
                            aoTocar: _escolherHora,
                            validator: obrigatorio('Escolha o horário'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _valor,
                      rotulo: 'Valor (R\$)',
                      icone: Icons.payments_outlined,
                      teclado: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validarValor,
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
