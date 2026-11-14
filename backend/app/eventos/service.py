"""As regras de negócio de eventos, e mais nada.

Este arquivo decide as regras puras. Toda regra recebe o `usuario` -- quem está
pedindo. Cada pessoa enxerga e mexe só no seu próprio calendário de eventos.
"""
from datetime import datetime
from .datas import FUSO_EVENTOS, ler_data
from . import repository
from .erros import (
    EventoNaoEncontrado,
    EventoNoPassado,
    CronologiaInvalida,
    ConflitoDeHorarioAtualizacao,
)


def listar(usuario, nome=None, local=None):
    # RN: Lista apenas os eventos pertencentes ao usuário logado
    return repository.listar(usuario.id, nome, local)


def buscar(usuario, evento_id):
    evento = repository.buscar(evento_id)
    # RN: Cada um enxerga só o que é seu. É 404 de propósito para segurança.
    if evento is None or evento.dono_id != usuario.id:
        raise EventoNaoEncontrado(f"Evento {evento_id} nao esta no seu calendario")
    return evento


def criar(usuario, dados):
    dt_inicio = ler_data(dados["data_inicio"])
    dt_fim = ler_data(dados["data_fim"])

    # RN01: O evento nao pode ser criado no passado
    if dt_inicio < datetime.now(FUSO_EVENTOS):
        raise EventoNoPassado("RN01: O evento nao pode ser criado no passado")

    # RN02: A data_fim precisa ser depois da data_inicio
    if dt_fim <= dt_inicio:
        raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")

    return repository.criar({**dados, "dono_id": usuario.id})



def atualizar(usuario, evento_id, mudancas):
    # Garante que o evento existe e pertence ao usuário antes de validar mudanças
    evento = buscar(usuario, evento_id)

    inicio = ler_data(mudancas.get("data_inicio", evento.data_inicio))
    fim = ler_data(mudancas.get("data_fim", evento.data_fim))
    if fim <= inicio:
        if "data_inicio" in mudancas and "data_fim" not in mudancas:
            raise ConflitoDeHorarioAtualizacao(
                "RN03: A nova data_inicio nao pode passar da data de termino salva"
            )
        raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")

    return repository.atualizar(evento.id, usuario.id, mudancas)


def apagar(usuario, evento_id):
    # Garante que o evento pertence ao usuário antes de deletar
    evento = buscar(usuario, evento_id)
    repository.apagar(evento.id, usuario.id)
