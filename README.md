Você é um designer de produto criando o protótipo navegável de uma aplicação.

CONTEXTO
Sistema de Sistema de gestão de eventos com carteira digital cashless (recarga de saldo e consumo). O usuário principal é Organizadores de evento, atendentes (caixa de recarga), vendedores (barracas/pontos de venda) e clientes (consumidores).

ENTIDADE PRINCIPAL
Evento, com os campos:
- id (inteiro, obrigatório)
- nome (texto, obrigatório)
- data_inicio (data/hora, obrigatório)
- data_fim (data/hora, obrigatório)
- local (texto, obrigatório)

Cada registro pertence a um usuário logado — Um organizador gerencia vários eventos; cada evento possui produtos e transações associadas que pertencem aos clientes, atendentes e vendedores.

TELAS (nesta ordem)
1. Login: e-mail e senha, link para cadastro, área para mensagem de erro.
2. Cadastro de usuário: nome, e-mail e senha, com as regras visíveis.
3. Listagem de Evento: Busca por nome do evento; filtro por período (data de início e fim) e por localização, um botão de criar em destaque, e o
   estado de lista vazia, com mensagem convidando a criar o primeiro registro.
4. Formulário de criar/editar Evento, com as validações visíveis.
5. Detalhe de um registro, com editar e excluir (excluir pede confirmação).

STACK DE DESTINO — leia com atenção
Este protótipo é descartável, mas ele vira a especificação de um aplicativo
Flutter que consome uma API FastAPI. Projete pensando nisso:
- Use Material Design 3 como linguagem visual.
- Layout em coluna única, pensado primeiro para celular.
- Não use nada que não tenha equivalente direto em Flutter: sem grid CSS
  complexo, sem hover como única forma de revelar informação, sem sticky.
- Todo estado de tela precisa existir e estar desenhado: carregando, vazio,
  erro e sucesso.

RESTRIÇÕES
- Não crie backend, banco de dados nem autenticação real: use dados de
  exemplo fixos, inventados.
- Não invente campos que não estão na lista acima.
- Todos os textos da interface em português do Brasil.




# Gerenciador de Eventos — o evento tem dono

O projeto com login e migrações, mais o que o checkpoint pede: o evento ganha **dono** (um usuário tem muitos eventos), cada pessoa enxerga e mexe só no próprio calendário, a listagem tem **busca e filtro** (por nome e local), e o `422` explica o que está errado em português. A coluna nova entrou por uma **migração** — o `create_all` não existe mais.

## O que é

Uma API robusta desenvolvida com **FastAPI**, **SQLAlchemy** e **Pydantic** para gestão personalizada de compromissos. O sistema implementa o padrão *multi-tenant* no nível de aplicação, garantindo o isolamento total dos dados: um usuário autenticado jamais consegue visualizar, editar ou apagar eventos criados por outras pessoas. 

## Como rodar

```bash
poetry install
```

Renomeie o arquivo `env.exemplo` para `.env` e configure as variáveis de ambiente (como a URL do banco PostgreSQL e a `SECRET_KEY` para geração dos tokens).

```bash
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```

O `upgrade head` aplica as migrações necessárias para estruturar o banco de dados (PostgreSQL), incluindo o relacionamento do `dono_id`. Depois, abra a documentação interativa em <http://127.0.0>.