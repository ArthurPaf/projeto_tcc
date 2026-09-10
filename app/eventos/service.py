from datetime import datetime
from . import repository
from .erros import (
    EventoNaoEncontrado,
    EventoNoPassado,
    CronologiaInvalida,
    ConflitoDeHorarioAtualizacao,
)


def listar(db):
    return repository.listar(db)


def buscar(db, evento_id):
    evento = repository.buscar(db, evento_id)
    if evento is None:
        raise EventoNaoEncontrado(f"Evento {evento_id} nao foi encontrado")
    return evento


def criar(db, dados):
    
    if dados["data_inicio"] < datetime.now():
        raise EventoNoPassado("RN01: O evento nao pode ser criado no passado")

    if dados["data_fim"] <= dados["data_inicio"]:
        raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")

    return repository.criar(db, dados)


def atualizar(db, evento_id, mudancas):
    evento = buscar(db, evento_id)

    nova_data_inicio = mudancas.get("data_inicio")
    nova_data_fim = mudancas.get("data_fim")

    if nova_data_inicio and not nova_data_fim:
        if nova_data_inicio >= evento.data_fim:
            raise ConflitoDeHorarioAtualizacao(
                "RN03: A nova data_inicio nao pode passar da data de termino salva"
            )

    if nova_data_inicio and nova_data_fim:
        if nova_data_fim <= nova_data_inicio:
            raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")
            
    if nova_data_fim and not nova_data_inicio:
        if nova_data_fim <= evento.data_inicio:
            raise CronologiaInvalida("RN02: A nova data_fim nao pode ser anterior ao inicio salvo")

    return repository.atualizar(db, evento, mudancas)


def apagar(db, evento_id):
    evento = buscar(db, evento_id)
    repository.apagar(db, evento)
