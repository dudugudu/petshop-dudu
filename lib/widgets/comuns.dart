import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Etiqueta arredondada com ícone e texto (serviço, data, espécie)
class Etiqueta extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color fundo;
  final Color cor;

  const Etiqueta({
    super.key,
    required this.icone,
    required this.texto,
    required this.fundo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mensagem de "não há nada aqui", com botão opcional
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? textoBotao;
  final VoidCallback? aoApertar;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.textoBotao,
    this.aoApertar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme esquema = Theme.of(context).colorScheme;
    final TextTheme texto = Theme.of(context).textTheme;
    final String? botao = textoBotao;
    final VoidCallback? acao = aoApertar;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: esquema.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 56, color: esquema.primary),
            ),
            const SizedBox(height: 24),
            Text(titulo, textAlign: TextAlign.center, style: texto.titleLarge),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
            if (botao != null && acao != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: acao,
                icon: const Icon(Icons.add_rounded),
                label: Text(botao),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Campo de texto já com o visual do app
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String rotulo;
  final IconData? icone;
  final Widget? sufixo;
  final String? dica;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final TextCapitalization maiusculas;
  final List<TextInputFormatter>? formatadores;
  final bool senha;
  final bool somenteLeitura;
  final VoidCallback? aoTocar;
  final ValueChanged<String>? aoMudar;
  final ValueChanged<String>? aoEnviar;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.rotulo,
    this.icone,
    this.sufixo,
    this.dica,
    this.validator,
    this.teclado,
    this.maiusculas = TextCapitalization.none,
    this.formatadores,
    this.senha = false,
    this.somenteLeitura = false,
    this.aoTocar,
    this.aoMudar,
    this.aoEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      textCapitalization: maiusculas,
      inputFormatters: formatadores,
      obscureText: senha,
      readOnly: somenteLeitura,
      onTap: aoTocar,
      onChanged: aoMudar,
      onFieldSubmitted: aoEnviar,
      validator: validator,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: dica,
        prefixIcon: icone == null ? null : Icon(icone),
        suffixIcon: sufixo,
      ),
    );
  }
}

// Botão fixo na parte de baixo da tela, na largura máxima de 560 px
class BotaoRodape extends StatelessWidget {
  final String texto;
  final Widget icone;
  final VoidCallback? aoApertar;

  const BotaoRodape({
    super.key,
    required this.texto,
    required this.icone,
    this.aoApertar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          heightFactor: 1, // ocupa só a altura do botão
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton.icon(
                onPressed: aoApertar,
                icon: icone,
                label: Text(texto),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Centraliza o conteúdo e limita a largura (útil em telas de computador)
class LarguraMaxima extends StatelessWidget {
  final double largura;
  final Widget child;

  const LarguraMaxima({super.key, this.largura = 560, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: child,
      ),
    );
  }
}

// Validador: campo vazio mostra a mensagem
String? Function(String?) obrigatorio(String mensagem) {
  return (texto) => texto == null || texto.trim().isEmpty ? mensagem : null;
}

// Mensagem rápida na parte de baixo da tela
void mostrarAviso(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem), duration: const Duration(seconds: 2)));
}

// Pequeno indicador de carregamento para usar dentro de um botão
Widget indicadorBotao() {
  return const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
  );
}
