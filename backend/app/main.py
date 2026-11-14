import os

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from .eventos import controller as eventos_controller
from .eventos.erros import ErroDeEvento, EventoNaoEncontrado
from .usuarios import controller as usuarios_controller
from .usuarios.erros import CredenciaisInvalidas, ErroDeUsuario
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="API do Gerenciador de Eventos", version="0.5.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        origem.strip()
        for origem in [os.getenv("ENDERECO_DO_APP", ""), *os.getenv("CORS_ORIGINS", "").split(",")]
        if origem.strip()
    ],
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(usuarios_controller.router)
app.include_router(eventos_controller.router)


@app.exception_handler(ErroDeEvento)
def traduzir_recusa(request: Request, erro: ErroDeEvento):
    """O unico lugar do sistema que transforma recusa em numero HTTP."""
    codigo = 404 if isinstance(erro, EventoNaoEncontrado) else 409
    return JSONResponse(status_code=codigo, content={"detail": str(erro)})


@app.exception_handler(ErroDeUsuario)
def traduzir_recusa_de_usuario(request: Request, erro: ErroDeUsuario):
    if isinstance(erro, CredenciaisInvalidas):
        # 401 e' "nao sei quem voce e'". O cabecalho diz como se apresentar.
        return JSONResponse(
            status_code=401,
            content={"detail": str(erro)},
            headers={"WWW-Authenticate": "Bearer"},
        )
    return JSONResponse(status_code=409, content={"detail": str(erro)})
