import 'package:flutter/material.dart';

import 'repositories/usuario_repository.dart';
import 'screens/login_screen.dart';
import 'services/sessao_service.dart';

// Aqui as camadas se montam, como o main.py monta a API no backend:
// o repositório entra no service, e o service entra nas telas.
void main() {
  final sessao = SessaoService(UsuarioRepository());
  runApp(EventoApp(sessao: sessao));
}

class EventoApp extends StatelessWidget {
  const EventoApp({super.key, required this.sessao});

  final SessaoService sessao;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: LoginScreen(sessao: sessao),
    );
  }
}
