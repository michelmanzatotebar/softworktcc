import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/pessoa.dart';

void main() {
  group('Pessoa - Testes Unitários', () {
    test('Deve criar uma Pessoa com todos os atributos', () {

      final pessoa = Pessoa(
        id: 1,
        nome: 'Michel Silva',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true,
        idade: 30,
      );


      expect(pessoa.id, 1);
      expect(pessoa.nome, 'Michel Silva');
      expect(pessoa.telefone, 11999887766);
      expect(pessoa.senha, '123456');
      expect(pessoa.email, 'michel@email.com');
      expect(pessoa.cpfCnpj, 12345678901);
      expect(pessoa.tipoConta, true);
      expect(pessoa.idade, 30);
    });

    test('Deve converter Pessoa para Map corretamente', () {

      final pessoa = Pessoa(
        id: 1,
        nome: 'Michel Silva',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true,
        idade: 30,
      );


      final map = pessoa.toMap();


      expect(map['id'], 1);
      expect(map['nome'], 'Michel Silva');
      expect(map['telefone'], 11999887766);
      expect(map['senha'], '123456');
      expect(map['email'], 'michel@email.com');
      expect(map['cpfCnpj'], 12345678901);
      expect(map['tipoConta'], true);
      expect(map['idade'], 30);
    });

    test('Deve criar Pessoa a partir de Map corretamente', () {

      final map = {
        'id': 1,
        'nome': 'Michel Silva',
        'telefone': 11999887766,
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': 12345678901,
        'tipoConta': true,
        'idade': 30,
      };


      final pessoa = Pessoa.fromMap(map);


      expect(pessoa.id, 1);
      expect(pessoa.nome, 'Michel Silva');
      expect(pessoa.telefone, 11999887766);
      expect(pessoa.senha, '123456');
      expect(pessoa.email, 'michel@email.com');
      expect(pessoa.cpfCnpj, 12345678901);
      expect(pessoa.tipoConta, true);
      expect(pessoa.idade, 30);
    });
  });
}