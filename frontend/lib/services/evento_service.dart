import '../models/Evento.dart';
import '../repositories/evento_repository.dart';
import '../repositories/usuario_repository.dart';
import 'sessao_service.dart';

// A recusa dos Eventos, com a frase que a tela mostra.
class ErroDeEventos implements Exception {
  ErroDeEventos(this.mensagem);

  final String mensagem;

  // O texto do erro quando a tela o mostra: é o __str__ do Python.
  @override
  String toString() => mensagem;
}

class EventoService {
  EventoService(this.repositorio, this.sessao);

  final EventoRepository repositorio;
  final SessaoService sessao;

  Future<List<Evento>> listar() async {
    try {
      // O guarda só abre a tela de Eventos com sessão: o token nunca é null aqui.
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

  // Um Evento só, pelo id: as mesmas regras do listar.
  Future<Evento> buscar(int id) async {
    try {
      return await repositorio.buscar(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeEventos(e.mensagem);
    } on Exception {
      throw ErroDeEventos('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }
}
