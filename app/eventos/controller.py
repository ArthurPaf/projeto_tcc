from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..seguranca import get_current_user
from . import models
from .schemas import EventoAtualizar, EventoCriar, EventoPublico

router = APIRouter(prefix="/eventos", tags=["Eventos"],
    dependencies=[Depends(get_current_user)])


@router.get("/", response_model=list[EventoPublico])
def listar(db: Session = Depends(get_db)):
    return models.listar(db)


@router.post("/", response_model=EventoPublico, status_code=status.HTTP_201_CREATED)
def criar(dados: EventoCriar, db: Session = Depends(get_db)):
    return models.criar(db, dados.model_dump())


@router.get("/{evento_id}", response_model=EventoPublico)
def buscar(evento_id: int, db: Session = Depends(get_db)):
    evento = models.buscar(db, evento_id)
    if not evento:
        raise HTTPException(status_code=404, detail="Evento nao encontrado")
    return evento


@router.patch("/{evento_id}", response_model=EventoPublico)
def atualizar(evento_id: int, dados: EventoAtualizar, db: Session = Depends(get_db)):
    evento = models.buscar(db, evento_id)
    if not evento:
        raise HTTPException(status_code=404, detail="Evento nao encontrado")
    
    mudancas = dados.model_dump(exclude_unset=True)
    return models.atualizar(db, evento, mudancas)


@router.delete("/{evento_id}", status_code=status.HTTP_204_NO_CONTENT)
def apagar(evento_id: int, db: Session = Depends(get_db)):
    evento = models.buscar(db, evento_id)
    if not evento:
        raise HTTPException(status_code=404, detail="Evento nao encontrado")
    models.apagar(db, evento)
    return