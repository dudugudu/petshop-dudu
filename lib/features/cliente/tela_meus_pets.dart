import 'package:flutter/material.dart';

import '../../core/sessao.dart';
import '../../data/pets_repositorio.dart';
import '../../models/pet.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';
import '../auth/navegacao.dart';
import 'tela_cadastro_pet.dart';

// Pets do cliente logado
class TelaMeusPets extends StatefulWidget {
  const TelaMeusPets({super.key});

  @override
  State<TelaMeusPets> createState() => _TelaMeusPetsState();
}

class _TelaMeusPetsState extends State<TelaMeusPets> {
  List<Pet> _pets = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final List<Pet> lista = await RepositorioPets.listarDoUsuario(Sessao.atual.id!);
    if (!mounted) return;
    setState(() {
      _pets = lista;
      _carregando = false;
    });
  }

  Future<void> _novoPet() async {
    final bool? salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastroPet()),
    );
    if (!mounted || salvou != true) return;
    mostrarAviso(context, 'Pet cadastrado!');
    await _carregar();
  }

  Future<void> _remover(Pet pet) async {
    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover pet'),
        content: Text('Deseja remover ${pet.nome} da sua lista?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (confirmou != true) return;

    await RepositorioPets.excluir(pet.id!);
    if (!mounted) return;
    mostrarAviso(context, 'Pet removido.');
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus pets'),
        actions: const [BotaoSair(), SizedBox(width: 4)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoPet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo pet'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
          ? EstadoVazio(
              icone: Icons.pets_rounded,
              titulo: 'Nenhum pet cadastrado',
              mensagem: 'Cadastre seu pet escolhendo a espécie na lista de animais.',
              textoBotao: 'Cadastrar pet',
              aoApertar: _novoPet,
            )
          : LarguraMaxima(
              largura: 720,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _pets.length,
                itemBuilder: (context, indice) {
                  final Pet pet = _pets[indice];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CartaoPet(pet: pet, aoRemover: () => _remover(pet)),
                  );
                },
              ),
            ),
    );
  }
}
