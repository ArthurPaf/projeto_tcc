from pydantic import BaseModel, ConfigDict, field_validator
from .datas import normalizar_data


def _nome_legivel(nome: str) -> str:
    # Mensagem amigável para o erro 422
    if not 2 <= len(nome.strip()) <= 120:
        raise ValueError("o nome precisa ter de 2 a 120 caracteres")
    return nome.strip()


def _local_valido(local: str) -> str:
    if not 2 <= len(local.strip()) <= 50:
        raise ValueError("o local precisa ter de 2 a 50 caracteres")
    return local.strip()


class EventoCriar(BaseModel):        
    nome: str
    data_inicio: str  
    data_fim: str
    local: str

    @field_validator("data_inicio", "data_fim")
    @classmethod
    def data_valida(cls, v):
        return normalizar_data(v)

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

    @field_validator("nome", "local", "data_inicio", "data_fim", mode="before")
    @classmethod
    def recusar_nulo(cls, v):
        # Omitir mantém o valor; null explícito apagaria um campo obrigatório.
        if v is None:
            raise ValueError("o campo não pode ser nulo")
        return v

    @field_validator("data_inicio", "data_fim")
    @classmethod
    def data_valida(cls, v):
        return normalizar_data(v)

    @field_validator("nome")
    @classmethod
    def nome_legivel(cls, v):
        return v if v is None else _nome_legivel(v)

    @field_validator("local")
    @classmethod
    def local_valido(cls, v):
        return v if v is None else _local_valido(v)
