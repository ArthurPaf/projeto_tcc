"""Pedidos reais à API, sem uvicorn e sem acessar o banco do projeto."""
from datetime import datetime, timedelta


# Datas relativas mantêm os eventos de teste no futuro.
INICIO = datetime.now().replace(microsecond=0) + timedelta(days=30)
EVENTO = {
    "nome": "Festival de Música",
    "local": "Praça Central",
    "data_inicio": INICIO.isoformat(),
    "data_fim": (INICIO + timedelta(hours=4)).isoformat(),
}


def entrar(cliente, email):
    cadastro = cliente.post(
        "/usuarios/", json={"nome": "Teste", "email": email, "senha": "segredo123"}
    )
    assert cadastro.status_code == 201
    resposta = cliente.post(
        "/usuarios/login", data={"username": email, "password": "segredo123"}
    )
    assert resposta.status_code == 200
    return {"Authorization": "Bearer " + resposta.json()["access_token"]}


def criar_evento(cliente, usuario):
    resposta = cliente.post("/eventos/", json=EVENTO, headers=usuario)
    assert resposta.status_code == 201
    return resposta.json()


def test_criar_um_evento_devolve_201_com_o_nome(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/eventos/", json=EVENTO, headers=ana)
    assert resposta.status_code == 201
    assert resposta.json()["nome"] == "Festival de Música"


def test_sem_token_a_api_recusa(cliente):
    resposta = cliente.get("/eventos/")
    assert resposta.status_code == 401


def test_o_bruno_nao_ve_o_evento_da_ana(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    bruno = entrar(cliente, "bruno@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    lista_da_ana = cliente.get("/eventos/", headers=ana).json()
    lista_do_bruno = cliente.get("/eventos/", headers=bruno).json()
    assert [item["id"] for item in lista_da_ana] == [evento["id"]]
    assert lista_do_bruno == []


def test_editar_muda_o_nome(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.patch(
        f"/eventos/{evento['id']}", json={"nome": "Feira de Tecnologia"}, headers=ana
    )
    assert resposta.status_code == 200
    assert resposta.json()["nome"] == "Feira de Tecnologia"


def test_excluir_tira_o_evento_da_lista(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.delete(f"/eventos/{evento['id']}", headers=ana)
    assert resposta.status_code == 204
    assert cliente.get("/eventos/", headers=ana).json() == []


def test_evento_que_nao_existe_devolve_404(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.get("/eventos/999", headers=ana)
    assert resposta.status_code == 404


def test_evento_que_termina_antes_de_comecar_devolve_409(cliente):
    # RN02: o fim do evento deve ser posterior ao início.
    ana = entrar(cliente, "ana@ifg.edu.br")
    dados = {**EVENTO, "data_fim": (INICIO - timedelta(hours=1)).isoformat()}
    resposta = cliente.post("/eventos/", json=dados, headers=ana)
    assert resposta.status_code == 409
    assert "RN02" in resposta.json()["detail"]
    assert cliente.get("/eventos/", headers=ana).json() == []


def test_a_busca_devolve_so_o_que_combina(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    criar_evento(cliente, ana)
    outro = cliente.post(
        "/eventos/", json={**EVENTO, "nome": "Feira de Tecnologia"}, headers=ana
    )
    assert outro.status_code == 201
    resposta = cliente.get("/eventos/", params={"nome": "festival"}, headers=ana)
    assert resposta.status_code == 200
    assert [item["nome"] for item in resposta.json()] == ["Festival de Música"]


def test_senha_errada_devolve_401(cliente):
    entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post(
        "/usuarios/login",
        data={"username": "ana@ifg.edu.br", "password": "senha-errada"},
    )
    assert resposta.status_code == 401
