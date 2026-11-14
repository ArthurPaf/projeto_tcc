# API do Gerenciador de Eventos

Esta pasta é a raiz de construção do Docker no Render.
O Dockerfile usa Python 3.14, instala apenas as dependências de produção,
aplica as migrações e inicia `app.main:app` na porta de `PORT` (padrão 8000).

Configure `DATABASE_URL`, `SECRET_KEY` e `ENDERECO_DO_APP` na hospedagem.
O endereço do app deve ser a origem HTTPS completa, sem barra final.
O `.dockerignore` impede a inclusão do `.env`, bancos locais e testes na imagem.

Para executar localmente nesta pasta:

```powershell
poetry install
Copy-Item .env.exemplo .env
# Configure o .env antes de aplicar as migrações.
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

Se o Poetry só estiver instalado no ambiente do projeto, substitua `poetry`
por `.\.venv\Scripts\poetry.exe`.

As instruções completas, os testes e o checklist ficam no [README principal](../README.md).
