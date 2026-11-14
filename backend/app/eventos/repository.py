"""Somente esta camada abre sessões e consulta a tabela de eventos."""
from ..database import SessionLocal
from .models import Evento
from .erros import EventoNaoEncontrado


def listar(dono_id: int, nome: str | None = None, local: str | None = None):
    with SessionLocal() as db:
        consulta = db.query(Evento).filter(Evento.dono_id == dono_id)
        if nome:
            consulta = consulta.filter(Evento.nome.ilike(f"%{nome}%"))
        if local:
            consulta = consulta.filter(Evento.local.ilike(f"%{local}%"))
        return consulta.order_by(Evento.data_inicio).all()


def buscar(evento_id: int):
    with SessionLocal() as db:
        return db.get(Evento, evento_id)


def criar(dados: dict):
    with SessionLocal() as db:
        evento = Evento(**dados)
        db.add(evento)
        db.commit()
        db.refresh(evento)
        return evento


def atualizar(evento_id: int, dono_id: int, mudancas: dict):
    with SessionLocal() as db:
        evento = db.query(Evento).filter(Evento.id == evento_id, Evento.dono_id == dono_id).first()
        if evento is None:
            raise EventoNaoEncontrado("O evento nao esta no seu calendario")
        for campo, valor in mudancas.items():
            setattr(evento, campo, valor)
        db.commit()
        db.refresh(evento)
        return evento


def apagar(evento_id: int, dono_id: int):
    with SessionLocal() as db:
        evento = db.query(Evento).filter(Evento.id == evento_id, Evento.dono_id == dono_id).first()
        if evento is None:
            raise EventoNaoEncontrado("O evento nao esta no seu calendario")
        db.delete(evento)
        db.commit()
