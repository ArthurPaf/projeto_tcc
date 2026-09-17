"""As regras de negócio de eventos, e mais nada.

Este arquivo decide as regras puras. Toda regra recebe o `usuario` -- quem está
pedindo. Cada pessoa enxerga e mexe só no seu próprio calendário de eventos.
"""
from datetime import datetime
from . import repository
from .erros import (
    EventoNaoEncontrado,
    EventoNoPassado,
    CronologiaInvalida,
    ConflitoDeHorarioAtualizacao,
)


def listar(db, usuario, nome=None, local=None):
    # RN: Lista apenas os eventos pertencentes ao usuário logado
    return repository.listar(db, usuario.id, nome, local)


def buscar(db, usuario, evento_id):
    evento = repository.buscar(db, evento_id)
    # RN: Cada um enxerga só o que é seu. É 404 de propósito para segurança.
    if evento is None or evento.dono_id != usuario.id:
        raise EventoNaoEncontrado(f"Evento {evento_id} nao esta no seu calendario")
    return evento


def criar(db, usuario, dados):
    # Tenta ler no formato padrão internacional, se falhar tenta o brasileiro
    try:
        dt_inicio = datetime.fromisoformat(dados["data_inicio"])
    except ValueError:
        # Aceita formatos como "20/11/2026 18:00" ou "20/11/2026 18:00:00"
        try:
            dt_inicio = datetime.strptime(dados["data_inicio"].strip(), "%d/%m/%Y")
        except ValueError:
            dt_inicio = datetime.strptime(dados["data_inicio"].strip(), "%d/%m/%Y")

    try:
        dt_fim = datetime.fromisoformat(dados["data_fim"])
    except ValueError:
        try:
            dt_fim = datetime.strptime(dados["data_fim"].strip(), "%d/%m/%Y")
        except ValueError:
            dt_fim = datetime.strptime(dados["data_fim"].strip(), "%d/%m/%Y")

    # RN01: O evento nao pode ser criado no passado
    if dt_inicio < datetime.now():
        raise EventoNoPassado("RN01: O evento nao pode ser criado no passado")

    # RN02: A data_fim precisa ser depois da data_inicio
    if dt_fim <= dt_inicio:
        raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")

    return repository.criar(db, {**dados, "dono_id": usuario.id})



def atualizar(db, usuario, evento_id, mudancas):
    # Garante que o evento existe e pertence ao usuário antes de validar mudanças
    evento = buscar(db, usuario, evento_id)

    nova_str_inicio = mudancas.get("data_inicio")
    nova_str_fim = mudancas.get("data_fim")

    # Converte os valores salvos no banco para string (caso o banco retorne objetos datetime)
    # Garante que a conversão posterior para isoformat funcione sem falhas
    ev_inicio_str = evento.data_inicio.isoformat() if isinstance(evento.data_inicio, datetime) else str(evento.data_inicio)
    ev_fim_str = evento.data_fim.isoformat() if isinstance(evento.data_fim, datetime) else str(evento.data_fim)

    # Cenário 1: Atualizou o início, mas manteve o fim original do banco
    if nova_str_inicio and not nova_str_fim:
        dt_nova_inicio = datetime.fromisoformat(nova_str_inicio)
        dt_fim_banco = datetime.fromisoformat(ev_fim_str)
        if dt_nova_inicio >= dt_fim_banco:
            raise ConflitoDeHorarioAtualizacao(
                "RN03: A nova data_inicio nao pode passar da data de termino salva"
            )

    if nova_str_inicio and nova_str_fim:
        dt_nova_inicio = datetime.fromisoformat(nova_str_inicio)
        dt_nova_fim = datetime.fromisoformat(nova_str_fim)
        if dt_nova_fim <= dt_nova_inicio:
            raise CronologiaInvalida("RN02: A data_fim precisa ser depois da data_inicio")
            
    
    if nova_str_fim and not nova_str_inicio:
        dt_nova_fim = datetime.fromisoformat(nova_str_fim)
        dt_inicio_banco = datetime.fromisoformat(ev_inicio_str)
        if dt_nova_fim <= dt_inicio_banco:
            raise CronologiaInvalida("RN02: A nova data_fim nao pode ser anterior ao inicio salvo")

    return repository.atualizar(db, evento, mudancas)


def apagar(db, usuario, evento_id):
    # Garante que o evento pertence ao usuário antes de deletar
    evento = buscar(db, usuario, evento_id)
    repository.apagar(db, evento)
