import 'package:flutter/material.dart';

import '../../data/usuarios_repositorio.dart';
import '../../models/usuario.dart';
import '../../widgets/cabecalho.dart';
import '../../widgets/comuns.dart';
import 'navegacao.dart';
import 'tela_cadastro.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  bool _ocultarSenha = true;
  bool _entrando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _erro = null;
    });

    try {
      final Usuario? usuario = await RepositorioUsuarios.autenticar(_email.text, _senha.text);
      if (!mounted) return;

      if (usuario == null) {
        setState(() {
          _entrando = false;
          _erro = 'E-mail ou senha incorretos.';
        });
      } else {
        irParaPainel(context, usuario);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = 'Não foi possível entrar agora. Tente de novo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final String? erro = _erro;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FundoGradiente(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 56),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets_rounded, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pet Shop',
                        style: texto.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Entre para acompanhar os seus pets',
                        textAlign: TextAlign.center,
                        style: texto.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // O cartão sobe um pouco sobre o topo colorido
            Transform.translate(
              offset: const Offset(0, -28),
              child: LarguraMaxima(
                largura: 440,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CampoTexto(
                              controller: _email,
                              rotulo: 'E-mail',
                              icone: Icons.mail_outline_rounded,
                              teclado: TextInputType.emailAddress,
                              validator: obrigatorio('Informe o e-mail'),
                            ),
                            const SizedBox(height: 16),
                            CampoTexto(
                              controller: _senha,
                              rotulo: 'Senha',
                              icone: Icons.lock_outline_rounded,
                              senha: _ocultarSenha,
                              aoEnviar: (_) => _entrar(),
                              validator: obrigatorio('Informe a senha'),
                              sufixo: IconButton(
                                icon: Icon(
                                  _ocultarSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                                onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                              ),
                            ),
                            if (erro != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                erro,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: esquema.error, fontWeight: FontWeight.w600),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _entrando ? null : _entrar,
                              child: _entrando ? indicadorBotao() : const Text('Entrar'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _entrando
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const TelaCadastro()),
                                    ),
                              child: const Text('Não tem conta? Criar conta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
