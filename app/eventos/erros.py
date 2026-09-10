class ErroDeEvento(Exception):
    """Qualquer recusa do gerenciador de eventos. Quem traduz para HTTP é o controller."""


class EventoNaoEncontrado(ErroDeEvento):
    """Pediram um evento que não está cadastrado."""

class EventoNoPassado(ErroDeEvento):
    """RN01 - Tentaram criar ou agendar um evento em uma data que já passou."""


class CronologiaInvalida(ErroDeEvento):
    """RN02 - A data de término foi colocada antes ou junto da data de início."""


class ConflitoDeHorarioAtualizacao(ErroDeEvento):
    """RN03 - A nova data de início ultrapassou a data de término que já estava salva."""


class EventoEmAndamento(ErroDeEvento):
    """Não se pode apagar ou alterar o local de um evento que já está acontecendo."""