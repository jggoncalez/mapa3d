import 'package:flutter_test/flutter_test.dart';
import 'package:mapa3d/models/local.dart';
import 'package:mapa3d/services/filtro_locais.dart';
import 'package:mapa3d/utils/formatadores.dart';

Local _l(String nome, String categoria, String cidade,
        {double km = 1, bool favorito = false}) =>
    Local(
      id: nome,
      nome: nome,
      categoria: categoria,
      cidade: cidade,
      avaliacao: 4,
      distancia: km,
      horario: '',
      descricao: '',
      favorito: favorito,
    );

void main() {
  final locais = [
    _l('Academia Fitness', 'Academia', 'São Paulo', km: 3),
    _l('Iron Gym', 'Academia', 'Campinas', km: 1, favorito: true),
    _l('Sabor Paulista', 'Restaurante', 'São Paulo', km: 2),
    _l('Hospital Central', 'Hospital', 'Jundiaí'),
  ];

  group('filtrarLocais', () {
    test('T02 — pesquisa por "Academia" encontra por nome e por categoria', () {
      final r = filtrarLocais(locais, 'Academia', 'Todas', 'Todos');
      expect(r.map((l) => l.nome), ['Academia Fitness', 'Iron Gym']);
    });

    test('a pesquisa ignora maiúsculas/minúsculas', () {
      final r = filtrarLocais(locais, 'hOSpital', 'Todas', 'Todos');
      expect(r.map((l) => l.nome), ['Hospital Central']);
    });

    test('T03 — filtro por cidade', () {
      final r = filtrarLocais(locais, '', 'Campinas', 'Todos');
      expect(r.map((l) => l.nome), ['Iron Gym']);
    });

    test('T04 — filtro por categoria', () {
      final r = filtrarLocais(locais, '', 'Todas', 'Restaurante');
      expect(r.map((l) => l.nome), ['Sabor Paulista']);
    });

    test('combina cidade + categoria + texto', () {
      final r = filtrarLocais(locais, 'fit', 'São Paulo', 'Academia');
      expect(r.map((l) => l.nome), ['Academia Fitness']);
    });

    test('"Todas" e "Todos" não filtram', () {
      expect(filtrarLocais(locais, '', 'Todas', 'Todos').length, 4);
    });

    test('somenteFavoritos mostra apenas favoritos', () {
      final r = filtrarLocais(locais, '', 'Todas', 'Todos', somenteFavoritos: true);
      expect(r.map((l) => l.nome), ['Iron Gym']);
    });

    test('sem resultado devolve lista vazia', () {
      expect(filtrarLocais(locais, 'xyz', 'Todas', 'Todos'), isEmpty);
    });
  });

  test('ordenarPorDistancia ordena do mais perto ao mais longe', () {
    final r = ordenarPorDistancia(locais);
    expect(r.map((l) => l.distancia), [1, 1, 2, 3]);
    // não altera a lista original
    expect(locais.first.nome, 'Academia Fitness');
  });

  group('formatadores', () {
    test('formatarKm e formatarNota usam vírgula', () {
      expect(formatarKm(1.2), '1,2 km');
      expect(formatarNota(4.8), '4,8');
    });

    test('statusHorario informa aberto/fechado', () {
      final dentro = DateTime(2026, 1, 1, 10, 0);
      final fora = DateTime(2026, 1, 1, 23, 30);
      expect(statusHorario('06:00 - 22:00', agora: dentro), 'Aberto · 06:00 - 22:00');
      expect(statusHorario('06:00 - 22:00', agora: fora), 'Fechado · 06:00 - 22:00');
    });

    test('statusHorario aceita horário que passa da meia-noite', () {
      final r = statusHorario('18:00 - 02:00', agora: DateTime(2026, 1, 1, 1, 0));
      expect(r, 'Aberto · 18:00 - 02:00');
    });

    test('statusHorario devolve o texto original se não entender o formato', () {
      expect(statusHorario('24h'), '24h');
    });
  });
}
