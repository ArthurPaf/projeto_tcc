from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from .database import Base, engine
from .eventos import controller as eventos_controller
from .eventos.erros import ErroDeEvento, ErroDeEvento, EventoNaoEncontrado
from .usuarios import controller as usuarios_controller
from .usuarios.erros import CredenciaisInvalidas, ErroDeUsuario

# So' para a aula: cria as tabelas que ainda nao existem ao subir -- e agora
# ha' uma nova, usuarios. Ele NAO sabe alterar uma tabela que ja' existe:
# esse e' o assunto da pagina de migracoes (Alembic).
Base.metadata.create_all(bind=engine)

app = FastAPI(title="API do Meu Projeto", version="0.4.0")
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
