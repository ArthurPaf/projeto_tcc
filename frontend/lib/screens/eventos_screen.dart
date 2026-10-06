import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

// Um lugar reservado: a listagem dos livros chega adiante.
class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event, size: 56),
            SizedBox(height: 16),
            Text('A listagem dos eventos chega adiante.'),
          ],
        ),
      ),
    );
  }
}
