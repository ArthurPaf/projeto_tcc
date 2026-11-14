# API do Gerenciador de Eventos

API REST desenvolvida com FastAPI, SQLAlchemy e Pydantic. Implementa cadastro,
autenticação JWT e gerenciamento dos eventos de cada usuário.

## Organização

- `app/usuarios`: cadastro, login e consulta do usuário autenticado.
- `app/eventos`: CRUD, busca e regras de datas e propriedade dos eventos.
- `app/database.py`: configuração da conexão e fábrica de sessões.
- `app/seguranca.py`: hash de senha e verificação de tokens.
- `alembic`: migrações do banco.
- `tests`: testes dos endpoints e da configuração de conexão.

As rotas seguem Controller → Service → Repository. As sessões e operações
de banco ficam nos repositories.

## Execução

Requisitos: Python 3.14 ou superior e Poetry. Comandos nesta pasta:

```powershell
poetry install
Copy-Item .env.exemplo .env
```

Após configurar `DATABASE_URL` e `SECRET_KEY` no `.env`:

```powershell
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

Com Poetry instalado no ambiente virtual local, o executável é
`.\.venv\Scripts\poetry.exe`.

## Testes

```powershell
poetry run pytest
```

Os testes utilizam banco SQLite separado do banco da aplicação.

## Publicação

O Dockerfile usa esta pasta como contexto, instala apenas dependências de
produção e aplica as migrações antes de iniciar a API. A porta é definida
por `PORT`, com padrão 8000.

`DATABASE_URL`, `SECRET_KEY` e `ENDERECO_DO_APP` são configurados nas variáveis
da hospedagem. O `.dockerignore` exclui arquivos de ambiente, bancos locais,
caches e testes da imagem.

Documentação pública: [Swagger UI](https://projeto-tcc-sk89.onrender.com/docs).

Configuração completa: [README principal](../README.md).
