"""As regras de conta e de login, e mais nada.

Nenhum HTTP ou SQL aqui: as funções de hash e token vêm de
app/seguranca.py; a consulta vem do repository. O service decide as regras.
"""
from .. import seguranca
from . import repository
from .erros import CredenciaisInvalidas, EmailJaCadastrado


def cadastrar(dados):
    # RN04: um e-mail, uma conta.
    if repository.buscar_por_email(dados["email"]):
        raise EmailJaCadastrado(f"Ja existe uma conta com o e-mail {dados['email']}")

    # A senha em texto chega ate' aqui e NAO passa deste ponto: o que vai
    # para o banco e' o hash.
    senha = dados.pop("senha")
    return repository.criar({**dados, "senha_hash": seguranca.gerar_hash(senha)})


def autenticar(email, senha):
    usuario = repository.buscar_por_email(email)
    if usuario is None or not seguranca.conferir_senha(senha, usuario.senha_hash):
        raise CredenciaisInvalidas("E-mail ou senha incorretos")
    return usuario


def entrar(email, senha):
    usuario = autenticar(email, senha)
    return {"access_token": seguranca.criar_token(usuario.id), "token_type": "bearer"}


def buscar_usuario_do_token(usuario_id):
    usuario = repository.buscar(usuario_id)
    if usuario is None:
        raise CredenciaisInvalidas("O usuario deste token nao existe mais")
    return usuario
