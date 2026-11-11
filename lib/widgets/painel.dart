import 'package:flutter/material.dart';

// Uma aba do painel: rótulo, ícones (parado e selecionado) e a tela
class Aba {
  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
  final Widget tela;

  const Aba(this.rotulo, this.icone, this.iconeSelecionado, this.tela);
}

// Tela com barra de navegação embaixo. Cada toque troca a tela inteira,
// então a aba recarrega os dados sempre que é aberta.
class PainelComAbas extends StatefulWidget {
  final List<Aba> abas;

  const PainelComAbas({super.key, required this.abas});

  @override
  State<PainelComAbas> createState() => _PainelComAbasState();
}

class _PainelComAbasState extends State<PainelComAbas> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.abas[_indice].tela,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: [
          for (final Aba aba in widget.abas)
            NavigationDestination(
              icon: Icon(aba.icone),
              selectedIcon: Icon(aba.iconeSelecionado),
              label: aba.rotulo,
            ),
        ],
      ),
    );
  }
}
