"""Testes de validação e limites dos endpoints."""
from datetime import timedelta

import jwt
import pytest

from app.seguranca import SECRET_KEY, ALGORITMO
from .test_eventos import EVENTO, INICIO, entrar, criar_evento


def test_evento_no_passado_e_recusado(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/eventos/", json={**EVENTO, "data_inicio": "2000-01-01", "data_fim": "2000-01-02"}, headers=ana)
    assert resposta.status_code == 409
    assert "RN01" in resposta.json()["detail"]
    assert cliente.get("/eventos/", headers=ana).json() == []


@pytest.mark.parametrize("campo", ["data_inicio", "data_fim"])
def test_data_impossivel_na_edicao_nao_modifica_evento(cliente, campo):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.patch(f"/eventos/{evento['id']}", json={campo: "2030-02-31"}, headers=ana)
    assert resposta.status_code == 422
    assert cliente.get(f"/eventos/{evento['id']}", headers=ana).json() == evento


@pytest.mark.parametrize("valor", ["2030-02-31", "não é data", "", "2030-13-01"])
def test_data_invalida_devolve_422_sem_salvar(cliente, valor):
    ana = entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/eventos/", json={**EVENTO, "data_inicio": valor}, headers=ana)
    assert resposta.status_code == 422
    assert cliente.get("/eventos/", headers=ana).json() == []


@pytest.mark.parametrize("campo", ["nome", "local", "data_inicio", "data_fim"])
def test_edicao_nao_aceita_nulo_e_preserva_evento(cliente, campo):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.patch(f"/eventos/{evento['id']}", json={campo: None}, headers=ana)
    assert resposta.status_code == 422
    assert cliente.get(f"/eventos/{evento['id']}", headers=ana).json() == evento


@pytest.mark.parametrize("formato", ["brasileiro", "fuso"])
def test_datas_com_hora_sao_normalizadas_para_brasilia(cliente, formato):
    ana = entrar(cliente, "ana@ifg.edu.br")
    if formato == "brasileiro":
        inicio = INICIO.strftime("%d/%m/%Y %H:%M:%S")
        fim = (INICIO + timedelta(hours=4)).strftime("%d/%m/%Y %H:%M:%S")
    else:
        inicio = (INICIO + timedelta(hours=3)).isoformat() + "+00:00"
        fim = (INICIO + timedelta(hours=7)).isoformat() + "+00:00"
    resposta = cliente.post("/eventos/", json={**EVENTO, "data_inicio": inicio, "data_fim": fim}, headers=ana)
    assert resposta.status_code == 201
    assert resposta.json()["data_inicio"] == INICIO.isoformat()
    assert resposta.json()["data_fim"] == (INICIO + timedelta(hours=4)).isoformat()


def test_editar_so_inicio_respeita_fim_salvo(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.patch(f"/eventos/{evento['id']}", json={"data_inicio": evento["data_fim"]}, headers=ana)
    assert resposta.status_code == 409
    assert "RN03" in resposta.json()["detail"]
    assert cliente.get(f"/eventos/{evento['id']}", headers=ana).json() == evento


def test_editar_so_fim_respeita_inicio_salvo(cliente):
    ana = entrar(cliente, "ana@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    resposta = cliente.patch(f"/eventos/{evento['id']}", json={"data_fim": evento["data_inicio"]}, headers=ana)
    assert resposta.status_code == 409
    assert cliente.get(f"/eventos/{evento['id']}", headers=ana).json() == evento


@pytest.mark.parametrize("metodo", ["get", "patch", "delete"])
def test_outro_usuario_nao_consulta_nem_altera_evento(cliente, metodo):
    ana = entrar(cliente, "ana@ifg.edu.br")
    bruno = entrar(cliente, "bruno@ifg.edu.br")
    evento = criar_evento(cliente, ana)
    argumentos = {"headers": bruno}
    if metodo == "patch":
        argumentos["json"] = {"nome": "Tentativa de alteração"}
    resposta = getattr(cliente, metodo)(f"/eventos/{evento['id']}", **argumentos)
    assert resposta.status_code == 404
    assert cliente.get(f"/eventos/{evento['id']}", headers=ana).json() == evento


@pytest.mark.parametrize("senha", ["a" * 73, "é" * 37])
def test_senha_acima_de_72_bytes_recusada_no_cadastro_e_login(cliente, senha):
    resposta = cliente.post("/usuarios/", json={"nome": "Teste", "email": "teste@ifg.edu.br", "senha": senha})
    assert resposta.status_code == 422
    entrar(cliente, "ana@ifg.edu.br")
    resposta = cliente.post("/usuarios/login", data={"username": "ana@ifg.edu.br", "password": senha})
    assert resposta.status_code == 401


def test_senha_no_limite_funciona_e_nao_aparece_na_resposta(cliente):
    senha = "é" * 36
    resposta = cliente.post("/usuarios/", json={"nome": "Teste", "email": "teste@ifg.edu.br", "senha": senha})
    assert resposta.status_code == 201
    assert "senha" not in resposta.json() and "senha_hash" not in resposta.json()
    assert cliente.post("/usuarios/login", data={"username": "teste@ifg.edu.br", "password": senha}).status_code == 200


@pytest.mark.parametrize("campo,valor", [("nome", "a"), ("nome", "a" * 121), ("local", " "), ("local", "a" * 51)])
def test_limites_dos_campos_do_evento(cliente, campo, valor):
    ana = entrar(cliente, "ana@ifg.edu.br")
    assert cliente.post("/eventos/", json={**EVENTO, campo: valor}, headers=ana).status_code == 422


@pytest.mark.parametrize("conteudo", [{"sub": "abc", "exp": 9999999999}, {"sub": "1"}, {"exp": 9999999999}])
def test_token_com_campos_invalidos_devolve_401(cliente, conteudo):
    token = jwt.encode(conteudo, SECRET_KEY, algorithm=ALGORITMO)
    assert cliente.get("/eventos/", headers={"Authorization": f"Bearer {token}"}).status_code == 401
