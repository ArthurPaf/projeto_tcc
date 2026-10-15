
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Evento.dart';
import '../routes.dart';
import '../services/evento_service.dart';
import '../widgets/app_drawer.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> eventos;

  @override
  void initState() {
    super.initState();
    eventos = context.read<EventoService>().listar();
  }

  void tentarDeNovo() {
    setState(() {
      eventos = context.read<EventoService>().listar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Evento>>(
        future: eventos,
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Erro ao buscar eventos
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 56),
                  const SizedBox(height: 16),
                  const Text('Não foi possível carregar os eventos'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
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

          final lista = snapshot.data ?? [];

          // Lista vazia
          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhum evento encontrado.'),
            );
          }

          // Listagem dos eventos
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final evento = lista[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.evento,
                      arguments: evento.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do evento
                        Text(
                          evento.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Local
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${evento.local}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Data de início
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Início: ${evento.data_inicio}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Data de fim
                        Row(
                          children: [
                            const Icon(
                              Icons.event_busy_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Fim: ${evento.data_fim}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Ver detalhes'),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
