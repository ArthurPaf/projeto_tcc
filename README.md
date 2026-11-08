# Gerenciador de Eventos — o evento tem dono

O projeto com login e migrações, mais o que o checkpoint pede: o evento ganha **dono** (um usuário tem muitos eventos), cada pessoa enxerga e mexe só no próprio calendário, a listagem tem **busca e filtro** (por nome e local), e o `422` explica o que está errado em português. A coluna nova entrou por uma **migração** — o `create_all` não existe mais.

## O que é

Uma API robusta desenvolvida com **FastAPI**, **SQLAlchemy** e **Pydantic** para gestão personalizada de compromissos. O sistema implementa o padrão *multi-tenant* no nível de aplicação, garantindo o isolamento total dos dados: um usuário autenticado jamais consegue visualizar, editar ou apagar eventos criados por outras pessoas. 

## Como rodar

```bash
cd backend
poetry install
```

Na pasta `backend/`, copie o arquivo `.env.exemplo` para `.env` e configure as variáveis de ambiente. O exemplo usa SQLite para rodar localmente; para usar PostgreSQL, informe a URL do seu banco em `DATABASE_URL`. Substitua a `SECRET_KEY` por uma chave secreta própria com mais de 32 caracteres.

```bash
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

O `upgrade head` aplica as migrações necessárias para estruturar o banco de dados, incluindo o relacionamento do `dono_id`. Depois, abra a [documentação interativa da API](http://127.0.0.1:8000/docs).

## Como rodar o app

Abra outro terminal na raiz do repositório para executar os comandos abaixo.

Suba a API antes (ela precisa estar na porta 8000).

```
cd frontend
flutter pub get
flutter run -d chrome
```

As telas têm nome (`lib/routes.dart`) e o `main.dart` liga cada nome à tela. As telas de dentro do app passam pelo `RotaProtegida`: sem sessão, mostram o login.

A sessão (`SessaoService`) fica no topo do app, num `ChangeNotifierProvider`, e as telas a leem com `context.read` e `context.watch`: nenhuma recebe a sessão pelo construtor. O token é persistido e validado novamente ao recarregar a página.

O cadastro chama `POST /usuarios/` pelas mesmas camadas do login e já entra com a conta nova. Quando a API recusa (e-mail repetido, campo inválido), a frase aparece na tela.

O token fica no aparelho (`shared_preferences`, que no navegador é o `localStorage`), num repositório próprio, o `TokenRepository`. O `main` o restaura antes de abrir o app: se a API ainda o aceita, o F5 não derruba a sessão. O Sair apaga o token.

A tela de eventos chama GET /eventos/ pelas camadas do aplicativo (tela, EventoService, EventoRepository), com o token no cabeçalho, e mostra apenas os eventos de quem está logado, exibindo nome, local, data de início e data de fim. Ela possui quatro estados: carregando, erro (com botão Tentar de novo), lista vazia e listagem dos eventos.
Ao tocar em um evento, o aplicativo abre a tela de detalhes pela rota /evento, passando o ID nos arguments. A tela consulta a API (GET /eventos/{id}) para buscar e apresentar os dados atualizados do evento.

O app cria, edita e exclui eventos pelas camadas (tela, `EventoService`, `EventoRepository`), com o token no cabeçalho: `POST /eventos/`, `PATCH /eventos/{id}` e `DELETE /eventos/{id}`. Um formulário só (`FormularioScreen`) serve para criar e para editar, com os campos `nome`, `local`, `data_inicio` e `data_fim`.

A validação acontece nas duas pontas: o `validator` de cada campo antes de enviar, e a API, que recusa com 422 ou 409; a frase da API aparece na tela. Excluir pede confirmação num diálogo. Depois de cada operação, a tela fecha com `true`, e a lista pede os eventos de novo.

## Organização das pastas

```text
backend/
|-- alembic/
|-- app/
|   |-- eventos/          # models, schemas, controller, service, repository e erros
|   |-- usuarios/
|   |-- database.py
|   |-- seguranca.py
|   +-- main.py
|-- tests/
|   +-- test_eventos.py
|-- conftest.py
|-- .env.exemplo
|-- alembic.ini
|-- pyproject.toml
+-- poetry.lock
frontend/
|-- lib/
|   |-- models/
|   |-- repositories/
|   |-- services/
|   |-- screens/
|   |-- widgets/
|   |-- routes.dart
|   +-- main.dart
+-- test/
    |-- screens_test.dart
    |-- formulario_test.dart
    +-- lista_test.dart
docs/
prototipo/
```

## Testes

Não precisa da API no ar nem do navegador. Instale as dependências antes:
`poetry install` em `backend/` e `flutter pub get` em `frontend/`.
O projeto usa Python 3.14 ou superior e Poetry.

Na pasta `backend/`:

```powershell
poetry run pytest
```

São nove testes de endpoint: criar (201), recusar sem token (401), isolar os
eventos por dono, editar (200), excluir (204), evento inexistente (404), fim
anterior ao início (409), busca por nome e senha errada (401).

O `TestClient` executa o controller, o service e o repository reais.
O `conftest.py` configura `teste.db` e a chave de token antes de importar o
app. Cada teste começa com tabelas vazias; ao terminar, as tabelas e o arquivo
de teste são removidos. O banco do `.env` não é usado.

A RN02 de eventos (fim depois do início) substitui a regra de título repetido
da biblioteca do professor, conforme a orientação de usar uma regra da sua
entidade. As datas dos testes da API são relativas ao dia da execução para
não ficarem no passado.

Na pasta `frontend/`:

```powershell
flutter test
```

Para executar separadamente os arquivos novos da aula:

```powershell
flutter test test/formulario_test.dart
flutter test test/lista_test.dart
```

Os dois testes do formulário conferem os quatro campos obrigatórios e a
remoção das mensagens de nome e local quando preenchidos. Os dois testes da
lista usam `MockClient` para devolver um evento ou uma lista vazia.
A suíte anterior foi preservada em `test/screens_test.dart`.

Veja o roteiro para observar os testes passando e falhando em
[Encontro 14 — testes](docs/encontro-14-testes.md).
