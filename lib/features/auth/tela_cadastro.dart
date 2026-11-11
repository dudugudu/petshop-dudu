import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/usuarios_repositorio.dart';
import '../../models/usuario.dart';
import '../../services/viacep.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';
import 'navegacao.dart';

// Cadastro de cliente. Digitar os 8 números do CEP preenche o endereço (ViaCEP).
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmar = TextEditingController();
  final TextEditingController _telefone = TextEditingController();
  final TextEditingController _cep = TextEditingController();
  final TextEditingController _logradouro = TextEditingController();
  final TextEditingController _numero = TextEditingController();
  final TextEditingController _complemento = TextEditingController();
  final TextEditingController _bairro = TextEditingController();
  final TextEditingController _cidade = TextEditingController();
  final TextEditingController _uf = TextEditingController();

  bool _buscandoCep = false;
  bool _salvando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    for (final controller in [
      _nome, _email, _senha, _confirmar, _telefone, _cep, _logradouro,
      _numero, _complemento, _bairro, _cidade, _uf,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final String cep = _cep.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8 || _buscandoCep) return;
    setState(() => _buscandoCep = true);

    try {
      final EnderecoCep? endereco = await ViaCep.buscar(cep);
      if (!mounted) return;
      if (endereco == null) {
        mostrarAviso(context, 'CEP não encontrado. Confira o número.');
      } else {
        // Alguns CEPs são de cidade inteira e não têm rua nem bairro.
        // Nesse caso só a cidade e a UF são preenchidas, sem apagar o que já foi digitado.
        if (endereco.logradouro.isNotEmpty) _logradouro.text = endereco.logradouro;
        if (endereco.bairro.isNotEmpty) _bairro.text = endereco.bairro;
        _cidade.text = endereco.cidade;
        _uf.text = endereco.uf;
        mostrarAviso(
          context,
          endereco.logradouro.isEmpty
              ? 'Este CEP não tem rua cadastrada. Digite a rua e o bairro.'
              : 'Endereço preenchido. Complete o número.',
        );
      }
    } catch (_) {
      if (mounted) {
        mostrarAviso(context, 'Não foi possível consultar o CEP agora. Preencha o endereço à mão.');
      }
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  Future<void> _criarConta() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
      final String email = _email.text.trim().toLowerCase();
      if (await RepositorioUsuarios.buscarPorEmail(email) != null) {
        if (!mounted) return;
        setState(() => _salvando = false);
        mostrarAviso(context, 'Este e-mail já está cadastrado.');
        return;
      }

      final Usuario usuario = await RepositorioUsuarios.cadastrarCliente(
        nome: _nome.text,
        email: email,
        senha: _senha.text,
        telefone: _telefone.text,
        cep: _cep.text,
        logradouro: _logradouro.text,
        numero: _numero.text,
        complemento: _complemento.text,
        bairro: _bairro.text,
        cidade: _cidade.text,
        uf: _uf.text,
      );
      if (mounted) irParaPainel(context, usuario);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarAviso(context, 'Não foi possível criar a conta. Tente de novo.');
    }
  }

  String? _validarEmail(String? texto) {
    final String? vazio = obrigatorio('Informe o e-mail')(texto);
    if (vazio != null) return vazio;
    final bool valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto!.trim());
    return valido ? null : 'Informe um e-mail válido';
  }

  String? _validarCep(String? texto) {
    final String digitos = (texto ?? '').replaceAll(RegExp(r'\D'), '');
    return digitos.length == 8 ? null : 'Informe um CEP com 8 números';
  }

  String? _validarUf(String? texto) {
    final String? vazio = obrigatorio('Informe a UF')(texto);
    if (vazio != null) return vazio;
    return texto!.trim().length == 2 ? null : 'Use 2 letras';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      bottomNavigationBar: BotaoRodape(
        texto: _salvando ? 'Criando conta...' : 'Criar conta',
        icone: _salvando ? indicadorBotao() : const Icon(Icons.check_rounded),
        aoApertar: _salvando ? null : _criarConta,
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
                  icone: Icons.lock_outline_rounded,
                  titulo: 'Acesso',
                  filhos: [
                    CampoTexto(
                      controller: _nome,
                      rotulo: 'Seu nome completo',
                      icone: Icons.person_outline_rounded,
                      maiusculas: TextCapitalization.words,
                      validator: obrigatorio('Informe o seu nome'),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _email,
                      rotulo: 'E-mail',
                      icone: Icons.mail_outline_rounded,
                      teclado: TextInputType.emailAddress,
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _senha,
                      rotulo: 'Senha (mínimo 6 caracteres)',
                      icone: Icons.key_outlined,
                      senha: _ocultarSenha,
                      validator: (texto) => (texto ?? '').length < 6
                          ? 'A senha precisa de pelo menos 6 caracteres'
                          : null,
                      sufixo: IconButton(
                        icon: Icon(
                          _ocultarSenha
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _confirmar,
                      rotulo: 'Confirme a senha',
                      icone: Icons.key_outlined,
                      senha: _ocultarSenha,
                      validator: (texto) => texto == _senha.text ? null : 'As senhas não são iguais',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SecaoCartao(
                  icone: Icons.phone_outlined,
                  titulo: 'Contato',
                  filhos: [
                    CampoTexto(
                      controller: _telefone,
                      rotulo: 'Telefone (opcional)',
                      icone: Icons.phone_iphone_rounded,
                      teclado: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SecaoCartao(
                  icone: Icons.home_outlined,
                  titulo: 'Endereço',
                  filhos: [
                    CampoTexto(
                      controller: _cep,
                      rotulo: 'CEP',
                      dica: 'Somente números',
                      icone: Icons.markunread_mailbox_outlined,
                      teclado: TextInputType.number,
                      formatadores: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      aoMudar: (texto) {
                        if (texto.length == 8) _buscarCep();
                      },
                      validator: _validarCep,
                      sufixo: _buscandoCep
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search_rounded),
                              tooltip: 'Buscar CEP',
                              onPressed: _buscarCep,
                            ),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _logradouro,
                      rotulo: 'Rua / avenida',
                      icone: Icons.signpost_outlined,
                      maiusculas: TextCapitalization.words,
                      validator: obrigatorio('Informe a rua'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CampoTexto(
                            controller: _numero,
                            rotulo: 'Número',
                            validator: obrigatorio('Informe o número'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CampoTexto(
                            controller: _complemento,
                            rotulo: 'Complemento (opcional)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controller: _bairro,
                      rotulo: 'Bairro',
                      icone: Icons.map_outlined,
                      maiusculas: TextCapitalization.words,
                      validator: obrigatorio('Informe o bairro'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CampoTexto(
                            controller: _cidade,
                            rotulo: 'Cidade',
                            maiusculas: TextCapitalization.words,
                            validator: obrigatorio('Informe a cidade'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CampoTexto(
                            controller: _uf,
                            rotulo: 'UF',
                            maiusculas: TextCapitalization.characters,
                            formatadores: [LengthLimitingTextInputFormatter(2)],
                            validator: _validarUf,
                          ),
                        ),
                      ],
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
