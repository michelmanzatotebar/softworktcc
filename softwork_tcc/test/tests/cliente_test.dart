import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/cliente.dart';

void main() {
  group('Cliente - Testes Unitários', () {
    test('Deve criar Cliente sem solicitação', () {
      // Arrange
      final cliente = Cliente(
        id: 1,
        nome: 'Michel Silva',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true, // true = cliente
        idade: 30,
        // solicitacao omitida = null
      );

      // Assert
      expect(cliente.id, 1);
      expect(cliente.nome, 'Michel Silva');
      expect(cliente.tipoConta, true); // Cliente
      expect(cliente.solicitacao, isNull);
    });

    test('Deve serializar Cliente sem solicitação', () {
      // Arrange
      final cliente = Cliente(
        id: 1,
        nome: 'Michel Silva',
        telefone: 11999887766,
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: 12345678901,
        tipoConta: true,
        idade: 30,
        solicitacao: null,
      );

      // Act
      final clienteMap = cliente.toMap();

      // Assert
      expect(clienteMap['id'], 1);
      expect(clienteMap['nome'], 'Michel Silva');
      expect(clienteMap['solicitacao'], isNull);
      expect(clienteMap['tipoConta'], true);
    });

    test('Deve deserializar Cliente com solicitacao null', () {
      // Arrange
      final clienteMap = {
        'id': 1,
        'nome': 'Michel Silva',
        'telefone': 11999887766,
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': 12345678901,
        'tipoConta': true,
        'idade': 30,
        'solicitacao': null,
      };

      // Act
      final cliente = Cliente.fromMap(clienteMap);

      // Assert
      expect(cliente.id, 1);
      expect(cliente.nome, 'Michel Silva');
      expect(cliente.solicitacao, isNull);
      expect(cliente.tipoConta, true);
    });
  });
}