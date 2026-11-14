from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm

from ..seguranca import get_current_user
from . import service
from .models import Usuario
from .schemas import Token, UsuarioCriar, UsuarioPublico

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.post("/", response_model=UsuarioPublico, status_code=201)
def cadastrar(dados: UsuarioCriar):
    return service.cadastrar(dados.model_dump())


@router.post("/login", response_model=Token)
def login(form: OAuth2PasswordRequestForm = Depends()):
    return service.entrar(form.username, form.password)


@router.get("/eu", response_model=UsuarioPublico)
def eu(usuario: Usuario = Depends(get_current_user)):
    """Quem sou eu? So' responde com um token valido -- e' o teste da porta."""
    return usuario
