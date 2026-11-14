from fastapi import APIRouter, Depends, status

from ..seguranca import get_current_user
from ..usuarios.models import Usuario
from . import service
from .schemas import EventoAtualizar, EventoCriar, EventoPublico

# Nenhuma rota roda sem token e o prefixo centraliza a rota de eventos
router = APIRouter(
    prefix="/eventos",
    tags=["Eventos"],
    dependencies=[Depends(get_current_user)],
)


@router.get("/", response_model=list[EventoPublico])
def listar(
    nome: str | None = None,            # ?nome=show  -- parâmetro de consulta opcional
    local: str | None = None,           # ?local=estadio
    usuario: Usuario = Depends(get_current_user),
):
    # Quem decide filtros e escopo por dono é a camada de negócio
    return service.listar(usuario, nome, local)


@router.post("/", response_model=EventoPublico, status_code=status.HTTP_201_CREATED)
def criar(
    dados: EventoCriar,
    usuario: Usuario = Depends(get_current_user),
):
    return service.criar(usuario, dados.model_dump())


@router.get("/{evento_id}", response_model=EventoPublico)
def buscar(
    evento_id: int,
    usuario: Usuario = Depends(get_current_user),
):
    return service.buscar(usuario, evento_id)


@router.patch("/{evento_id}", response_model=EventoPublico)
def atualizar(
    evento_id: int,
    dados: EventoAtualizar,
    usuario: Usuario = Depends(get_current_user),
):
    # exclude_unset=True impede que campos não enviados no JSON venham como None
    mudancas = dados.model_dump(exclude_unset=True)
    return service.atualizar(usuario, evento_id, mudancas)


@router.delete("/{evento_id}", status_code=status.HTTP_204_NO_CONTENT)
def apagar(
    evento_id: int,
    usuario: Usuario = Depends(get_current_user),
):
    service.apagar(usuario, evento_id)
