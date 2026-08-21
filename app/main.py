from fastapi import FastAPI
from .eventos import controller as eventos_controller

app = FastAPI(title="API do Meu Projeto", version="0.1.0")
app.include_router(eventos_controller.router)
