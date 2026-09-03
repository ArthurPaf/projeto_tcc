from sqlalchemy.orm import Session

from .models import Evento

# A UNICA parte do sistema que sabe que existe um banco. Se aparecer um
# `db.query` fora daqui, a camada vazou.


def listar(db: Session):
    return db.query(Evento).all()


def buscar(db: Session, evento_id: int):
    return db.query(Evento).filter(Evento.id == evento_id).first()


def criar(db: Session, dados: dict):
    Evento = Evento(**dados)
    db.add(Evento)
    db.commit()
    db.refresh(Evento)   # o id nasce no banco; sem isto ele vem None
    return Evento


def buscar_por_titulo(db: Session, nome: str):
    return db.query(Evento).filter(Evento.nome == nome).first()


def atualizar(db: Session, evento: Evento, mudancas: dict):
    for campo, valor in mudancas.items():
        setattr(evento, campo, valor)
    db.commit()
    db.refresh(evento)
    return evento


def apagar(db: Session, Evento: Evento):
    db.delete(Evento)
    db.commit()
