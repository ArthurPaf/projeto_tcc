from pydantic import BaseModel, Field


class EventoCriar(BaseModel):       
    nome: str = Field(min_length=2)
    data_inicio: int = Field(gt=0)
    data_fim: int = Field(gt=0)
    local: str = Field(min_length=2)


class EventoPublico(BaseModel):     
    id: int
    nome: str
    data_inicio: int
    data_fim: int
    local: str


class EventoAtualizar(BaseModel):   
    nome: str | None = None
    data_inicio: int | None = None
    data_fim: int | None = None
    local: str | None = None
