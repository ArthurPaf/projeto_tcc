"""Banco exclusivo dos testes e cliente compartilhado, como no Encontro 14."""
import os
from pathlib import Path

# Antes do app: database.py e seguranca.py leem estas variáveis no import.
BANCO_TESTE = Path(__file__).parent / "teste.db"
os.environ["DATABASE_URL"] = f"sqlite:///{BANCO_TESTE.as_posix()}"
os.environ["SECRET_KEY"] = "uma-chave-so-para-os-testes-com-mais-de-32-letras"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app


@pytest.fixture
def cliente():
    # Cada teste começa vazio, mesmo depois de uma execução interrompida.
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    try:
        with TestClient(app) as cliente_teste:
            yield cliente_teste
    finally:
        Base.metadata.drop_all(engine)
        engine.dispose()
        BANCO_TESTE.unlink(missing_ok=True)
