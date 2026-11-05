import 'package:flutter/material.dart';
import 'atendimento.dart';
import 'banco_de_dados.dart';

// Esta mesma tela serve para CADASTRAR e para EDITAR.
// Se receber um atendimento, está editando. Se não receber, está cadastrando.
class TelaFormulario extends StatefulWidget {
  final Atendimento? atendimento;

  const TelaFormulario({super.key, this.atendimento});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  // Chave que permite validar todos os campos de uma vez
  final GlobalKey<FormState> _chaveFormulario = GlobalKey<FormState>();

  // Um controller para cada campo de texto
  final TextEditingController _petController = TextEditingController();
  final TextEditingController _tutorController = TextEditingController();
  final TextEditingController _servicoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  // Guarda a data escolhida no calendário
  DateTime? _dataSelecionada;

  // Verdadeiro se estamos editando um atendimento que já existe
  bool get _estaEditando => widget.atendimento != null;

  @override
  void initState() {
    super.initState();

    // Se for edição, preenche os campos com os dados atuais
    if (_estaEditando) {
      Atendimento a = widget.atendimento!;
      _petController.text = a.nomePet;
      _tutorController.text = a.nomeTutor;
      _servicoController.text = a.servico;
      _valorController.text = a.valor.toStringAsFixed(2).replaceAll('.', ',');
      _dataSelecionada = DateTime.parse(a.data);
      _dataController.text = formatarData(a.data);
    }
  }

  @override
  void dispose() {
    _petController.dispose();
    _tutorController.dispose();
    _servicoController.dispose();
    _dataController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // Abre o calendário para escolher a data
  Future<void> _escolherData() async {
    DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (escolhida != null) {
      setState(() {
        _dataSelecionada = escolhida;
        _dataController.text = formatarData(dataParaTexto(escolhida));
      });
    }
  }

  Future<void> _salvar() async {
    // validate() roda os validators de todos os campos.
    // Se algum estiver errado, mostra a mensagem e para aqui.
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    // Troca vírgula por ponto para o Dart conseguir converter em número
    double valor = double.parse(_valorController.text.replaceAll(',', '.'));

    Atendimento atendimento = Atendimento(
      id: widget.atendimento?.id, // nulo no cadastro, preenchido na edição
      nomePet: _petController.text.trim(),
      nomeTutor: _tutorController.text.trim(),
      servico: _servicoController.text.trim(),
      data: dataParaTexto(_dataSelecionada!),
      valor: valor,
    );

    if (_estaEditando) {
      await BancoDeDados.atualizar(atendimento);
    } else {
      await BancoDeDados.inserir(atendimento);
    }

    // Confere se a tela ainda existe antes de usar o context depois de um await
    if (!mounted) return;

    // Fecha esta tela e volta para a listagem
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_estaEditando ? 'Editar atendimento' : 'Novo atendimento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _chaveFormulario,
          child: Column(
            children: [
              TextFormField(
                controller: _petController,
                decoration: const InputDecoration(
                  labelText: 'Nome do pet',
                  border: OutlineInputBorder(),
                ),
                validator: (texto) {
                  if (texto == null || texto.trim().isEmpty) {
                    return 'Informe o nome do pet';
                  }
                  return null; // null significa "campo válido"
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tutorController,
                decoration: const InputDecoration(
                  labelText: 'Nome do tutor',
                  border: OutlineInputBorder(),
                ),
                validator: (texto) {
                  if (texto == null || texto.trim().isEmpty) {
                    return 'Informe o nome do tutor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servicoController,
                decoration: const InputDecoration(
                  labelText: 'Serviço (ex.: banho, tosa, consulta)',
                  border: OutlineInputBorder(),
                ),
                validator: (texto) {
                  if (texto == null || texto.trim().isEmpty) {
                    return 'Informe o serviço';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                readOnly: true, // não digita, só escolhe no calendário
                onTap: _escolherData,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (texto) {
                  if (texto == null || texto.isEmpty) {
                    return 'Selecione a data';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (texto) {
                  if (texto == null || texto.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  double? valor = double.tryParse(texto.replaceAll(',', '.'));
                  if (valor == null || valor <= 0) {
                    return 'Informe um valor válido, maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: Text(_estaEditando ? 'Salvar alterações' : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}