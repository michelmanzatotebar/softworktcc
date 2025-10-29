import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/avaliacao.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/cliente.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';

void main() {
  group('Avaliacao - Testes Unitários', () {
    test('Deve criar Avaliacao com todos os campos', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Excelente serviço',
        descricao: 'Trabalho muito bem feito',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      expect(avaliacao.id, 1);
      expect(avaliacao.titulo, 'Excelente serviço');
      expect(avaliacao.descricao, 'Trabalho muito bem feito');
      expect(avaliacao.categoria, 'Limpeza');
      expect(avaliacao.servico, servico);
      expect(avaliacao.cliente, cliente);
      expect(avaliacao.prestador, prestador);
      expect(avaliacao.nota, 5.0);
    });

    test('Deve criar Avaliacao sem serviço e sem nota', () {
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Dúvida sobre serviço',
        descricao: 'Como funciona?',
        categoria: 'Limpeza',
        cliente: cliente,
        prestador: prestador,
      );

      expect(avaliacao.servico, isNull);
      expect(avaliacao.nota, isNull);
      expect(avaliacao.titulo, 'Dúvida sobre serviço');
    });

    test('Deve serializar Avaliacao para Map', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Excelente serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final map = avaliacao.toMap();

      expect(map['id'], 1);
      expect(map['titulo'], 'Excelente serviço');
      expect(map['descricao'], 'Muito bom');
      expect(map['categoria'], 'Limpeza');
      expect(map['nota'], 5.0);
      expect(map['servico'], isA<Map<String, dynamic>>());
      expect(map['cliente'], isA<Map<String, dynamic>>());
      expect(map['prestador'], isA<Map<String, dynamic>>());
    });

    test('Deve serializar Avaliacao sem serviço', () {
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Sugestão',
        descricao: 'Gostaria de sugerir',
        categoria: 'Sugestao',
        cliente: cliente,
        prestador: prestador,
      );

      final map = avaliacao.toMap();

      expect(map['servico'], isNull);
      expect(map['nota'], isNull);
    });

    test('Deve deserializar Avaliacao de Map', () {
      final prestadorMap = {
        'id': 1,
        'nome': 'Laura Silva',
        'telefone': '11888777666',
        'senha': '654321',
        'email': 'laura@email.com',
        'cpfCnpj': '98765432100',
        'tipoConta': false,
        'logradouro': 'Av. Principal, 456',
        'cep': '87654321',
        'idade': 35,
        'solicitacao': null,
      };

      final servicoMap = {
        'id': 1,
        'nome': 'Limpeza',
        'descricao': 'Limpeza residencial',
        'valor': 150.0,
        'categoria': 'Limpeza',
        'prestador': prestadorMap,
      };

      final clienteMap = {
        'id': 2,
        'nome': 'Michel Cliente',
        'telefone': '11999888777',
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua das Flores, 123',
        'cep': '01234567',
        'idade': 30,
        'solicitacao': null,
      };

      final avaliacaoMap = {
        'id': 1,
        'titulo': 'Excelente serviço',
        'descricao': 'Muito bom',
        'categoria': 'Limpeza',
        'servico': servicoMap,
        'cliente': clienteMap,
        'prestador': prestadorMap,
        'nota': 5.0,
      };

      final avaliacao = Avaliacao.fromMap(avaliacaoMap);

      expect(avaliacao.id, 1);
      expect(avaliacao.titulo, 'Excelente serviço');
      expect(avaliacao.descricao, 'Muito bom');
      expect(avaliacao.categoria, 'Limpeza');
      expect(avaliacao.nota, 5.0);
      expect(avaliacao.servico, isNotNull);
      expect(avaliacao.servico!.nome, 'Limpeza');
      expect(avaliacao.cliente.nome, 'Michel Cliente');
      expect(avaliacao.prestador.nome, 'Laura Silva');
    });

    test('Deve deserializar Avaliacao sem serviço', () {
      final prestadorMap = {
        'id': 1,
        'nome': 'Laura Silva',
        'telefone': '11888777666',
        'senha': '654321',
        'email': 'laura@email.com',
        'cpfCnpj': '98765432100',
        'tipoConta': false,
        'logradouro': 'Av. Principal, 456',
        'cep': '87654321',
        'idade': 35,
        'solicitacao': null,
      };

      final clienteMap = {
        'id': 2,
        'nome': 'Michel Cliente',
        'telefone': '11999888777',
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua das Flores, 123',
        'cep': '01234567',
        'idade': 30,
        'solicitacao': null,
      };

      final avaliacaoMap = {
        'id': 1,
        'titulo': 'Dúvida',
        'descricao': 'Como funciona?',
        'categoria': 'Duvida',
        'servico': null,
        'cliente': clienteMap,
        'prestador': prestadorMap,
        'nota': null,
      };

      final avaliacao = Avaliacao.fromMap(avaliacaoMap);

      expect(avaliacao.servico, isNull);
      expect(avaliacao.nota, isNull);
    });

    test('Deve serializar e deserializar mantendo integridade', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final avaliacaoOriginal = Avaliacao(
        id: 1,
        titulo: 'Excelente serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 4.5,
      );

      final map = avaliacaoOriginal.toMap();
      final avaliacaoReconstruida = Avaliacao.fromMap(map);

      expect(avaliacaoReconstruida.id, avaliacaoOriginal.id);
      expect(avaliacaoReconstruida.titulo, avaliacaoOriginal.titulo);
      expect(avaliacaoReconstruida.descricao, avaliacaoOriginal.descricao);
      expect(avaliacaoReconstruida.categoria, avaliacaoOriginal.categoria);
      expect(avaliacaoReconstruida.nota, avaliacaoOriginal.nota);
      expect(avaliacaoReconstruida.cliente.nome, avaliacaoOriginal.cliente.nome);
      expect(avaliacaoReconstruida.prestador.nome, avaliacaoOriginal.prestador.nome);
    });

    test('Deve validar nota entre 0 e 5', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final notasValidas = [0.0, 1.0, 2.5, 3.0, 4.5, 5.0];

      for (var nota in notasValidas) {
        final avaliacao = Avaliacao(
          id: 1,
          titulo: 'Teste',
          descricao: 'Teste',
          categoria: 'Limpeza',
          servico: servico,
          cliente: cliente,
          prestador: prestador,
          nota: nota,
        );

        expect(avaliacao.nota, greaterThanOrEqualTo(0.0));
        expect(avaliacao.nota, lessThanOrEqualTo(5.0));
      }
    });

    test('Deve validar tipos de dados corretos', () {
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Teste',
        descricao: 'Teste',
        categoria: 'Limpeza',
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      expect(avaliacao.id, isA<int>());
      expect(avaliacao.titulo, isA<String>());
      expect(avaliacao.descricao, isA<String>());
      expect(avaliacao.categoria, isA<String>());
      expect(avaliacao.cliente, isA<Cliente>());
      expect(avaliacao.prestador, isA<PrestadorAutonomo>());
      expect(avaliacao.nota, isA<double>());
    });

    test('Deve criar avaliação do tipo Avaliacao', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Ótimo trabalho',
        descricao: 'Serviço excelente',
        categoria: 'Avaliacao',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      expect(avaliacao.categoria, 'Avaliacao');
      expect(avaliacao.nota, isNotNull);
      expect(avaliacao.servico, isNotNull);
    });

    test('Deve criar avaliação do tipo Sugestao', () {
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

      final sugestao = Avaliacao(
        id: 1,
        titulo: 'Sugestão de melhoria',
        descricao: 'Poderia adicionar...',
        categoria: 'Sugestao',
        cliente: cliente,
        prestador: prestador,
      );

      expect(sugestao.categoria, 'Sugestao');
      expect(sugestao.servico, isNull);
      expect(sugestao.nota, isNull);
    });

    test('Deve criar avaliação do tipo Duvida', () {
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

      final duvida = Avaliacao(
        id: 1,
        titulo: 'Como funciona?',
        descricao: 'Gostaria de saber...',
        categoria: 'Duvida',
        cliente: cliente,
        prestador: prestador,
      );

      expect(duvida.categoria, 'Duvida');
      expect(duvida.servico, isNull);
      expect(duvida.nota, isNull);
    });

    test('Deve manter relacionamentos entre entidades', () {
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
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Teste',
        descricao: 'Teste',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      expect(avaliacao.prestador.id, prestador.id);
      expect(avaliacao.cliente.id, cliente.id);
      expect(avaliacao.servico!.prestador.id, prestador.id);
      expect(identical(avaliacao.prestador, prestador), true);
      expect(identical(avaliacao.cliente, cliente), true);
    });

    test('Deve converter nota para double corretamente', () {
      final prestadorMap = {
        'id': 1,
        'nome': 'Laura Silva',
        'telefone': '11888777666',
        'senha': '654321',
        'email': 'laura@email.com',
        'cpfCnpj': '98765432100',
        'tipoConta': false,
        'logradouro': 'Av. Principal, 456',
        'cep': '87654321',
        'idade': 35,
        'solicitacao': null,
      };

      final clienteMap = {
        'id': 2,
        'nome': 'Michel Cliente',
        'telefone': '11999888777',
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua das Flores, 123',
        'cep': '01234567',
        'idade': 30,
        'solicitacao': null,
      };

      final avaliacaoMap = {
        'id': 1,
        'titulo': 'Teste',
        'descricao': 'Teste',
        'categoria': 'Limpeza',
        'servico': null,
        'cliente': clienteMap,
        'prestador': prestadorMap,
        'nota': 4,
      };

      final avaliacao = Avaliacao.fromMap(avaliacaoMap);

      expect(avaliacao.nota, isA<double>());
      expect(avaliacao.nota, 4.0);
    });

    test('Deve validar campos obrigatórios', () {
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Teste',
        descricao: 'Teste',
        categoria: 'Limpeza',
        cliente: cliente,
        prestador: prestador,
      );

      final map = avaliacao.toMap();

      expect(map['id'], isNotNull);
      expect(map['titulo'], isNotNull);
      expect(map['descricao'], isNotNull);
      expect(map['categoria'], isNotNull);
      expect(map['cliente'], isNotNull);
      expect(map['prestador'], isNotNull);
    });
  });
}