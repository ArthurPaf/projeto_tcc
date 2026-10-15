import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Evento.dart';
import '../services/evento_service.dart';

// O detalhe de um Evento. Recebe apenas o id e busca os dados atuais na API.
class EventoScreen extends StatefulWidget {
  const EventoScreen({super.key, this.id});

  // O id recebido pela rota.
  // Se não existir, mostra a lista de eventos.
  final int? id;

  @override
  State<EventoScreen> createState() => _EventoScreenState();
}

class _EventoScreenState extends State<EventoScreen> {
  late Future<Evento> pedido;

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

  @override
  Widget build(BuildContext context) {
    // Sem id, volta para a lista de eventos.
    if (widget.id == null) {
      return const EventoScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
      ),
      body: FutureBuilder<Evento>(
        future: pedido,
        builder: (context, snapshot) {
          // Estado de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado de erro.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Não consegui carregar o evento',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: tentarDeNovo,
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Verifica se existem dados antes de os utilizar.
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Evento não encontrado'),
            );
          }

          final evento = snapshot.data!;

          // Estado de sucesso: apresenta os detalhes do evento.
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Nome'),
                subtitle: Text(evento.nome),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Data de início'),
                subtitle: Text('${evento.data_inicio}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Data de fim'),
                subtitle: Text('${evento.data_fim}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Local'),
                subtitle: Text(evento.local),
              ),
            ],
          );
        },
      ),
    );
  }
}