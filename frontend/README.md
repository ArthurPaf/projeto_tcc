# Aplicativo de Gestão de Eventos

Aplicativo Flutter que consome a API de eventos. Permite cadastro de usuário,
login, gerenciamento de eventos e busca por nome.

## Checklist de funcionalidades

- [x] Autenticação com cadastro, login e sessão persistida.
- [x] Criação, listagem, detalhe, edição e exclusão de eventos.
- [x] Acesso restrito aos eventos do usuário autenticado.
- [x] Validação de campos e datas antes do envio e tratamento das recusas da API.
- [x] Busca por nome com filtro executado pela API, pelo parâmetro `nome`.
- [x] Mensagens de sucesso e erro nas ações.

## Estrutura

- `lib/models`: representação dos dados de usuários e eventos.
- `lib/repositories`: requisições HTTP, conversão de JSON e armazenamento do token.
- `lib/services`: regras de sessão, acesso aos eventos e validação.
- `lib/screens`: telas de cadastro, login, lista, formulário, detalhe e perfil.
- `lib/widgets`: componentes compartilhados e proteção de rotas.
- `lib/routes.dart`: nomes das rotas.
- `test`: testes de widget e validação.

## Execução

Requisito: Flutter compatível com Dart 3.13.3 ou superior. Comandos nesta pasta:

```powershell
flutter pub get
flutter run -d chrome
```

O endereço padrão da API é `http://127.0.0.1:8000`. A configuração de outro
endereço utiliza `API_URL`:

```powershell
flutter run -d chrome --dart-define=API_URL=https://projeto-tcc-sk89.onrender.com
```

## Testes

```powershell
flutter test
dart analyze
```

As requisições são simuladas nos testes de widget, sem depender de uma API ativa.

## Compilação web

```powershell
flutter build web --release --dart-define=API_URL=https://projeto-tcc-sk89.onrender.com
```

Os arquivos gerados ficam em `build/web`. Alterações no endereço da API exigem
nova compilação. A API deve permitir a origem do aplicativo no CORS.

Aplicativo público: [projeto-tcc-1.onrender.com](https://projeto-tcc-1.onrender.com).

Configuração completa: [README principal](../README.md).
