import 'package:flutter/material.dart';

import '../../core/formatadores.dart';
import '../../data/atendimentos_repositorio.dart';
import '../../widgets/cabecalho.dart';

// Faturamento total, quantidade de atendimentos e ticket médio
class TelaResumo extends StatefulWidget {
  const TelaResumo({super.key});

  @override
  State<TelaResumo> createState() => _TelaResumoState();
}

class _TelaResumoState extends State<TelaResumo> {
  double _faturamento = 0;
  int _quantidade = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final double total = await RepositorioAtendimentos.faturamentoTotal();
    final int quantidade = await RepositorioAtendimentos.quantidade();
    if (!mounted) return;
    setState(() {
      _faturamento = total;
      _quantidade = quantidade;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;
    final double ticketMedio = _quantidade == 0 ? 0 : _faturamento / _quantidade;
    final String atendimentos = _quantidade == 1
        ? '1 atendimento realizado'
        : '$_quantidade atendimentos realizados';

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo financeiro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: FundoGradiente(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Faturamento total',
                            style: texto.titleMedium?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatarMoeda(_faturamento),
                              style: texto.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            atendimentos,
                            style: texto.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CartaoNumero(
                        icone: Icons.event_available_outlined,
                        rotulo: 'Atendimentos',
                        valor: '$_quantidade',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CartaoNumero(
                        icone: Icons.trending_up_rounded,
                        rotulo: 'Ticket médio',
                        valor: formatarMoeda(ticketMedio),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Cartão pequeno com ícone, rótulo e um número em destaque
class _CartaoNumero extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _CartaoNumero({required this.icone, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: esquema.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, size: 18, color: esquema.onSecondaryContainer),
            ),
            const SizedBox(height: 14),
            Text(
              rotulo,
              style: texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
