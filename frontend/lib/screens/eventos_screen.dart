
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento.dart';
import '../routes.dart';
import '../services/evento_service.dart';
import '../widgets/app_drawer.dart';

// A lista dos eventos de quem está logado, vinda da API. A tela tem quatro
// estados, um de cada vez: carregando, erro, lista vazia e a lista. No alto, o
// campo de busca; o + abre o formulário de um evento novo, e o toque, o detalhe
// (que edita e exclui).
class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  // O pedido à API: nasce UMA vez, quando a tela nasce, e só é refeito pelo
  // pedirDeNovo. Criado dentro do build, sairia de novo a cada redesenho.
  late Future<List<Evento>> eventos;

  // O que a pessoa procurou: '' é a lista inteira.
  String busca = '';

  @override
  void initState() {
    super.initState();
    eventos = context.read<EventoService>().listar();
  }

  // Pede a lista de novo, com a busca de agora: o Tentar de novo, a volta de
  // uma tela que mudou os eventos (fechou com true) e a busca fazem o mesmo.
  void pedirDeNovo() {
    setState(() {
      eventos = context.read<EventoService>().listar(busca: busca);
    });
  }

  // O Enter no campo de busca: guarda o texto e pede de novo. Quem filtra é a
  // API (o parâmetro de busca), e não a tela.
  void buscar(String texto) {
    busca = texto.trim();
    pedirDeNovo();
  }

  // Os quatro estados da lista, como antes; vazia, a frase diz o que foi buscado.
  Widget listaDosEventos() {
    return FutureBuilder<List<Evento>>(
      future: eventos,
      builder: (context, snapshot) {
        // 1. Carregando: a resposta ainda não chegou.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Erro: a API recusou, ou nem respondeu.
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56),
                const SizedBox(height: 16),
                const Text('Não consegui carregar os eventos'),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: pedirDeNovo,
                  child: const Text('Tentar de novo'),
                ),
              ],
            ),
          );
        }

        final lista = snapshot.data!;

        // 3. Vazia: o pedido deu certo, mas não há evento nenhum.
        if (lista.isEmpty) {
          final frase = busca.isEmpty
              ? 'Nenhum evento ainda.'
              : 'Nenhum evento com "$busca" no nome.';
          return Center(child: Text(frase));
        }

        // 4. A lista: um ListTile por evento. O toque abre o detalhe e leva só
        // o id: a tela do evento busca o evento de agora na API. O await espera
        // o detalhe fechar: com true (editou ou excluiu), a lista pede de novo.
        return ListView.builder(
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final evento = lista[i];
            return ListTile(
              leading: const Icon(Icons.event),
              title: Text(evento.nome),
              subtitle: Text(evento.local),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final mudou = await Navigator.pushNamed(
                  context,
                  AppRoutes.evento,
                  arguments: evento.id,
                );
                if (mudou == true) {
                  pedirDeNovo();
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // A busca: o Enter (onSubmitted) chama o buscar com o texto digitado.
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar pelo nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: buscar,
            ),
          ),

          // A lista ocupa o resto da tela, embaixo da busca.
          Expanded(child: listaDosEventos()),
        ],
      ),

      // O + abre o formulário vazio. Ele fecha com true quando salvou: aí, a
      // lista pede de novo, e o evento novo aparece.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo evento',
        onPressed: () async {
          final salvou = await Navigator.pushNamed(
            context,
            AppRoutes.formulario,
          );
          if (salvou == true) {
            pedirDeNovo();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
