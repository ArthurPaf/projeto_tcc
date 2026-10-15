
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Evento.dart';
import 'usuario_repository.dart';

class EventoRepository {
  EventoRepository({http.Client? cliente})
      : cliente = cliente ?? http.Client();

  final http.Client cliente;

  // Lista os eventos do usuário autenticado.
  Future<List<Evento>> listar(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/eventos/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resposta.statusCode != 200) {
      throw RecusaDaApi(
        resposta.statusCode,
        jsonDecode(resposta.body)['detail'],
      );
    }

    final itens = jsonDecode(resposta.body);

    return [
      for (final item in itens) Evento.fromJson(item),
    ];
  }

  // Busca um evento específico pelo ID.
  Future<Evento> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/eventos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resposta.statusCode != 200) {
      throw RecusaDaApi(
        resposta.statusCode,
        jsonDecode(resposta.body)['detail'],
      );
    }

    return Evento.fromJson(jsonDecode(resposta.body));
  }
}
