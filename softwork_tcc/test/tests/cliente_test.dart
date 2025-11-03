import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/cliente.dart';
import 'package:softwork_tcc/models/solicitacao.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';

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

  group('Cliente COM Solicitação', () {
    test('Deve criar Cliente com solicitação associada', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '654321',
        email: 'laura@email.com',
        cpfCnpj: '98765432100',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 35,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Limpeza Residencial',
        descricao: 'Limpeza completa',
        valor: 150.0,
        categoria: 'Casa',
        prestador: prestador,
      );

      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: '11999888777',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Preciso de limpeza',
        descricao: 'Limpeza urgente na minha casa',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 15, 10, 30),
        statusSolicitacao: 'Pendente',
      );

      cliente.solicitacao = solicitacao;

      expect(cliente.solicitacao, isNotNull);
      expect(cliente.solicitacao!.id, 1);
      expect(cliente.solicitacao!.titulo, 'Preciso de limpeza');
      expect(cliente.solicitacao!.statusSolicitacao, 'Pendente');
      expect(cliente.solicitacao!.cliente, cliente);
    });

    test('Deve criar Cliente com solicitação e validar dados', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '654321',
        email: 'laura@email.com',
        cpfCnpj: '98765432100',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 35,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Jardinagem',
        descricao: 'Cuidados com jardim',
        valor: 200.0,
        categoria: 'Jardim',
        prestador: prestador,
      );

      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: '11999888777',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Preciso de jardinagem',
        descricao: 'Meu jardim precisa de cuidados',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 16, 14, 0),
        statusSolicitacao: 'Pendente',
      );

      cliente.solicitacao = solicitacao;

      expect(cliente.id, 2);
      expect(cliente.nome, 'Michel Cliente');
      expect(cliente.solicitacao, isNotNull);
      expect(cliente.solicitacao!.titulo, 'Preciso de jardinagem');
      expect(cliente.solicitacao!.statusSolicitacao, 'Pendente');
    });

    test('Deve validar estrutura de Cliente com Solicitação', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '654321',
        email: 'laura@email.com',
        cpfCnpj: '98765432100',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 35,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Pintura',
        descricao: 'Serviço de pintura residencial',
        valor: 300.0,
        categoria: 'Reforma',
        prestador: prestador,
      );

      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: '11999888777',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Preciso de pintura',
        descricao: 'Pintar as paredes da casa',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 17, 9, 0),
        statusSolicitacao: 'Aceita',
      );

      cliente.solicitacao = solicitacao;

      expect(cliente.solicitacao, isNotNull);
      expect(cliente.solicitacao!.id, 1);
      expect(cliente.solicitacao!.titulo, 'Preciso de pintura');
      expect(cliente.solicitacao!.statusSolicitacao, 'Aceita');
      expect(cliente.solicitacao!.servico.nome, 'Pintura');
      expect(cliente.solicitacao!.servico.valor, 300.0);
      expect(cliente.solicitacao!.prestador.nome, 'Laura Silva');
    });
  });
}