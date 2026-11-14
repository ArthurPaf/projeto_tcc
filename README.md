# Gerenciador de Eventos

Aplicativo Flutter com API FastAPI e banco relacional. Cada organizador cria
uma conta, entra no sistema e gerencia apenas os próprios eventos.

## Checklist das seis funcionalidades

- [x] **Autenticação:** cadastro e login no app e na API, senha em hash bcrypt,
  token JWT e sessão persistida no aparelho.
- [x] **CRUD:** criar, listar, consultar detalhe, editar e excluir eventos,
  com confirmação antes de excluir.
- [x] **Relacionamento:** o dono vem do token; cada usuário só consulta,
  edita e exclui os próprios eventos.
- [x] **Validação:** campos e datas conferidos no formulário e novamente
  na API, com mensagens de recusa.
- [x] **Busca:** campo na lista; a API filtra os eventos pelo nome.
- [x] **Feedback:** avisos de sucesso e de erro nas ações de cadastro,
  login, busca, criação, edição, exclusão e saída.

## Organização

```text
backend/
|-- app/
|   |-- eventos/      # models, schemas, datas, controller, service, repository, erros
|   |-- usuarios/     # models, schemas, controller, service, repository, erros
|   |-- database.py   # conexão e fábrica de sessões
|   |-- seguranca.py  # hash e verificação de JWT
|   +-- main.py
|-- alembic/          # migrações
|-- tests/            # testes de endpoint
|-- conftest.py       # banco exclusivo dos testes
|-- Dockerfile
|-- .dockerignore     # exclui segredos, banco local e caches da imagem
|-- .env.exemplo
|-- pyproject.toml
+-- poetry.lock
frontend/
|-- lib/
|   |-- models/
|   |-- repositories/
|   |-- services/     # regras de sessão, eventos e validação
|   |-- screens/
|   |-- widgets/
|   |-- routes.dart
|   +-- main.dart
+-- test/             # testes de widget e regras do app
compose.yaml          # API e PostgreSQL com volume persistente
.env.exemplo          # configuração do Compose, sem credenciais
docs/
prototipo/
```

As rotas chamam os services; os services chamam os repositories. Somente os
repositories abrem sessões e fazem consultas ou gravações no banco. Os models
descrevem as tabelas e os schemas validam os dados de entrada e saída.
No aplicativo, as telas chamam os services; apenas os repositories fazem HTTP.

## Rodar localmente

Requisitos: Git, Python 3.14 ou superior, Poetry e Flutter compatível com Dart
3.13.3 ou superior. Execute os comandos a partir da raiz deste repositório.
Para conferir as ferramentas: `python --version`, `poetry --version` e
`flutter --version`. Caso falte apenas o Poetry, instale com
`python -m pip install poetry` (também pode usar `python -m poetry` nos comandos).

### API

No PowerShell:

```powershell
cd backend
poetry install
Copy-Item .env.exemplo .env
```

No Linux/macOS, use `cp .env.exemplo .env` no lugar de `Copy-Item`.
Edite o arquivo `backend/.env`: mantenha `DATABASE_URL=sqlite:///./eventos.db`
para usar SQLite localmente e substitua `SECRET_KEY` por uma chave própria.
Gere a chave com:

```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```

Ainda em `backend/`:

```powershell
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

API: [documentação interativa](http://127.0.0.1:8000/docs).
As migrações criam e atualizam as tabelas. O SQLite fica em `backend/eventos.db`.
Para PostgreSQL, altere `DATABASE_URL` para a URL do banco.

### Aplicativo

Abra outro terminal na raiz do repositório, mantendo a API em execução:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

O endereço local padrão da API é `http://127.0.0.1:8000`. Para usar outro
endereço, informe `--dart-define=API_URL=https://endereco-da-api`.
O login e o cadastro guardam o token com `shared_preferences`. A sessão é
restaurada após recarregar a página quando a API ainda aceita esse token.
Sair apaga o token. Senhas incorretas e tokens vencidos são recusados.

## Regras e validação

- Nome do evento: de 2 a 120 caracteres; local: de 2 a 50.
- Nome do usuário: de 2 a 80 caracteres; e-mail válido de até 120 caracteres.
- Senha: no mínimo 6 caracteres e no máximo 72 bytes em UTF-8. Acentos podem
  ocupar mais de um byte. O banco armazena somente o hash.
- As datas aceitam `AAAA-MM-DD`, `AAAA-MM-DDTHH:MM:SS`, `DD/MM/AAAA` ou
  `DD/MM/AAAA HH:MM` (com segundos opcionais). Datas ISO com fuso também são aceitas.
- Datas sem fuso representam o horário de Brasília, UTC-03:00. Datas com fuso
  são convertidas para esse horário antes de salvar. O banco guarda a forma
  `AAAA-MM-DDTHH:MM:SS`, que também permite ordenar cronologicamente.
- RN01: um evento novo não pode começar no passado.
- RN02: o fim deve ser depois do início, inclusive nas edições parciais.
- RN03: editar só o início não pode ultrapassar o fim já salvo.
- Campos obrigatórios não aceitam `null` na edição. Omitir um campo mantém o
  valor anterior. Campos inválidos recebem 422; recusas das regras de negócio,
  409; eventos inexistentes ou de outro usuário, 404; falha de autenticação, 401.
- Nomes repetidos são permitidos. Não existe campo de disponibilidade nem
  proibição de excluir eventos encerrados.

## Testes

Não precisa da API no ar nem do navegador. Depois de instalar as dependências:

Na pasta `backend/`:

```powershell
poetry run pytest
```

