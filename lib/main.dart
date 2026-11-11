import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/tema.dart';
import 'features/auth/tela_login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // No Windows e no Linux o SQLite precisa do sqflite_common_ffi.
  // No Android, o sqflite já funciona direto.
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Shop',
      debugShowCheckedModeBanner: false,
      theme: criarTema(Brightness.light),
      darkTheme: criarTema(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const TelaLogin(),
    );
  }
}
