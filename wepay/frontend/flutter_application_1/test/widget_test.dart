// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Login screen is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const WePayApp());

    expect(find.text('WePay'), findsOneWidget);
    expect(find.text('Gerenciador de Gastos'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('Navigate to cadastro screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WePayApp());

    await tester.tap(find.text('Criar Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar Usuário'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Salvar Cadastro'),
      findsOneWidget,
    );
  });

  testWidgets('Dashboard route shows control panel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WePayApp());

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('WePay Home'), findsOneWidget);
    expect(find.text('Painel de Controle'), findsOneWidget);
    expect(find.text('Gerenciar Grupos'), findsOneWidget);
  });
}
