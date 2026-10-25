import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento.dart';
import '../routes.dart';
import '../services/evento_service.dart';
import '../widgets/app_drawer.dart';

// A lista dos eventos de quem está logado, vinda da API. A tela tem quatro
// estados, um de cada vez: carregando, erro, lista vazia e a lista. O + abre
// o formulário de um evento novo, e o toque, o detalhe (que edita e exclui).
class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  // O pedido à API: nasce UMA vez, quando a tela nasce, e só é refeito pelo
  // pedirDeNovo. Criado dentro do build, sairia de novo a cada redesenho.
  late Future<List<Evento>> eventos;

  @override
  void initState() {
    super.initState();
    eventos = context.read<EventoService>().listar();
  }

  // Pede a lista de novo: o Tentar de novo, e a volta de uma tela que mudou
  // o acervo (fechou com true), fazem a mesma coisa.
  void pedirDeNovo() {
    setState(() {
      eventos = context.read<EventoService>().listar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Evento>>(
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
                  const Text('Não consegui carregar os livros'),
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
          // 3. Vazia: o pedido deu certo, mas não há livro nenhum.
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhum livro ainda.'));
          }
          // 4. A lista: um ListTile por livro. O toque abre o detalhe e leva só
          // o id: a tela do livro busca o livro de agora na API. O await espera
          // o detalhe fechar: com true (editou ou excluiu), a lista pede de novo.
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final livro = lista[i];
              return ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(livro.nome),
                subtitle: Text(livro.local),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final mudou = await Navigator.pushNamed(context, AppRoutes.evento, arguments: livro.id);
                  if (mudou == true) {
                    pedirDeNovo();
                  }
                },
              );
            },
          );
        },
      ),
      // O + abre o formulário vazio. Ele fecha com true quando salvou: aí, a
      // lista pede de novo, e o livro novo aparece.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo livro',
        onPressed: () async {
          final salvou = await Navigator.pushNamed(context, AppRoutes.formulario);
          if (salvou == true) {
            pedirDeNovo();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
