import '../models/evento.dart';
import '../repositories/evento_repository.dart';
import '../repositories/usuario_repository.dart';
import 'sessao_service.dart';

// A recusa dos eventos, com a frase que a tela mostra.
class ErroDeEventos implements Exception {
  ErroDeEventos(this.mensagem);

  final String mensagem;

  // O texto do erro quando a tela o mostra: é o __str__ do Python.
  @override
  String toString() => mensagem;
}

// As regras dos eventos. Não guarda estado (não é um ChangeNotifier): quem
// lembra se está carregando, se deu erro ou qual é a lista é a própria tela.
// O service pega o token na sessão, pede ao repositório e traduz a recusa.
class EventoService {
  EventoService(this.repositorio, this.sessao);

  final EventoRepository repositorio;
  final SessaoService sessao;

  Future<List<Evento>> listar() async {
    try {
      // O guarda só abre a tela de livros com sessão: o token nunca é null aqui.
      return await repositorio.listar(sessao.token!);
    } on RecusaDaApi catch (e) {
      throw ErroDeEventos(e.mensagem);
    } on Exception {
      // Uma falha de fora, como a rede: a API nem respondeu (o uvicorn parado).
      // Um erro do próprio código não é Exception: passa direto, e a tela o
      // mostra inteiro.
      throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  // Um evento só, pelo id: as mesmas regras do listar.
  Future<Evento> buscar(int id) async {
    try {
      return await repositorio.buscar(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeEventos(e.mensagem);
    } on Exception {
      throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  // Criar, editar e excluir: o mesmo molde do listar. O token vem da sessão,
  // e a recusa da API (422, 409, 404) vira a frase que a tela mostra.
Future<Evento> criar(
  String nome,
  String local,
  String data_inicio,
  String data_fim,
) async {
  try {
    return await repositorio.criar(
      sessao.token!,
      nome,
      local,
      data_inicio,
      data_fim,
    );
  } on RecusaDaApi catch (e) {
    throw ErroDeEventos(e.mensagem);
  } on Exception {
    throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
  }
}

Future<Evento> atualizar(
  int id,
  String nome,
  String local,
  String data_inicio,
  String data_fim,
) async {
  try {
    return await repositorio.atualizar(
      sessao.token!,
      id,
      nome,
      local,
      data_inicio,
      data_fim,
    );
  } on RecusaDaApi catch (e) {
    throw ErroDeEventos(e.mensagem);
  } on Exception {
    throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
  }
}

  Future<void> excluir(int id) async {
    try {
      await repositorio.excluir(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeEventos(e.mensagem);
    } on Exception {
      throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }
}
