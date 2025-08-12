import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/cliente.dart';

void main() {
  group('Cliente - Testes Unitários', () {
    test('Deve criar Cliente sem solicitação', () {
      final cliente = Cliente(
        id: 1,
        nome: 'Michel Silva',
        telefone: '11999887766',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      expect(cliente.id, 1);
      expect(cliente.nome, 'Michel Silva');
      expect(cliente.tipoConta, true);
      expect(cliente.solicitacao, isNull);
    });

    test('Deve serializar Cliente sem solicitação', () {
      final cliente = Cliente(
        id: 1,
        nome: 'Michel Silva',
        telefone: '11999887766',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final clienteMap = cliente.toMap();

      expect(clienteMap['id'], 1);
      expect(clienteMap['nome'], 'Michel Silva');
      expect(clienteMap['solicitacao'], isNull);
      expect(clienteMap['tipoConta'], true);
    });

    test('Deve deserializar Cliente com solicitacao null', () {
      final clienteMap = {
        'id': 1,
        'nome': 'Michel Silva',
        'telefone': '11999887766',
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua das Flores, 123',
        'cep': '01234567',
        'idade': 30,
        'solicitacao': null,
      };

      final cliente = Cliente.fromMap(clienteMap);

      expect(cliente.id, 1);
      expect(cliente.nome, 'Michel Silva');
      expect(cliente.solicitacao, isNull);
      expect(cliente.tipoConta, true);
    });
  });
}