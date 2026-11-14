# Encontro 14 — testes do projeto de eventos

O modelo de biblioteca foi adaptado para `Evento`, com `nome`, `local`,
`data_inicio` e `data_fim`. As pastas seguem a organização da aula.

## API: verde, vermelho e verde

1. Em `backend/`, rode `poetry run pytest`: a suíte deve passar. Os nove
   testes originais continuam em `tests/test_eventos.py`; a revisão da
   rubrica acrescentou os casos de validação em `tests/test_validacao.py`.
2. Em `backend/app/eventos/repository.py`, na função `listar`, troque
   temporariamente `consulta = db.query(Evento).filter(Evento.dono_id == dono_id)`
   por `consulta = db.query(Evento)`.
3. Rode `poetry run pytest` novamente. O teste
   `test_o_bruno_nao_ve_o_evento_da_ana` deve falhar: a lista do Bruno recebe
   o evento da Ana. Os demais devem continuar passando.
4. Restaure o filtro do dono e rode novamente: a suíte deve passar.

## Formulário: verde, vermelho e verde

1. Em `frontend/`, rode `flutter test test/formulario_test.dart`:
   todos os testes do arquivo devem passar.
2. Em `frontend/lib/screens/formulario_screen.dart`, no validator do nome,
   troque temporariamente `return validarTextoEvento(valor, 'nome', 120);`
   por `return null;`.
3. Rode o mesmo comando: o teste do formulário vazio deve falhar porque a
   mensagem não aparece. Os testes com nome preenchido devem continuar passando.
4. Restaure a mensagem e rode `flutter test` para conferir todos os testes.

Não entregue o código com as falhas temporárias.

## Arquivos da aula

- `backend/conftest.py`: banco e chave exclusivos dos testes.
- `backend/tests/test_eventos.py`: nove testes de endpoint.
- `backend/pyproject.toml`: pytest e httpx no grupo de desenvolvimento.
- `frontend/test/formulario_test.dart`: testes de validação do formulário.
- `frontend/test/lista_test.dart`: dois testes com API de mentira.
- `frontend/test/screens_test.dart`: suíte anterior preservada.
- `README.md`: comandos para executar os testes.

A RN02 (o fim deve ser depois do início) substitui o título repetido do
modelo: o projeto de eventos não proíbe nomes repetidos.

## Verificação realizada em 08/11/2026

- API funcionando: 9 testes passaram.
- API sem o filtro do dono, temporariamente: 1 falhou e 8 passaram.
- Filtro restaurado: os 9 testes voltaram a passar.
- Formulário sem a mensagem do nome, temporariamente: 1 falhou e 1 passou.
- Aplicativo com o código restaurado: 53 testes passaram, incluindo os 4 novos.
- Migrações: aplicação em banco SQLite vazio, conferência com os models
  (`alembic check`) e reversão até a base verificadas. A migração inicial,
  antes vazia, agora cria as tabelas de usuários e eventos.
- A busca do app passou a enviar `nome`, como a API de eventos espera,
  e o item do menu foi adaptado de Livros para Eventos.
