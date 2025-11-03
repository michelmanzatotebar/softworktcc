import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/perfil.dart';

void main() {
  group('Perfil - Testes Unitários', () {
    test('Deve criar Perfil com biografia vazia', () {
      final perfil = Perfil(
        biografia: '',
      );

      expect(perfil.biografia, '');
      expect(perfil.biografia.isEmpty, true);
    });

    test('Deve serializar Perfil para Map', () {
      final perfil = Perfil(
        biografia: '',
      );

      final perfilMap = perfil.toMap();

      expect(perfilMap, isA<Map<String, dynamic>>());
      expect(perfilMap['biografia'], '');
    });

    test('Deve deserializar Perfil de Map', () {
      final perfilMap = {
        'biografia': '',
      };

      final perfil = Perfil.fromMap(perfilMap);

      expect(perfil.biografia, '');
      expect(perfil.biografia, isA<String>());
    });
  });
}