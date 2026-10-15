import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/evento_repository.dart';
import 'repositories/token_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/cadastro_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/evento_screen.dart';
import 'screens/eventos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/evento_service.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

// Aqui as camadas se montam:
// os repositórios entram nos services, e os services ficam disponíveis
// para todas as telas através do Provider.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessao = SessaoService(
    UsuarioRepository(),
    tokens: TokenRepository(),
  );

  // Restaura a sessão guardada no aparelho.
  await sessao.restaurar();

  // O service dos eventos utiliza a sessão para aceder à API.
  final eventos = EventoService(EventoRepository(), sessao,);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider.value(value: eventos),
      ],
      child: const BibliotecaApp(),
    ),
  );
}

class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),

        AppRoutes.cadastro: (context) => const CadastroScreen(),

        AppRoutes.inicio: (context) =>
            const RotaProtegida(tela: InicioScreen()),

        AppRoutes.eventos: (context) =>
            const RotaProtegida(tela: EventosScreen()),

        // A rota passa o id recebido nos arguments para a tela de detalhe.
        AppRoutes.evento: (context) => RotaProtegida(
              tela: EventoScreen(
                id: ModalRoute.of(context)!.settings.arguments as int?,
              ),
            ),

        AppRoutes.perfil: (context) =>
            const RotaProtegida(tela: PerfilScreen()),
      },
    );
  }
}
