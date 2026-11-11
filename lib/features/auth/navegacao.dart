import 'package:flutter/material.dart';

import '../../core/sessao.dart';
import '../../models/usuario.dart';
import '../admin/painel_admin.dart';
import '../cliente/painel_cliente.dart';
import 'tela_login.dart';

// Entra na conta e vai para o painel certo. Apaga login e cadastro da pilha.
void irParaPainel(BuildContext context, Usuario usuario) {
  Sessao.iniciar(usuario);
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => usuario.ehAdmin ? const PainelAdmin() : const PainelCliente(),
    ),
    (_) => false,
  );
}

// Encerra a sessão e volta para o login
void sairDaConta(BuildContext context) {
  Sessao.encerrar();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const TelaLogin()),
    (_) => false,
  );
}

// Botão de sair que aparece na barra superior das telas
class BotaoSair extends StatelessWidget {
  const BotaoSair({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: 'Sair',
      onPressed: () => sairDaConta(context),
    );
  }
}
