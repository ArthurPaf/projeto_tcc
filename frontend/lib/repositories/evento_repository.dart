import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/evento.dart';
import 'usuario_repository.dart';

// O repositório dos eventos: como o do usuário, o único que sabe endereço,
// HTTP e JSON. O endereço da API e a RecusaDaApi vêm do usuario_repository.
class EventoRepository {
  EventoRepository({http.Client? cliente}) : cliente = cliente ?? http.Client();

  final http.Client cliente;

  // GET /eventos/, com o token no cabeçalho, como o quemSouEu: a API devolve só
  // os eventos do dono do token. A resposta é uma LISTA em JSON, e cada item
  // vira um Evento: é o [Evento.from_json(item) for item in itens] do Python.
  Future<List<Evento>> listar(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/eventos/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    final itens = jsonDecode(resposta.body);
    return [for (final item in itens) Evento.fromJson(item)];
  }

  // GET /eventos/{id}: um evento só, como ele está AGORA no banco. Evento de
  // outra pessoa, ou que não existe mais, a API responde 404.
  Future<Evento> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/eventos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Evento.fromJson(jsonDecode(resposta.body));
  }

  // POST /eventos/: o evento novo vai em JSON no corpo, como no cadastro da
  // conta, e o token no cabeçalho. A API responde 201 e o evento criado.
  Future<Evento> criar(
  String token,
  String nome,
  String local,
  String data_inicio,
  String data_fim,
) async {
  final resposta = await cliente.post(
    Uri.parse('$enderecoDaApi/eventos/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'nome': nome,
      'local': local,
      'data_inicio': data_inicio,
      'data_fim': data_fim,
    }),
  );
  if (resposta.statusCode != 201) {
    throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
  }
  return Evento.fromJson(jsonDecode(resposta.body));
}

Future<Evento> atualizar(
  String token,
  int id,
  String nome,
  String local,
  String data_inicio,
  String data_fim,
) async {
  final resposta = await cliente.patch(
    Uri.parse('$enderecoDaApi/eventos/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'nome': nome,
      'local': local,
      'data_inicio': data_inicio,
      'data_fim': data_fim,
    }),
  );
  if (resposta.statusCode != 200) {
    throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
  }
  return Evento.fromJson(jsonDecode(resposta.body));
}

  // DELETE /eventos/{id}: a API responde 204, sem corpo nenhum.
  Future<void> excluir(String token, int id) async {
    final resposta = await cliente.delete(
      Uri.parse('$enderecoDaApi/eventos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 204) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
  }

  // A frase da recusa, como no UsuarioRepository: o "detail" é um texto (404,
  // 409) ou uma lista, com um item por campo errado (422). O Pydantic põe
  // "Value error, " na frente das mensagens dos validadores da API: sai aqui.
  String _frase(String corpo) {
    final detalhe = jsonDecode(corpo)['detail'];
    if (detalhe is String) {
      return detalhe;
    }
    final primeiro = detalhe[0];
    final mensagem = '${primeiro['msg']}'.replaceFirst('Value error, ', '');
    return '${primeiro['loc'].last}: $mensagem';
  }
}
