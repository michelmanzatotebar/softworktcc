import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/login.dart';
import 'package:softwork_tcc/models/pessoa.dart';

void main() {
  group('Login - Testes Unitários', () {
    test('Deve gerenciar lista de usuários', () {

      final pessoa1 = Pessoa(
        id: 1,
        nome: 'Michel',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true,
        idade: 30,
      );

      final pessoa2 = Pessoa(
        id: 2,
        nome: 'Laura',
        telefone: 11888777666,
        senha: '654321',
        email: 'laura@email.com',
        cpfCnpj: 98765432100,
        tipoConta: false,
        idade: 35,
      );


      final login = Login(usuarios: [pessoa1, pessoa2]);


      expect(login.usuarios.length, 2);
      expect(login.usuarios[0].nome, 'Michel');
      expect(login.usuarios[1].nome, 'Laura');
    });

    test('Deve converter Login com usuários para Map', () {

      final pessoa = Pessoa(
        id: 1,
        nome: 'Michel',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true,
        idade: 30,
      );
      final login = Login(usuarios: [pessoa]);


      final map = login.toMap();


      expect(map['usuarios'], isA<List>());
      expect(map['usuarios'].length, 1);
      expect(map['usuarios'][0]['nome'], 'Michel');
    });
  });
}