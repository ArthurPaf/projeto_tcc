import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';
import 'aviso.dart';

// O menu lateral, igual em toda tela protegida. Ele não recebe nada pelo
// construtor: pergunta à sessão quem está logado, onde quer que esteja.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // O guarda só abre as telas com sessão, então o usuário nunca é null aqui.
    final usuario = context.watch<SessaoService>().usuario!;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario.nome),
            accountEmail: Text(usuario.email),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.inicio),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Eventos'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.eventos),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.perfil),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              final sessao = context.read<SessaoService>();
              final navegador = Navigator.of(context);
              final mensageiro = ScaffoldMessenger.of(context);
              try {
                await sessao.sair();
              } catch (_) {
                if (context.mounted) {
                  avisar(
                    context,
                    'Não consegui sair. Tente de novo.',
                    erro: true,
                  );
                }
                return;
              }
              mensageiro.hideCurrentSnackBar();
              mensageiro.showSnackBar(
                const SnackBar(
                  content: Text('Você saiu da conta'),
                  backgroundColor: Colors.green,
                ),
              );
              if (!context.mounted) return;
              navegador.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (rota) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
