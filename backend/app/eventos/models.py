from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
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
    dono_id = Column(Integer, ForeignKey("usuarios.id", name="fk_eventos_dono"), nullable=True)
    dono = relationship("Usuario", back_populates="eventos")
