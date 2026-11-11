import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../models/usuario.dart';
import 'avatares.dart';

// Cartão com título e ícone, agrupando campos relacionados
class SecaoCartao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final List<Widget> filhos;

  const SecaoCartao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: esquema.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, size: 18, color: esquema.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Text(titulo, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 18),
            ...filhos,
          ],
        ),
      ),
    );
  }
}

// Nome, e-mail e telefone de uma conta, com o avatar ao lado
class CartaoUsuario extends StatelessWidget {
  final Usuario usuario;

  const CartaoUsuario({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final TextTheme texto = Theme.of(context).textTheme;
    final Color cinza = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AvatarPet(nome: usuario.nome, raio: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(usuario.nome, style: texto.titleLarge),
                  Text(usuario.email, style: texto.bodyMedium?.copyWith(color: cinza)),
                  if (usuario.telefone != null)
                    Text(usuario.telefone!, style: texto.bodyMedium?.copyWith(color: cinza)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Linha de um pet: foto, nome, espécie e crédito da foto. O botão de remover é opcional.
class CartaoPet extends StatelessWidget {
  final Pet pet;
  final VoidCallback? aoRemover;

  const CartaoPet({super.key, required this.pet, this.aoRemover});

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final Color cinza = esquema.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            FotoPet(url: pet.fotoUrl, tamanho: 68),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texto.titleMedium,
                  ),
                  Text(
                    pet.tipo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodyMedium?.copyWith(color: cinza),
                  ),
                  if (pet.nomeCientifico != null)
                    Text(
                      pet.nomeCientifico!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: cinza),
                    ),
                  // A API exige o crédito de quem tirou a foto
                  if (pet.fotoAtribuicao != null)
                    Text(
                      'Foto: ${pet.fotoAtribuicao}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.labelSmall?.copyWith(color: esquema.outline),
                    ),
                ],
              ),
            ),
            if (aoRemover != null)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: esquema.error),
                tooltip: 'Remover pet',
                onPressed: aoRemover,
              ),
          ],
        ),
      ),
    );
  }
}
