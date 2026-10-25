import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento.dart';
import '../routes.dart';
import '../services/evento_service.dart';
import 'eventos_screen.dart';

// O detalhe de um evento. Chega só o id, e a tela pede o evento à API: o dado é
// o de agora, e não o de quando a lista carregou. Daqui, o evento se edita e
// se exclui; quando um dos dois dá certo, a tela fecha com true.
class EventoScreen extends StatefulWidget {
  const EventoScreen({super.key, this.id});

  // O id que a rota tirou dos arguments. Sem ele (um F5 aqui apaga os
  // arguments, que moram na memória), a tela mostra a lista.
  final int? id;

  @override
  State<EventoScreen> createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  // O pedido do evento: como o da lista, nasce uma vez, no initState.
  late Future<Evento> pedido;
  // A recusa da exclusão (o evento emprestado, por exemplo), para a tela mostrar.
  String? erro;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      pedido = context.read<EventoService>().buscar(widget.id!);
    }
  }

  void tentarDeNovo() {
    setState(() {
      pedido = context.read<EventoService>().buscar(widget.id!);
    });
  }

  // Abre o formulário com o evento, para editar. Se ele voltar com true (salvou),
  // esta tela também fecha com true: passa a notícia para a lista.
  Future<void> editar(Evento evento) async {
    final salvou = await Navigator.pushNamed(context, AppRoutes.formulario, arguments: evento);
    if (salvou == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  // Pergunta antes de excluir. O diálogo é uma tela por cima, e fecha devolvendo
  // um valor: true no Excluir, false no Cancelar, null num toque fora dele.
  Future<void> excluir(Evento evento) async {
    final certeza = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir ${evento.nome}?'),
        content: const Text('Tem certeza? O evento sai do seu acervo, e não dá para desfazer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (certeza != true || !mounted) {
      return;
    }
    try {
      await context.read<EventoService>().excluir(evento.id);
    } on ErroDeEventos catch (e) {
      setState(() {
        erro = '$e';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == null) {
      return const EventosScreen();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Evento')),
      body: FutureBuilder<Evento>(
        future: pedido,
        builder: (context, snapshot) {
          // Os estados da lista, de novo. O vazio não existe aqui: o evento que
          // sumiu é um 404 da API, e vira erro.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 56),
                  const SizedBox(height: 16),
                  const Text('Não consegui carregar o evento'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: tentarDeNovo,
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            );
          }
          final evento = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Título'),
                subtitle: Text(evento.nome),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Ano'),
                subtitle: Text(evento.local),
              ),
              const SizedBox(height: 16),
              // Editar e Excluir: o evento já está na mão, e é o de agora.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => editar(evento),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => excluir(evento),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
