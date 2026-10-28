import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapa3d/models/local.dart';
import 'package:mapa3d/widgets/local_card.dart';

Local _local({bool favorito = false}) => Local(
      id: '1',
      nome: 'Academia Fitness',
      categoria: 'Academia',
      cidade: 'São Paulo',
      avaliacao: 4.8,
      distancia: 1.2,
      horario: '06:00 - 22:00',
      descricao: 'Academia completa.',
      favorito: favorito,
    );

void main() {
  testWidgets('LocalCard mostra nome, categoria, distância e avaliação',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalCard(local: _local(), onTap: () {}),
        ),
      ),
    );

    expect(find.text('Academia Fitness'), findsOneWidget);
    expect(find.text('Academia'), findsOneWidget);
    expect(find.text('1,2 km'), findsOneWidget);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('LocalCard mostra o coração quando é favorito', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalCard(local: _local(favorito: true), onTap: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('LocalCard chama onTap ao tocar (abrir detalhes)', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalCard(local: _local(), onTap: () => toques++),
        ),
      ),
    );

    await tester.tap(find.text('Academia Fitness'));
    expect(toques, 1);
  });

  testWidgets('LocalCard oferece Editar e Excluir no menu', (tester) async {
    var editou = false;
    var excluiu = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalCard(
            local: _local(),
            onTap: () {},
            onEditar: () => editou = true,
            onExcluir: () => excluiu = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(editou, isTrue);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(excluiu, isTrue);
  });
}
