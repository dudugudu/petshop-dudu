import 'package:flutter/material.dart';

import '../core/tema.dart';

// Fundo em gradiente da cor principal, com dois círculos translúcidos de detalhe
class FundoGradiente extends StatelessWidget {
  final Widget child;

  const FundoGradiente({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Color claro = Color.lerp(corPrincipal, Colors.white, 0.14)!;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [claro, corPrincipal],
              ),
            ),
          ),
        ),
        const Positioned(top: -80, right: -50, child: _Circulo(200)),
        const Positioned(bottom: -90, left: -60, child: _Circulo(180)),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}

class _Circulo extends StatelessWidget {
  final double tamanho;

  const _Circulo(this.tamanho);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

// Bloco translúcido com ícone, rótulo e valor, para ficar sobre o gradiente
class MetricaVidro extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const MetricaVidro({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icone, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texto.labelMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: texto.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
