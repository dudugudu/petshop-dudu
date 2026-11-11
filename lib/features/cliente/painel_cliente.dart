import 'package:flutter/material.dart';

import '../../widgets/painel.dart';
import '../agenda/tela_agenda.dart';
import 'tela_meus_pets.dart';
import 'tela_perfil.dart';

// Painel do cliente: agenda dos pets, pets cadastrados e perfil
class PainelCliente extends StatelessWidget {
  const PainelCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return const PainelComAbas(
      abas: [
        Aba('Agenda', Icons.calendar_month_outlined, Icons.calendar_month_rounded, TelaAgenda()),
        Aba('Meus pets', Icons.pets_outlined, Icons.pets_rounded, TelaMeusPets()),
        Aba('Perfil', Icons.person_outline_rounded, Icons.person_rounded, TelaPerfil()),
      ],
    );
  }
}
