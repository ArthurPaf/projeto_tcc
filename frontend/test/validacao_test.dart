import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/validacao_evento.dart';
import 'package:frontend/services/validacao_usuario.dart';

void main() {
  test('datas impossíveis e horas inválidas são recusadas', () {
    for (final data in [
      '2030-02-31',
      '31/02/2030',
      '2030-01-01T25:00',
      'abc',
    ]) {
      expect(lerDataEvento(data), isNull, reason: data);
    }
  });
  test('formato brasileiro, ISO e fuso representam o mesmo instante', () {
    expect(lerDataEvento('20/11/2030 18:00'), DateTime.utc(2030, 11, 20, 21));
    expect(
      lerDataEvento('2030-11-20T21:00:00Z'),
      lerDataEvento('2030-11-20T18:00:00-03:00'),
    );
  });
  test('limite de senha é em bytes, incluindo acentos', () {
    expect(validarSenha('é' * 36), isNull);
    expect(validarSenha('é' * 37), isNotNull);
    expect(validarSenha('12345'), isNotNull);
  });
}
