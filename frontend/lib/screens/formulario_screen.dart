
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento.dart';
import '../services/evento_service.dart';
import '../widgets/aviso.dart';
import 'eventos_screen.dart';

// Uma tela só para criar e para editar: sem evento, cria; com o evento, edita.
// Os campos e as regras são os mesmos; muda o título da barra, o que vem
// preenchido e o pedido que sai (POST para criar, PATCH para editar).
class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key, this.evento});

  // O evento a editar, que veio nos arguments; null é um evento novo.
  final Evento? evento;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  // A chave do Form: é por ela que o Salvar alcança o formulário e confere
  // todos os campos de uma vez.
  final chave = GlobalKey<FormState>();
  final nome = TextEditingController();
  final local = TextEditingController();
  final dataInicio = TextEditingController();
  final dataFim = TextEditingController();

  String formatarDataParaApi(String data) {
  final partes = data.trim().split('/');

  if (partes.length == 3) {
    final dia = partes[0].padLeft(2, '0');
    final mes = partes[1].padLeft(2, '0');
    final ano = partes[2];

    return '$ano-$mes-$dia';
  }

  return data.trim();
}

  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    // Editando: os campos já começam com o que o evento tem.
    if (widget.evento != null) {
      nome.text = widget.evento!.nome;
      local.text = widget.evento!.local;
      dataInicio.text = widget.evento!.dataInicio;
      dataFim.text = widget.evento!.dataFim;
    }
  }

  
Future<void> salvar() async {
  // A ponta do app: cada validator confere o seu campo. Se algum devolver
  // uma frase, ela aparece embaixo do campo, e nada vai para a API.
  if (!chave.currentState!.validate()) {
    return;
  }

  setState(() {
    salvando = true;
    erro = null;
  });

  // A ponta da API: ela confere tudo de novo, e pode recusar (422, 409).
  // O serviço é o EventoService, pego uma vez para as duas chamadas abaixo.
  final servico = context.read<EventoService>();
  debugPrint('Data início original: ${dataInicio.text}');
  debugPrint('Data início enviada: ${formatarDataParaApi(dataInicio.text)}');
  debugPrint('Data fim enviada: ${formatarDataParaApi(dataFim.text)}');

  try {
    if (widget.evento == null) {
      await servico.criar(
        nome.text,
        local.text,
        formatarDataParaApi(dataInicio.text),
        formatarDataParaApi(dataFim.text),
      );
    } else {
      await servico.atualizar(
        widget.evento!.id,
        nome.text,
        local.text,
        formatarDataParaApi(dataInicio.text),
        formatarDataParaApi(dataFim.text),
      );
    }
  } on ErroDeEventos catch (e) {
    if (!mounted) return;

    setState(() {
      salvando = false;
      erro = '$e';
    });

    // A frase da API fica no formulário; o aviso diz que não deu.
    avisar(context, 'Não deu para salvar', erro: true);
    return;
  }

  if (!mounted) return;

  // Deu certo: o aviso verde, e o formulário fecha com true; quem o abriu
  // pede de novo. O aviso continua na tela da lista.
  avisar(context, 'Evento salvo');
  Navigator.pop(context, true);
}


  @override
  void dispose() {
    nome.dispose();
    local.dispose();
    dataInicio.dispose();
    dataFim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Depois de um F5, o formulário é a primeira tela da pilha: ninguém o
    // abriu, e não há quem receba o true. Aí, ele mostra a lista, como o detalhe.
    if (ModalRoute.of(context)!.isFirst) {
      return const EventosScreen();
    }

    final editando = widget.evento != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar evento' : 'Novo evento')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: chave,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nome,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: local,
                    decoration: const InputDecoration(
                      labelText: 'Local',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o local';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dataInicio,
                    decoration: const InputDecoration(
                      labelText: 'Data de início',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe a data de início';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dataFim,
                    decoration: const InputDecoration(
                      labelText: 'Data de fim',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe a data de fim';
                      }
                      return null;
                    },
                  ),
                  if (erro != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: salvando ? null : salvar,
                    child: Text(salvando ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
