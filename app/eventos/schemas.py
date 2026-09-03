from pydantic import BaseModel, Field


class EventoCriar(BaseModel):       
    nome: str = Field(min_length=2)
    data_inicio: str = Field
    data_fim: str = Field
    local: str = Field(min_length=2)


class EventoPublico(BaseModel):     
    id: int
    nome: str
    data_inicio: str
    data_fim: str
    local: str


class EventoAtualizar(BaseModel):   
    nome: str | None = None
    data_inicio: str | None = None
    data_fim: str | None = None
    local: str | None = None
