from pydantic import BaseModel, ConfigDict, field_validator


def _nome_legivel(nome: str) -> str:
    # Mensagem amigável para o erro 422
    if len(nome.strip()) < 2:
        raise ValueError("o nome precisa ter pelo menos 2 caracteres")
    return nome.strip()


def _local_valido(local: str) -> str:
    if len(local.strip()) < 2:
        raise ValueError("o local precisa ter pelo menos 2 caracteres")
    return local.strip()


class EventoCriar(BaseModel):        
    nome: str
    data_inicio: str  
    data_fim: str
    local: str

    @field_validator("nome")
    @classmethod
    def nome_legivel(cls, v):
        return _nome_legivel(v)

    @field_validator("local")
    @classmethod
    def local_valido(cls, v):
        return _local_valido(v)


class EventoPublico(BaseModel):      
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    data_inicio: str
    data_fim: str
    local: str
    dono_id: int | None = None   


class EventoAtualizar(BaseModel):    
    nome: str | None = None
    data_inicio: str | None = None
    data_fim: str | None = None
    local: str | None = None

    @field_validator("nome")
    @classmethod
    def nome_legivel(cls, v):
        return v if v is None else _nome_legivel(v)

    @field_validator("local")
    @classmethod
    def local_valido(cls, v):
        return v if v is None else _local_valido(v)
