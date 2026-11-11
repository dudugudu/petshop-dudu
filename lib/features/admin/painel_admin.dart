import 'package:flutter/material.dart';

import '../../widgets/painel.dart';
import '../agenda/tela_agenda.dart';
import 'tela_atendimentos.dart';
import 'tela_clientes.dart';

// Painel do administrador: agenda, atendimentos e clientes
class PainelAdmin extends StatelessWidget {
  const PainelAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const PainelComAbas(
      abas: [
        Aba('Agenda', Icons.calendar_month_outlined, Icons.calendar_month_rounded, TelaAgenda()),
        Aba('Atendimentos', Icons.list_alt_outlined, Icons.list_alt_rounded, TelaAtendimentos()),
        Aba('Clientes', Icons.people_outline_rounded, Icons.people_rounded, TelaClientes()),
      ],
    );
  }
}
