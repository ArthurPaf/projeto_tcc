from sqlalchemy.orm import Session
from .models import Evento

# A UNICA parte do sistema que sabe que existe um banco. Se aparecer um
# `db.query` fora daqui, a camada vazou.


def listar(db: Session, dono_id: int, nome: str | None = None, local: str | None = None):
    # A consulta vai sendo montada: o filtro do dono sempre entra; os outros,
    # so' quando quem chamou pediu. Nada vai ao banco ate' o .all().
    consulta = db.query(Evento).filter(Evento.dono_id == dono_id)
    if nome:
        consulta = consulta.filter(Evento.nome.ilike(f"%{nome}%"))
    if local:
        consulta = consulta.filter(Evento.local.ilike(f"%{local}%"))
    return consulta.order_by(Evento.data_inicio).all()


def buscar(db: Session, evento_id: int):
    return db.query(Evento).filter(Evento.id == evento_id).first()


def criar(db: Session, dados: dict):
    # Bug corrigido: a variável local agora usa letra minúscula (evento) 
    # para não sobrescrever a classe importada (Evento)
    evento = Evento(**dados)
    db.add(evento)
    db.commit()
    db.refresh(evento)   # o id nasce no banco; sem isto ele vem None
    return evento


def buscar_por_nome(db: Session, dono_id: int, nome: str):
    # Bug corrigido: os parâmetros dono_id, nome e os filtros foram mapeados corretamente
    return db.query(Evento).filter(Evento.dono_id == dono_id, Evento.nome == nome).first()


def atualizar(db: Session, evento: Evento, mudancas: dict):
    for campo, valor in mudancas.items():
        setattr(evento, campo, valor)
    db.commit()
    db.refresh(evento)
    return evento


def apagar(db: Session, evento: Evento):
    # Bug corrigido: variável alterada para minúscula para manter a consistência
    db.delete(evento)
    db.commit()
