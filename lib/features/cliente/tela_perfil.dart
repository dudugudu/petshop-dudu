import 'package:flutter/material.dart';

import '../../core/sessao.dart';
import '../../models/usuario.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';
import '../auth/navegacao.dart';

// Dados da conta de quem está logado e o endereço
class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Sessao.atual;
    final TextTheme texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: const [BotaoSair(), SizedBox(width: 4)],
      ),
      body: LarguraMaxima(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CartaoUsuario(usuario: usuario),
            const SizedBox(height: 16),
            SecaoCartao(
              icone: Icons.home_outlined,
              titulo: 'Endereço',
              filhos: [
                if (usuario.cep != null)
                  Text(
                    'CEP ${usuario.cep}',
                    style: texto.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 4),
                Text(
                  usuario.enderecoCompleto.isEmpty ? 'Endereço não informado' : usuario.enderecoCompleto,
                  style: texto.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
