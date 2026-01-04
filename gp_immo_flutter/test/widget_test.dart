import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gp_immo_frontend/app.dart';
import 'package:gp_immo_frontend/app_shell.dart';
import 'package:gp_immo_frontend/screens/forms/property_form_screen.dart';
import 'package:gp_immo_frontend/screens/properties_screen.dart';
import 'package:gp_immo_frontend/state/app_state.dart';

void main() {
  AppState buildTestState() {
    final state = AppState();
    state.navIndex = 2;
    state.showOwner = true;
    return state;
  }

  Widget buildTestApp() {
    return GpImmoApp(
      home: const AppShell(),
      appStateBuilder: buildTestState,
    );
  }

  testWidgets('Voir tous ouvre la liste des biens', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 300));

    final viewAll = find.text('Voir tous');
    await tester.ensureVisible(viewAll);
    await tester.tap(viewAll);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PropertiesScreen), findsOneWidget);
  });

  testWidgets('Ajouter un bien ouvre le formulaire', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Ajouter un bien'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PropertyFormScreen), findsOneWidget);
  });
}
