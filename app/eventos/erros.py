class ErroDeEvento(Exception):
    """Qualquer recusa do acervo. Quem traduz para HTTP e o controller."""


class EventoNaoEncontrado(ErroDeEvento):
    """Evento nao existe."""
