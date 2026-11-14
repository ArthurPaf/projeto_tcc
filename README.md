# Gerenciador de Eventos

Sistema de gestão de eventos com aplicativo Flutter, API FastAPI e banco
relacional. Cada usuário possui seu próprio calendário de eventos, com
cadastro, consulta, edição, exclusão e busca por nome.

## No ar

- Aplicativo: [projeto-tcc-1.onrender.com](https://projeto-tcc-1.onrender.com)
- API: [projeto-tcc-sk89.onrender.com/docs](https://projeto-tcc-sk89.onrender.com/docs)

No plano gratuito do Render, a API pode entrar em repouso após 15 minutos sem
uso. O primeiro acesso pode levar cerca de um minuto para iniciar o serviço.

## Checklist de funcionalidades

- [x] Autenticação: cadastro, login, hash de senha com bcrypt e token JWT.
- [x] CRUD: criação, listagem, detalhe, edição e exclusão de eventos.
- [x] Relacionamento: cada evento pertence ao usuário identificado pelo token.
- [x] Validação: conferência dos dados no formulário e na API.
- [x] Busca: filtro por nome executado pela API.
- [x] Feedback: mensagens de sucesso e erro nas ações do aplicativo.

## Tecnologias

- Aplicativo: Flutter, Dart, Provider, HTTP e Shared Preferences.
- API: Python, FastAPI, Pydantic e SQLAlchemy.
- Banco: SQLite para execução local e PostgreSQL na hospedagem.
- Migrações: Alembic.
- Testes: pytest, TestClient e flutter_test.
- Publicação: Docker e Render.

## Estrutura

```text
backend/
|-- app/
|   |-- eventos/
|   |-- usuarios/
|   |-- database.py
|   |-- seguranca.py
|   +-- main.py
|-- alembic/
|-- tests/
|-- conftest.py
|-- Dockerfile
|-- .dockerignore
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
docs/
prototipo/
```

Na API, o fluxo segue Controller → Service → Repository. Os controllers
recebem as requisições, os services aplicam as regras e os repositories abrem
as sessões e executam as operações de banco. Os models representam as tabelas
e os schemas definem os dados de entrada e saída.

No aplicativo, as telas utilizam services; as chamadas HTTP ficam nos
repositories, e os models representam os dados recebidos da API.

## Execução local

Requisitos: Python 3.14 ou superior, Poetry e Flutter compatível com Dart
3.13.3 ou superior. Os comandos abaixo partem da raiz do repositório.

### API

```powershell
cd backend
poetry install
```

O arquivo `backend/.env`, criado localmente, deve conter a configuração:

```env
DATABASE_URL=sqlite:///./eventos.db
SECRET_KEY=
ENDERECO_DO_APP=
CORS_ORIGINS=
```

`SECRET_KEY` deve ser preenchida com uma chave aleatória antes da inicialização.

| Variável | Descrição |
|---|---|
| DATABASE_URL | Conexão do banco; o exemplo utiliza `sqlite:///./eventos.db` |
| SECRET_KEY | Chave secreta para assinatura dos tokens JWT |
| ENDERECO_DO_APP | Origem pública do aplicativo, sem barra final |
| CORS_ORIGINS | Origens adicionais permitidas, separadas por vírgula |

Uma chave aleatória pode ser gerada com:

```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```

Após a configuração do `.env`, a aplicação das migrações e a inicialização
são feitas dentro de `backend/`:

```powershell
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

Documentação local: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs).

Quando o Poetry está instalado apenas no ambiente virtual do projeto,
`poetry` pode ser substituído por `.\.venv\Scripts\poetry.exe`.

### Aplicativo

Em outro terminal, a partir da raiz:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

O endereço local padrão da API é `http://127.0.0.1:8000`. A variável de
compilação `API_URL` permite configurar outro endereço:

```powershell
flutter run -d chrome --dart-define=API_URL=https://projeto-tcc-sk89.onrender.com
```

## Regras de negócio e validação

- O nome do evento deve ter de 2 a 120 caracteres; o local, de 2 a 50.
- O nome do usuário deve ter de 2 a 80 caracteres; o e-mail deve ser válido e
  ter no máximo 120 caracteres.
- A senha deve ter pelo menos 6 caracteres e no máximo 72 bytes em UTF-8.
  O banco armazena somente o hash.
- RN01: um evento novo não pode começar no passado.
- RN02: o fim deve ser posterior ao início, inclusive nas edições parciais.
- RN03: a alteração apenas do início deve respeitar o fim já cadastrado.
- Campos obrigatórios não aceitam `null` na edição. Campos omitidos mantêm
  seus valores anteriores.
- O dono do evento é obtido pelo token. Consultas e alterações em eventos de
  outro usuário retornam 404.

As datas aceitam os formatos `AAAA-MM-DD`, `AAAA-MM-DDTHH:MM:SS`,
`DD/MM/AAAA` e `DD/MM/AAAA HH:MM`, com segundos opcionais. Datas ISO com fuso
são convertidas para UTC-03:00; valores sem fuso representam esse horário.
O formato armazenado é `AAAA-MM-DDTHH:MM:SS`.

Erros de validação retornam 422; recusas das regras de negócio, 409; registros
inexistentes ou sem acesso, 404; falhas de autenticação, 401.

O token é armazenado com Shared Preferences. Ao recarregar o aplicativo, a
sessão é restaurada quando a API ainda aceita o token. A saída da conta remove
o token armazenado.

## Testes

Na pasta `backend/`:

```powershell
poetry run pytest
```

Os testes de endpoint usam TestClient e um banco SQLite exclusivo, configurado
pelo `conftest.py`. As tabelas começam vazias a cada teste; ao final, as tabelas
e o arquivo `teste.db` são removidos. O banco do `.env` não é utilizado.

Na pasta `frontend/`:

```powershell
flutter test
dart analyze
```

Os testes de widget utilizam respostas HTTP simuladas e verificam os fluxos
de autenticação, sessão, CRUD, busca, validação e feedback. A execução dos
testes não exige API ativa nem navegador aberto.

## Configuração de publicação

### API

O serviço Docker no Render utiliza `backend` como diretório raiz e o arquivo
`Dockerfile` dessa pasta. A construção local equivalente é:

```powershell
docker build -t eventos-api ./backend
```

A imagem instala as dependências de produção, aplica as migrações e inicia o
Uvicorn em `0.0.0.0`. A porta vem de `PORT`, com padrão 8000.

Na hospedagem, `DATABASE_URL` deve apontar para o PostgreSQL persistente.
As URLs com prefixo `postgres://`, `postgresql://` ou `postgresql+psycopg://`
são normalizadas para `postgresql+psycopg2://`, preservando os dados da conexão.

`ENDERECO_DO_APP` deve conter `https://projeto-tcc-1.onrender.com`, sem barra
final. A chave `SECRET_KEY` e as credenciais do banco ficam nas variáveis
protegidas da hospedagem. Os arquivos `.env` e os bancos locais são excluídos
do Git e da imagem Docker.

### Aplicativo

O site estático utiliza `frontend` como diretório raiz. A compilação recebe o
endereço público da API:

```powershell
flutter pub get
flutter build web --release --dart-define=API_URL=https://projeto-tcc-sk89.onrender.com
```

O diretório de publicação é `build/web`, relativo a `frontend`. Alterações
em `API_URL` exigem uma nova compilação. O roteamento utiliza URLs com `#`.
