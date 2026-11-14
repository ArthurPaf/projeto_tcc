"""Consultas e sessoes da tabela de usuarios ficam nesta camada."""
from sqlalchemy.exc import IntegrityError
from ..database import SessionLocal
from .models import Usuario
from .erros import EmailJaCadastrado


def buscar(usuario_id: int):
    with SessionLocal() as db:
        return db.get(Usuario, usuario_id)


def buscar_por_email(email: str):
    with SessionLocal() as db:
        return db.query(Usuario).filter(Usuario.email == email).first()


def criar(dados: dict):
    with SessionLocal() as db:
        usuario = Usuario(**dados)
        db.add(usuario)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            raise EmailJaCadastrado("Ja existe uma conta com este e-mail")
        db.refresh(usuario)
        return usuario
