"""Escolha do driver PostgreSQL sem abrir conexão com um servidor."""
import pytest
from sqlalchemy import create_engine

from app.database import normalizar_url


@pytest.mark.parametrize("prefixo", [
    "postgres://", "postgresql://", "postgresql+psycopg://", "postgresql+psycopg2://",
])
def test_postgres_usa_driver_instalado_e_preserva_parametros(prefixo):
    destino = "teste:senha%40teste@banco.invalid:5432/eventos?sslmode=require"
    url = normalizar_url(prefixo + destino)
    assert url == "postgresql+psycopg2://" + destino
    # create_engine importa o driver sem abrir conexão com o servidor.
    engine = create_engine(url)
    try:
        assert engine.dialect.driver == "psycopg2"
        assert engine.dialect.dbapi.__name__ == "psycopg2"
    finally:
        engine.dispose()


def test_sqlite_local_nao_e_alterado():
    assert normalizar_url("sqlite:///./eventos.db") == "sqlite:///./eventos.db"
