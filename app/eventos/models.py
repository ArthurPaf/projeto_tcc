from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import Session
from ..database import Base


class Evento(Base):
    """A TABELA. Nao confunda com os schemas: aquilo atravessa a
    fronteira da API, isto vira linha no banco.
    """

    __tablename__ = "evento"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(120), nullable=False)
    data_inicio = Column(String(20), nullable=False)
    data_fim = Column(String(20), nullable=False)
    local = Column(String(50), nullable=False)

def listar(db: Session):
    return db.query(Evento).all()


def buscar(db: Session, evento_id: int):
    return db.query(Evento).filter(Evento.id == evento_id).first()


def criar(db: Session, dados: dict):
    db_evento = Evento(**dados)
    db.add(db_evento)
    db.commit()
    db.refresh(db_evento)
    return db_evento


def buscar_por_titulo(db: Session, nome: str):
    return db.query(Evento).filter(Evento.nome == nome).first()


def atualizar(db: Session, evento: Evento, mudancas: dict):
    for campo, valor in mudancas.items():
        setattr(evento, campo, valor)
    db.commit()
    db.refresh(evento)
    return evento


def apagar(db: Session, evento_obj: Evento):
    db.delete(evento_obj)
    db.commit()