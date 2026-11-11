import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/formatadores.dart';
import '../../models/atendimento.dart';

const List<String> _meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];
const List<String> _letras = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

// Calendário mensal. Mostra uma bolinha por agendamento (até 3) em cada dia.
class CalendarioAgenda extends StatefulWidget {
  final List<Atendimento> atendimentos;
  final DateTime diaSelecionado;
  final ValueChanged<DateTime> aoSelecionarDia;

  const CalendarioAgenda({
    super.key,
    required this.atendimentos,
    required this.diaSelecionado,
    required this.aoSelecionarDia,
  });

  @override
  State<CalendarioAgenda> createState() => _CalendarioAgendaState();
}

class _CalendarioAgendaState extends State<CalendarioAgenda> {
  late DateTime _mes; // primeiro dia do mês mostrado

  @override
  void initState() {
    super.initState();
    _mes = DateTime(widget.diaSelecionado.year, widget.diaSelecionado.month);
  }

  void _trocarMes(int quantidade) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + quantidade));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final DateTime hoje = somenteData(DateTime.now());

    final Map<String, int> porDia = {};
    for (final Atendimento atendimento in widget.atendimentos) {
      porDia[atendimento.data] = (porDia[atendimento.data] ?? 0) + 1;
    }

    // Domingo é a primeira coluna, por isso weekday % 7
    final int diasNoMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    final int espacosAntes = DateTime(_mes.year, _mes.month).weekday % 7;
    final int semanas = ((espacosAntes + diasNoMes) / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Mês anterior',
              onPressed: () => _trocarMes(-1),
            ),
            Expanded(
              child: Text(
                '${_meses[_mes.month - 1]} ${_mes.year}',
                textAlign: TextAlign.center,
                style: texto.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Próximo mês',
              onPressed: () => _trocarMes(1),
            ),
          ],
        ),
        Row(
          children: [
            for (final String letra in _letras)
              Expanded(
                child: Center(
                  child: Text(
                    letra,
                    style: texto.labelMedium?.copyWith(
                      color: esquema.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (int semana = 0; semana < semanas; semana++)
          Row(
            children: [
              for (int coluna = 0; coluna < 7; coluna++)
                Expanded(
                  child: _celulaDia(
                    context,
                    semana * 7 + coluna - espacosAntes + 1,
                    diasNoMes,
                    porDia,
                    hoje,
                  ),
                ),
            ],
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.today_rounded, size: 18),
            label: const Text('Hoje'),
            onPressed: () {
              setState(() => _mes = DateTime(hoje.year, hoje.month));
              widget.aoSelecionarDia(hoje);
            },
          ),
        ),
      ],
    );
  }

  Widget _celulaDia(
    BuildContext context,
    int dia,
    int diasNoMes,
    Map<String, int> porDia,
    DateTime hoje,
  ) {
    if (dia < 1 || dia > diasNoMes) {
      return const SizedBox(height: 50);
    }

    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final DateTime data = DateTime(_mes.year, _mes.month, dia);
    final bool selecionado = mesmoDia(data, widget.diaSelecionado);
    final bool ehHoje = mesmoDia(data, hoje);
    final int quantidade = porDia[dataParaTexto(data)] ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => widget.aoSelecionarDia(data),
      child: SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selecionado ? esquema.primary : null,
                border: ehHoje && !selecionado
                    ? Border.all(color: esquema.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                '$dia',
                style: texto.bodyMedium?.copyWith(
                  color: selecionado
                      ? esquema.onPrimary
                      : (ehHoje ? esquema.primary : esquema.onSurface),
                  fontWeight: selecionado || ehHoje ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < min(quantidade, 3); i++)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selecionado ? esquema.onPrimary : esquema.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
