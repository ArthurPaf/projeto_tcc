# Rubrica e apresentação

## Critérios implementados no código

| Critério | Onde conferir |
|---|---|
| Autenticação | `backend/app/usuarios/`, `backend/app/seguranca.py`, telas de login e cadastro, `SessaoService` |
| CRUD | `backend/app/eventos/`, `EventoService`, telas de lista, formulário e detalhe |
| Relacionamento | `get_current_user`, filtro `dono_id` no repository, verificação do dono no service e nos testes |
| Validação | schemas da API, service de eventos, `validacao_evento.dart` e `validacao_usuario.dart` |
| Busca | campo em `EventosScreen`, parâmetro `nome` na API, filtro no repository |
| Feedback | `aviso.dart` e chamadas nas ações de cadastro, login, busca, salvar, excluir e sair |
| Camadas | controllers → services → repositories; sessões e SQL somente nos repositories; models só descrevem tabelas |
| Testes | `backend/tests/` e `frontend/test/`; comandos no README |
| README | instalação, seis funcionalidades, testes e publicação |
| Histórico | commits em mais de quatro dias diferentes; consultar `git log --format=%ad --date=short` |

## O que depende da publicação e da apresentação

- [ ] App público por HTTPS e API pública acessível.
- [ ] PostgreSQL persistente configurado na hospedagem.
- [ ] API construída pelo Dockerfile e migrações aplicadas.
- [ ] Cadastro, login e criação de evento pelo endereço público verificados.
- [ ] Endereços reais preenchidos no README, sem credenciais.
- [ ] Demonstração ensaiada e explicação das camadas preparada.

O projeto inclui Dockerfile e Compose, mas esses arquivos não significam que
a hospedagem já foi feita. O banco usa URL privada; não exponha suas credenciais.

## Roteiro de demonstração

1. Abra o app e cadastre uma conta de organizador.
2. Saia e entre com o e-mail e a senha dessa conta.
3. Crie um evento com nome e local válidos e início pelo menos um dia no futuro.
   Use `DD/MM/AAAA HH:MM`, com o fim depois do início.
4. Abra o detalhe e mostre os quatro campos.
5. Edite o local, salve e mostre o aviso e a lista atualizada.
6. Busque parte do nome e explique que a API faz o filtro.
7. Tente criar um evento com `31/02/2090 18:00` ou fim anterior ao início.
   Mostre a recusa na tela; pelos testes da API, mostre que a API também valida.
8. Exclua o evento: primeiro cancele o diálogo, depois confirme.
9. Saia e confirme o aviso e o retorno ao login.
10. Opcionalmente, mostre uma segunda conta sem acesso aos eventos da primeira.

## Como explicar o código

Siga um exemplo completo, como salvar um evento:

- `FormularioScreen`: recebe os dados, chama os validators e mostra os avisos.
- `EventoService` do app: obtém o token e traduz recusas do repository.
- `EventoRepository` do app: monta o POST e converte JSON em `Evento`.
- Controller da API: recebe a requisição validada e identifica o usuário.
- Service da API: decide as regras de datas e de dono.
- Repository da API: abre e fecha a sessão, salva e devolve os dados.
- Model: descreve a tabela; schema: define a entrada e a saída.

JWT identifica quem pede; bcrypt protege a senha; Alembic versiona as tabelas;
o Dockerfile prepara o ambiente que sobe a API. Os testes de widget simulam
HTTP; os testes de endpoint executam a API real com um banco exclusivo.

## Verificação das correções — 14/11/2026

- 37 testes da API passaram, incluindo datas inválidas, fusos, campos nulos,
  limites de senha, edição parcial e acesso aos eventos de outro usuário.
- 58 testes do app passaram, incluindo formulário e fluxos com HTTP simulado.
- Build web de produção gerado com `API_URL` configurável. O endereço usado
  para conferir a compilação é fictício; gere um novo build com a URL real
  antes de hospedar `build/web`.
- Análise direta com `dart analyze --format machine` concluída sem avisos.
  O comando `flutter analyze` apresentou uma falha interna de protocolo neste
  ambiente; a checagem foi realizada pelo analisador Dart diretamente.
- Migrações aplicadas em SQLite vazio, conferidas com `alembic check` e
  revertidas até a base com sucesso.
- CORS conferido: a origem pública configurada é aceita; outra origem é
  recusada pelo navegador por não receber permissão de acesso.
- Dockerfile e Compose preparados. Docker não está instalado neste ambiente;
  o build do container e a execução com PostgreSQL ainda precisam ser
  confirmados na máquina/hospedagem que fará a publicação.
- Publicação real e demonstração permanecem pendentes.
