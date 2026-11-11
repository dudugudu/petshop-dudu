import 'package:flutter/material.dart';

// 2025-03-15 (formato usado no banco)
String dataParaTexto(DateTime data) {
  return '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';
}

// 2025-03-15 -> 15/03/2025
String formatarData(String dataDoBanco) {
  final List<String> partes = dataDoBanco.split('-');
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}

// 50.5 -> R$ 50,50
String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

// 09:05 -> "09:05" (formato do banco) e o caminho contrário
String horaParaTexto(TimeOfDay hora) {
  return '${_doisDigitos(hora.hour)}:${_doisDigitos(hora.minute)}';
}

TimeOfDay textoParaHora(String texto) {
  final List<String> partes = texto.split(':');
  return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
}

// Compara só ano, mês e dia
bool mesmoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Mesma data, sem horas
DateTime somenteData(DateTime data) => DateTime(data.year, data.month, data.day);

String _doisDigitos(int numero) => numero.toString().padLeft(2, '0');
