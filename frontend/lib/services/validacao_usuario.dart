import 'dart:convert';

String? validarNomeUsuario(String texto) {
  final tamanho = texto.trim().runes.length;
  return tamanho < 2 || tamanho > 80
      ? 'O nome precisa ter de 2 a 80 caracteres'
      : null;
}

String? validarEmail(String texto) {
  final email = texto.trim();
  return email.length > 120 ||
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? 'Informe um e-mail válido'
      : null;
}

String? validarSenha(String texto) {
  if (texto.runes.length < 6) {
    return 'A senha precisa ter pelo menos 6 caracteres';
  }
  if (utf8.encode(texto).length > 72) {
    return 'A senha deve ter no máximo 72 bytes em UTF-8';
  }
  return null;
}
