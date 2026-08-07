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
