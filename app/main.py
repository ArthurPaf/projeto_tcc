from fastapi import FastAPI
from .eventos import controller as eventos_controller

app = FastAPI(title="API do Meu Projeto", version="0.1.0")
app.include_router(eventos_controller.router)
from fastapi import FastAPI

from .database import Base, engine

# So' para a aula: cria as tabelas ao subir. Em projeto de verdade quem
# faz isso e' uma ferramenta de migracao (Alembic), assunto de outro dia.
Base.metadata.create_all(bind=engine)

app = FastAPI(title="API do Meu Projeto", version="0.2.0")

app.include_router(eventos_controller.router)
@app.get("/")
def raiz():
    return {"status": "de pe"}
