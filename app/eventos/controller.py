from fastapi import APIRouter, HTTPException, status
from .schemas import EventoAtualizar, EventoCriar, EventoPublico

router = APIRouter(prefix="/eventos", tags=["Eventos"])


eventos: list[dict] = []


@router.get("/", response_model=list[EventoPublico])
def listar():
    return eventos

@router.post("/", response_model=EventoPublico, status_code=201)
def criar(dados: EventoCriar):
    novo = {"id": len(eventos) + 1, **dados.model_dump()}
    eventos.append(novo)
    return novo

@router.get("/{evento_id}", response_model=EventoPublico)
def buscar(evento_id: int):
    for e in eventos:
        if e["id"] == evento_id:
            return e
    raise HTTPException(status_code=404, detail="Evento nao encontrado")

@router.patch("/{evento_id}", response_model=EventoPublico)
def atualizar(evento_id: int, dados: EventoAtualizar):
    for e in eventos:
        if e["id"] == evento_id:
            e.update(dados.model_dump(exclude_unset=True))
            return e
    raise HTTPException(status_code=404, detail="Evento nao encontrado")

@router.delete("/{evento_id}", status_code=204)
def apagar(evento_id: int):
    for e in eventos:
        if e["id"] == evento_id:
            eventos.remove(e)
            return
    raise HTTPException(status_code=404, detail="Evento nao encontrado")