O `conftest.py` define a URL de `teste.db` e a chave do token antes de importar
o app. Cada teste começa com tabelas vazias e usa o `TestClient`, executando as
camadas reais. Depois, as tabelas e o banco de teste são removidos. O banco do
`.env` não é usado. A suíte cobre CRUD, dono, busca, login, datas, edição parcial,
valores nulos e limites de senha e campos.

Na pasta `frontend/`:

```powershell
flutter test
dart analyze
```

Os testes de widget usam HTTP simulado, sem inventar regras adicionais para
a entidade. O formulário é exercitado com campos vazios, data impossível e fim
anterior ao início. Há testes de login, cadastro, sessão, lista, detalhe,
CRUD, busca e feedback. Para executar só o formulário:

```powershell
flutter test test/formulario_test.dart
```

## API e PostgreSQL pelo Docker

Requisito adicional: Docker com Compose. Na raiz:

```powershell
Copy-Item .env.exemplo .env
```

Gere **dois valores distintos** com o comando de `secrets.token_hex(32)` acima
e preencha `POSTGRES_PASSWORD` e `SECRET_KEY` no `.env` da raiz. A senha em
hexadecimal evita caracteres especiais na URL do banco. Para acesso público,
preencha também `ENDERECO_DO_APP` com a origem HTTPS do aplicativo, sem barra final.

```powershell
docker compose up --build -d
docker compose logs -f api
```

O Compose inicia PostgreSQL com volume persistente, espera o banco ficar pronto
e inicia a API pelo `backend/Dockerfile`. O container aplica as migrações antes
de iniciar o Uvicorn em `0.0.0.0`, na porta indicada por `PORT` (padrão 8000).
Para parar sem apagar os dados: `docker compose down`.

## No ar

- O app: [https://projeto-tcc-1.onrender.com](https://projeto-tcc-1.onrender.com)
- A API: [https://projeto-tcc-sk89.onrender.com/docs](https://projeto-tcc-sk89.onrender.com/docs)

No plano gratuito, a API pode entrar em repouso após 15 minutos sem uso.
O primeiro acesso pode levar cerca de um minuto enquanto o serviço inicia.
Espere e tente novamente se o primeiro pedido não responder.

O endereço e as credenciais do banco ficam apenas nas variáveis protegidas
da hospedagem, em `DATABASE_URL`. Eles não são publicados neste README.

### Prova do sistema inteiro

Abra o app em uma janela anônima e confira:

- [ ] Criar uma conta e entrar pelo endereço público.
- [ ] Cadastrar um evento com início no futuro e fim depois do início.
- [ ] Buscar parte do nome e localizar o evento criado.
- [ ] Fechar a aba, abrir o app novamente, entrar se necessário e confirmar
  que o evento continua disponível.

Essa prova de cadastro e persistência deve ser concluída pelo navegador
público; os testes automatizados locais não substituem essa etapa.

## Publicação na web

### Publicar a API

No Render, configure a raiz do serviço como **`backend`** e use o
`Dockerfile` dessa pasta. Não é necessário instalar Docker no seu computador:
quem constrói a imagem é a hospedagem. O equivalente local, a partir da raiz
do repositório, seria:

```powershell
docker build -t eventos-api ./backend
```

Provisione um banco PostgreSQL persistente e configure no serviço da API:

- `DATABASE_URL`: URL privada do PostgreSQL fornecida pela hospedagem.
  O projeto normaliza `postgres://`, `postgresql://` e `postgresql+psycopg://`
  para `postgresql+psycopg2://`, selecionando o driver instalado. A API e as
  migrações usam essa mesma configuração; host, banco, senha e parâmetros
  da URL são preservados.
- `SECRET_KEY`: chave aleatória própria, diferente da usada localmente.
- `ENDERECO_DO_APP`: origem HTTPS exata do app, sem barra final, conforme
  o tutorial do professor.
- `CORS_ORIGINS`: opcional, para origens adicionais separadas por vírgula.
- `PORT`: porta definida pelo provedor, quando exigida.

Não copie arquivos `.env` para a imagem. O `backend/.dockerignore` exclui arquivos de
ambiente, bancos locais, caches e ambientes virtuais. Use variáveis protegidas
da hospedagem. Não publique senha ou URL de banco com credenciais no README.

### Publicar o aplicativo

Com a API já acessível por HTTPS, dentro de `frontend/` execute, substituindo
o endereço pelo endereço **real** da sua API, sem barra final:

```powershell
flutter pub get
flutter build web --release --dart-define=API_URL=https://endereco-real-da-api
```

Publique o conteúdo de `frontend/build/web` em uma hospedagem de arquivos
estáticos com HTTPS. O aplicativo usa as rotas com `#` do Flutter por padrão.
Depois de mudar `API_URL`, gere e publique um novo build.

Abra o endereço público em uma janela anônima e confira: criar conta, entrar,
criar, consultar, editar, buscar, provocar uma recusa de validação, excluir e
sair. Entre com outra conta e confirme que ela não vê os eventos da primeira.
Reinicie a API e confirme que os dados continuam no PostgreSQL. Depois de
concluir a prova pelo navegador, marque os itens da seção “No ar”.

## Apresentação e acompanhamento da rubrica

O histórico já tem commits em mais de quatro dias diferentes. O roteiro de
apresentação e a relação de cada critério com o código ficam em
[Rubrica e apresentação](docs/rubrica-e-apresentacao.md).
A nota da apresentação depende da demonstração e da explicação do código;
nenhum checklist substitui essa etapa. Os endereços públicos estão na seção
“No ar”; a comprovação completa da nuvem inclui a prova de cadastro e
persistência indicada nessa seção.
