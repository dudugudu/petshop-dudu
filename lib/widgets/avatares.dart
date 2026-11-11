import 'package:flutter/material.dart';

import '../core/tema.dart';

// Tag do Hero que liga o avatar da lista ao formulário de edição
String tagAvatar(int id) => 'avatar-$id';

// Inicial do nome do pet em uma cor fixa para o nome.
// Sem nome, mostra um ícone de pet. Com tag, o avatar "voa" entre as telas.
class AvatarPet extends StatelessWidget {
  final String nome;
  final double raio;
  final String? tag;

  const AvatarPet({super.key, required this.nome, required this.raio, this.tag});

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final String limpo = nome.trim();
    final Widget avatar;

    if (limpo.isEmpty) {
      avatar = CircleAvatar(
        radius: raio,
        backgroundColor: esquema.primaryContainer,
        child: Icon(Icons.pets_rounded, size: raio, color: esquema.onPrimaryContainer),
      );
    } else {
      final estilo = estiloAvatar(limpo, Theme.of(context).brightness);
      avatar = CircleAvatar(
        radius: raio,
        backgroundColor: estilo.fundo,
        child: Text(
          limpo[0].toUpperCase(),
          style: TextStyle(
            color: estilo.texto,
            fontSize: raio * 0.8,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final String? etiqueta = tag;
    return etiqueta == null ? avatar : Hero(tag: etiqueta, child: avatar);
  }
}

// Foto do pet (iNaturalist). Enquanto carrega, ou se falhar, mostra um ícone de pet.
class FotoPet extends StatelessWidget {
  final String? url;
  final double tamanho;

  const FotoPet({super.key, required this.url, this.tamanho = 64});

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final String? endereco = url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            width: tamanho,
            height: tamanho,
            color: esquema.primaryContainer,
            alignment: Alignment.center,
            child: Icon(Icons.pets_rounded, size: tamanho * 0.45, color: esquema.onPrimaryContainer),
          ),
          if (endereco != null)
            Image.network(
              endereco,
              width: tamanho,
              height: tamanho,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
