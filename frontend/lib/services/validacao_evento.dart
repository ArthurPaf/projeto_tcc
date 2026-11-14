// Datas sem fuso representam o horário de Brasília (UTC-03:00).
// A conferência dos componentes impede DateTime de aceitar 31/02 como março.
DateTime? lerDataEvento(String texto) {
  final iso = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?(Z|[+-]\d{2}:\d{2})?)?$',
  ).firstMatch(texto.trim());
  final br = RegExp(
    r'^(\d{2})/(\d{2})/(\d{4})(?: (\d{2}):(\d{2})(?::(\d{2}))?)?$',
  ).firstMatch(texto.trim());
  final partes = iso ?? br;
  if (partes == null) return null;
  final ano = int.parse(partes.group(iso != null ? 1 : 3)!);
  final mes = int.parse(partes.group(2)!);
  final dia = int.parse(partes.group(iso != null ? 3 : 1)!);
  final hora = int.parse(partes.group(4) ?? '0');
  final minuto = int.parse(partes.group(5) ?? '0');
  final segundo = int.parse(partes.group(6) ?? '0');
  final data = DateTime.utc(ano, mes, dia, hora, minuto, segundo);
  if (ano < 1 ||
      ano > 9999 ||
      data.year != ano ||
      data.month != mes ||
      data.day != dia ||
      hora > 23 ||
      minuto > 59 ||
      segundo > 59) {
    return null;
  }
  final fuso = iso?.group(7);
  var deslocamento = -180;
  if (fuso == 'Z') {
    deslocamento = 0;
  } else if (fuso != null) {
    final horas = int.parse(fuso.substring(1, 3));
    final minutos = int.parse(fuso.substring(4, 6));
    if (horas > 23 || minutos > 59) return null;
    deslocamento = (horas * 60 + minutos) * (fuso[0] == '-' ? -1 : 1);
  }
  return data.subtract(Duration(minutes: deslocamento));
}

String? validarTextoEvento(String? valor, String campo, int limite) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Informe o $campo';
  if (texto.runes.length < 2 || texto.runes.length > limite) {
    return 'O $campo precisa ter de 2 a $limite caracteres';
  }
  return null;
}

String? validarDataEvento(String? valor, String campo) {
  if ((valor ?? '').trim().isEmpty) return 'Informe a data de $campo';
  if (lerDataEvento(valor!) == null) return 'Informe uma data de $campo válida';
  return null;
}
