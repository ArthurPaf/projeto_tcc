import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

load_dotenv()

# Sem valor padrao de proposito: faltando a variavel, a aplicacao nao
# sobe apontando para o banco errado - ela reclama na hora de subir.
URL = os.environ["DATABASE_URL"]
# Alguns provedores entregam o prefixo antigo; o driver usa postgresql://.
if URL.startswith("postgres://"):
    URL = URL.replace("postgres://", "postgresql://", 1)

# O SQLite recusa ser usado de uma thread diferente da que abriu a
# conexao, e o FastAPI atende cada rota sincrona numa thread do pool.
# Esta e a UNICA linha do projeto que sabe qual banco esta' rodando -
# quando a URL vira postgresql://, ela some sozinha.
ARGS = {"check_same_thread": False} if URL.startswith("sqlite") else {}

engine = create_engine(URL, connect_args=ARGS, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False)


class Base(DeclarativeBase):
    """Todas as tabelas herdam daqui. E assim que o SQLAlchemy
    descobre quais existem.
    """
