import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/evento.dart';
import 'repositories/evento_repository.dart';
import 'repositories/token_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/cadastro_screen.dart';
import 'screens/formulario_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/evento_screen.dart';
import 'screens/eventos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/evento_service.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

// Aqui as camadas se montam, como o main.py monta a API no backend: os
// repositórios entram nos services, e os services ficam no topo do app, onde
// toda tela os alcança, sem passar de construtor em construtor.
Future<void> main() async {
  // O Flutter precisa estar de pé antes de qualquer pacote falar com o aparelho.
  WidgetsFlutterBinding.ensureInitialized();
  final sessao = SessaoService(UsuarioRepository(), tokens: TokenRepository());
  // Antes de a primeira tela aparecer: se o aparelho guardou um token que a
  // API ainda aceita, a sessão volta e o app abre logado.
  await sessao.restaurar();
  // O service dos eventos pega o token na sessão: nasce com ela na mão.
  final eventos = EventoService(EventoRepository(), sessao);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider.value(value: eventos),
      ],
      child: const EventoApp(),
    ),
  );
}

class EventoApp extends StatelessWidget {
  const EventoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.cadastro: (context) => const CadastroScreen(),
        AppRoutes.inicio: (context) => const RotaProtegida(tela: InicioScreen()),
        AppRoutes.eventos: (context) => const RotaProtegida(tela: EventosScreen()),
        // O detalhe: a rota entrega à tela o id que veio nos arguments.
        AppRoutes.evento: (context) => RotaProtegida(
          tela: EventoScreen(id: ModalRoute.of(context)!.settings.arguments as int?),
        ),
        // O formulário: sem arguments, um evento novo; com o evento, a edição.
        AppRoutes.formulario: (context) => RotaProtegida(
          tela: FormularioScreen(evento: ModalRoute.of(context)!.settings.arguments as Evento?),
        ),
        AppRoutes.perfil: (context) => const RotaProtegida(tela: PerfilScreen()),
      },
    );
  }
}
