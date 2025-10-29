import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/visualizar_avaliacao.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';
import 'package:softwork_tcc/models/avaliacao.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/cliente.dart';

void main() {
  group('VisualizarAvaliacao - Testes Unitários', () {
    test('Deve criar VisualizarAvaliacao com lista vazia de avaliações', () {
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

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [],
      );

      expect(visualizar.id, 1);
      expect(visualizar.prestador, prestador);
      expect(visualizar.avaliacoes, isEmpty);
      expect(visualizar.avaliacoes, isA<List<Avaliacao>>());
    });

    test('Deve criar VisualizarAvaliacao com múltiplas avaliações', () {
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

      final avaliacao1 = Avaliacao(
        id: 1,
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final avaliacao2 = Avaliacao(
        id: 2,
        titulo: 'Bom trabalho',
        descricao: 'Satisfeito',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 4.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao1, avaliacao2],
      );

      expect(visualizar.avaliacoes.length, 2);
      expect(visualizar.avaliacoes[0].titulo, 'Ótimo serviço');
      expect(visualizar.avaliacoes[1].titulo, 'Bom trabalho');
    });

    test('Deve serializar VisualizarAvaliacao para Map', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      final map = visualizar.toMap();

      expect(map['id'], 1);
      expect(map['prestador'], isA<Map<String, dynamic>>());
      expect(map['avaliacoes'], isA<List>());
      expect(map['avaliacoes'].length, 1);
      expect(map['prestador']['nome'], 'Laura Silva');
    });

    test('Deve deserializar VisualizarAvaliacao de Map', () {
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
        'titulo': 'Ótimo serviço',
        'descricao': 'Muito bom',
        'categoria': 'Limpeza',
        'servico': servicoMap,
        'cliente': clienteMap,
        'prestador': prestadorMap,
        'nota': 5.0,
      };

      final visualizarMap = {
        'id': 1,
        'prestador': prestadorMap,
        'avaliacoes': [avaliacaoMap],
      };

      final visualizar = VisualizarAvaliacao.fromMap(visualizarMap);

      expect(visualizar.id, 1);
      expect(visualizar.prestador.nome, 'Laura Silva');
      expect(visualizar.avaliacoes.length, 1);
      expect(visualizar.avaliacoes[0].titulo, 'Ótimo serviço');
      expect(visualizar.avaliacoes[0].nota, 5.0);
    });

    test('Deve serializar e deserializar mantendo integridade dos dados', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizarOriginal = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      final map = visualizarOriginal.toMap();
      final visualizarReconstruido = VisualizarAvaliacao.fromMap(map);

      expect(visualizarReconstruido.id, visualizarOriginal.id);
      expect(visualizarReconstruido.prestador.nome, visualizarOriginal.prestador.nome);
      expect(visualizarReconstruido.avaliacoes.length, visualizarOriginal.avaliacoes.length);
      expect(visualizarReconstruido.avaliacoes[0].titulo, visualizarOriginal.avaliacoes[0].titulo);
    });

    test('Deve filtrar avaliações por categoria', () {
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

      final servicoLimpeza = Servico(
        id: 1,
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Limpeza',
        prestador: prestador,
      );

      final servicoJardinagem = Servico(
        id: 2,
        nome: 'Jardinagem',
        descricao: 'Cuidados com jardim',
        valor: 200.0,
        categoria: 'Jardinagem',
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

      final avaliacaoLimpeza1 = Avaliacao(
        id: 1,
        titulo: 'Ótima limpeza',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servicoLimpeza,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final avaliacaoLimpeza2 = Avaliacao(
        id: 2,
        titulo: 'Boa limpeza',
        descricao: 'Satisfeito',
        categoria: 'Limpeza',
        servico: servicoLimpeza,
        cliente: cliente,
        prestador: prestador,
        nota: 4.0,
      );

      final avaliacaoJardinagem = Avaliacao(
        id: 3,
        titulo: 'Ótimo jardim',
        descricao: 'Excelente',
        categoria: 'Jardinagem',
        servico: servicoJardinagem,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacaoLimpeza1, avaliacaoLimpeza2, avaliacaoJardinagem],
      );

      final avaliacoesLimpeza = visualizar.filtrarPorCategoria('Limpeza');

      expect(avaliacoesLimpeza.length, 2);
      expect(avaliacoesLimpeza[0].categoria, 'Limpeza');
      expect(avaliacoesLimpeza[1].categoria, 'Limpeza');
      expect(avaliacoesLimpeza.every((av) => av.categoria == 'Limpeza'), true);
    });

    test('Deve retornar lista vazia ao filtrar categoria inexistente', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      final avaliacoesPintura = visualizar.filtrarPorCategoria('Pintura');

      expect(avaliacoesPintura, isEmpty);
    });

    test('Deve validar responderDuvida retorna false quando não há serviço da categoria', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      final resultado = visualizar.responderDuvida('Jardinagem', 'Resposta teste');

      expect(resultado, false);
    });

    test('Deve validar responderDuvida retorna true quando há serviço da categoria', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      final resultado = visualizar.responderDuvida('Limpeza', 'Resposta teste');

      expect(resultado, true);
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

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [],
      );

      expect(visualizar.id, isA<int>());
      expect(visualizar.prestador, isA<PrestadorAutonomo>());
      expect(visualizar.avaliacoes, isA<List<Avaliacao>>());
    });

    test('Deve manter referência do prestador nas avaliações', () {
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
        titulo: 'Ótimo serviço',
        descricao: 'Muito bom',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final visualizar = VisualizarAvaliacao(
        id: 1,
        prestador: prestador,
        avaliacoes: [avaliacao],
      );

      expect(visualizar.prestador.id, prestador.id);
      expect(visualizar.avaliacoes[0].prestador.id, prestador.id);
      expect(visualizar.avaliacoes[0].prestador.nome, prestador.nome);
    });
  });
}