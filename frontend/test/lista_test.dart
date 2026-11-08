import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/usuario.dart';
import 'package:frontend/repositories/evento_repository.dart';
import 'package:frontend/repositories/usuario_repository.dart';
import 'package:frontend/screens/eventos_screen.dart';
import 'package:frontend/services/evento_service.dart';
import 'package:frontend/services/sessao_service.dart';

Future<void> abrirALista(WidgetTester tester, String respostaDaApi) async {
  final api = MockClient((pedido) async {
    expect(pedido.method, 'GET');
    expect(pedido.url.path, '/eventos/');
    expect(pedido.headers['Authorization'], 'Bearer um-token');
    return http.Response(
      respostaDaApi,
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  final sessao = SessaoService(UsuarioRepository());
  sessao.token = 'um-token';
  sessao.usuario = Usuario(id: 1, nome: 'Ana', email: 'ana@ifg.edu.br');
  final eventos = EventoService(EventoRepository(cliente: api), sessao);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider.value(value: eventos),
      ],
      child: const MaterialApp(home: EventosScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a lista mostra o evento que a API devolveu', (tester) async {
    await abrirALista(
      tester,
      jsonEncode([
        {
          'id': 1,
          'nome': 'Festival de Música',
          'local': 'Praça Central',
          'data_inicio': '2030-11-20T18:00:00',
          'data_fim': '2030-11-20T22:00:00',
        },
      ]),
    );
    expect(find.text('Festival de Música'), findsOneWidget);
    expect(find.text('Praça Central'), findsOneWidget);
    expect(find.text('Nenhum evento ainda.'), findsNothing);
  });

  testWidgets('sem evento nenhum, a lista avisa que está vazia', (tester) async {
    await abrirALista(tester, '[]');
    expect(find.text('Nenhum evento ainda.'), findsOneWidget);
  });
}
