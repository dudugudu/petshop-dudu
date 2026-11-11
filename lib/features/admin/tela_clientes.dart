import 'package:flutter/material.dart';

import '../../data/pets_repositorio.dart';
import '../../models/pet.dart';
import '../../models/usuario.dart';
import '../../data/usuarios_repositorio.dart';
import '../../widgets/avatares.dart';
import '../../widgets/cartoes.dart';
import '../../widgets/comuns.dart';
import '../auth/navegacao.dart';

// Lista de contas de cliente. Tocar em uma abre o detalhe com endereço e pets.
class TelaClientes extends StatefulWidget {
  const TelaClientes({super.key});

  @override
  State<TelaClientes> createState() => _TelaClientesState();
}

class _TelaClientesState extends State<TelaClientes> {
  List<Usuario> _clientes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final List<Usuario> lista = await RepositorioUsuarios.listarClientes();
    if (!mounted) return;
    setState(() {
      _clientes = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color cinza = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: const [BotaoSair(), SizedBox(width: 4)],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
          ? const EstadoVazio(
              icone: Icons.people_outline_rounded,
              titulo: 'Nenhum cliente ainda',
              mensagem: 'Quando alguém criar uma conta no app, ela aparece aqui.',
            )
          : LarguraMaxima(
              largura: 720,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _clientes.length,
                itemBuilder: (context, indice) {
                  final Usuario cliente = _clientes[indice];
                  final String local = cliente.cidade == null
                      ? 'Sem endereço'
                      : '${cliente.cidade}/${cliente.uf ?? ''}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: AvatarPet(nome: cliente.nome, raio: 24),
                        title: Text(cliente.nome, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(
                          '${cliente.email}\n$local',
                          style: TextStyle(color: cinza),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TelaDetalheCliente(cliente: cliente)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// Detalhe de um cliente: conta, endereço e pets
class TelaDetalheCliente extends StatefulWidget {
  final Usuario cliente;

  const TelaDetalheCliente({super.key, required this.cliente});

  @override
  State<TelaDetalheCliente> createState() => _TelaDetalheClienteState();
}

class _TelaDetalheClienteState extends State<TelaDetalheCliente> {
  List<Pet> _pets = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final List<Pet> lista = await RepositorioPets.listarDoUsuario(widget.cliente.id!);
    if (!mounted) return;
    setState(() {
      _pets = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Usuario cliente = widget.cliente;
    final Color cinza = Theme.of(context).colorScheme.onSurfaceVariant;
    final TextTheme texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cliente')),
      body: LarguraMaxima(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CartaoUsuario(usuario: cliente),
            const SizedBox(height: 16),
            SecaoCartao(
              icone: Icons.home_outlined,
              titulo: 'Endereço',
              filhos: [
                Text(
                  cliente.enderecoCompleto.isEmpty
                      ? 'Endereço não informado'
                      : cliente.enderecoCompleto,
                  style: texto.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SecaoCartao(
              icone: Icons.pets_rounded,
              titulo: 'Pets',
              filhos: [
                if (_carregando)
                  const Center(child: CircularProgressIndicator())
                else if (_pets.isEmpty)
                  Text('Nenhum pet cadastrado.', style: texto.bodyLarge?.copyWith(color: cinza))
                else
                  for (final Pet pet in _pets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CartaoPet(pet: pet),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
