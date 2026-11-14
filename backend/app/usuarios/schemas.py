from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class UsuarioCriar(BaseModel):        # ENTRA no cadastro
    nome: str = Field(min_length=2, max_length=80)
    email: EmailStr                   # "abc" nem chega ao seu codigo: 422
    senha: str = Field(min_length=6)

    @field_validator("nome", mode="before")
    @classmethod
    def limpar_nome(cls, valor):
        return valor.strip() if isinstance(valor, str) else valor

    @field_validator("email")
    @classmethod
    def limite_email(cls, valor):
        if len(valor) > 120:
            raise ValueError("o e-mail deve ter no máximo 120 caracteres")
        return valor

    @field_validator("senha")
    @classmethod
    def limite_senha(cls, valor):
        if len(valor.encode("utf-8")) > 72:
            raise ValueError("a senha deve ter no máximo 72 bytes em UTF-8")
        return valor


class UsuarioPublico(BaseModel):      # SAI na resposta -- sem senha, sem hash
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    email: EmailStr


class Token(BaseModel):               # SAI no login
    access_token: str
    token_type: str = "bearer"
