import 'package:flutter_test/flutter_test.dart';
import 'package:mapa3d/models/local.dart';

void main() {
  group('Local.fromMap', () {
    test('lê todos os campos do documento', () {
      final local = Local.fromMap('abc123', {
        'nome': 'Academia Fitness',
        'categoria': 'Academia',
        'cidade': 'São Paulo',
        'avaliacao': 4.8,
        'distancia': 1.2,
        'horario': '06:00 - 22:00',
        'descricao': 'Boa academia',
        'favorito': true,
        'latitude': -23.5,
        'longitude': -46.6,
      });

      expect(local.id, 'abc123');
      expect(local.nome, 'Academia Fitness');
      expect(local.categoria, 'Academia');
      expect(local.cidade, 'São Paulo');
      expect(local.avaliacao, 4.8);
      expect(local.distancia, 1.2);
      expect(local.horario, '06:00 - 22:00');
      expect(local.descricao, 'Boa academia');
      expect(local.favorito, isTrue);
      expect(local.latitude, -23.5);
      expect(local.longitude, -46.6);
    });

    test('converte int em double (Firestore pode devolver 4 em vez de 4.0)', () {
      final local = Local.fromMap('x', {'avaliacao': 4, 'distancia': 2});
      expect(local.avaliacao, 4.0);
      expect(local.distancia, 2.0);
    });

    test('usa valores padrão quando faltam campos', () {
      final local = Local.fromMap('x', {});
      expect(local.nome, '');
      expect(local.avaliacao, 0.0);
      expect(local.favorito, isFalse);
      expect(local.latitude, isNull);
      expect(local.longitude, isNull);
    });
  });

  group('Local.toMap', () {
    test('contém os 8 campos do modelo e não inclui o id', () {
      final map = Local(
        id: 'abc',
        nome: 'A',
        categoria: 'Academia',
        cidade: 'Campinas',
        avaliacao: 4.5,
        distancia: 3.0,
        horario: '08:00 - 18:00',
        descricao: 'd',
        favorito: false,
      ).toMap();

      expect(
        map.keys.toSet(),
        {
          'nome',
          'categoria',
          'cidade',
          'avaliacao',
          'distancia',
          'horario',
          'descricao',
          'favorito',
        },
      );
      expect(map.containsKey('id'), isFalse);
    });

    test('inclui latitude/longitude somente quando existem', () {
      final map = Local(
        id: '',
        nome: 'A',
        categoria: 'Academia',
        cidade: 'Campinas',
        avaliacao: 4.5,
        distancia: 3.0,
        horario: '',
        descricao: '',
        favorito: false,
        latitude: -22.9,
        longitude: -47.0,
      ).toMap();

      expect(map['latitude'], -22.9);
      expect(map['longitude'], -47.0);
    });
  });
}
