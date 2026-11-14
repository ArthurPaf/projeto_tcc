import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/formulario_screen.dart';

// Uma tela embaixo evita o comportamento de F5, que mostra a lista.
Future<void> abrirOFormulario(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold()));
  Navigator.of(tester.element(find.byType(Scaffold)))
      .push(MaterialPageRoute(builder: (_) => const FormularioScreen()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('data impossível fica no formulário sem enviar à API', (
    tester,
  ) async {
    await abrirOFormulario(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Encontro Cultural',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Centro Cultural');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '31/02/2090 18:00',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      '01/03/2090 22:00',
    );
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('Informe uma data de início válida'), findsOneWidget);
    expect(find.byType(FormularioScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fim anterior ao início é recusado na tela', (tester) async {
    await abrirOFormulario(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Encontro Cultural',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Centro Cultural');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '01/03/2090 18:00',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      '01/03/2090 17:00',
    );
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    expect(find.text('O fim precisa ser depois do início'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o formulário vazio mostra as quatro frases', (tester) async {
    await abrirOFormulario(tester);
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome'), findsOneWidget);
    expect(find.text('Informe o local'), findsOneWidget);
    expect(find.text('Informe a data de início'), findsOneWidget);
    expect(find.text('Informe a data de fim'), findsOneWidget);
  });

  testWidgets('com nome e local preenchidos, as datas continuam recusadas', (
    tester,
  ) async {
    await abrirOFormulario(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Encontro Cultural',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Centro Cultural');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome'), findsNothing);
    expect(find.text('Informe o local'), findsNothing);
    expect(find.text('Informe a data de início'), findsOneWidget);
    expect(find.text('Informe a data de fim'), findsOneWidget);
  });
}
