"""Datas do calendário em horário de Brasília (UTC-03:00)."""
from datetime import datetime, timedelta, timezone

FUSO_EVENTOS = timezone(timedelta(hours=-3))


def ler_data(valor: str) -> datetime:
    texto = valor.strip()
    try:
        data = datetime.fromisoformat(texto)
    except ValueError:
        for formato in ("%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M", "%d/%m/%Y"):
            try:
                data = datetime.strptime(texto, formato)
                break
            except ValueError:
                continue
        else:
            raise ValueError("informe uma data válida: AAAA-MM-DD ou DD/MM/AAAA HH:MM")
    if data.tzinfo is None:
        data = data.replace(tzinfo=FUSO_EVENTOS)
    return data.astimezone(FUSO_EVENTOS)


def normalizar_data(valor: str) -> str:
    # Mantém o schema existente: 19 caracteres e ordem cronológica no banco.
    return ler_data(valor).replace(tzinfo=None).isoformat(timespec="seconds")
