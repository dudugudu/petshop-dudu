import 'package:flutter/material.dart';
import 'atendimento.dart';
import 'banco_de_dados.dart';

class TelaResumo extends StatefulWidget {
  const TelaResumo({super.key});

  @override
  State<TelaResumo> createState() => _TelaResumoState();
}

class _TelaResumoState extends State<TelaResumo> {
  double _faturamentoTotal = 0;
  int _quantidade = 0;

  @override
  void initState() {
    super.initState();
    _carregarResumo();
  }

  // Os dois cálculos são feitos pelo SQL (SUM e COUNT) dentro do BancoDeDados
  Future<void> _carregarResumo() async {
    double total = await BancoDeDados.calcularFaturamentoTotal();
    int quantidade = await BancoDeDados.contarAtendimentos();
    setState(() {
      _faturamentoTotal = total;
      _quantidade = quantidade;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo financeiro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Faturamento total', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                formatarMoeda(_faturamentoTotal),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Atendimentos realizados: $_quantidade',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                // Navigator.pop fecha esta tela e volta para a listagem
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}