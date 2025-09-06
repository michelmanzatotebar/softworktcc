import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/solicitacao.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/cliente.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';

void main() {
  group('Solicitacao - Testes Unitários', () {
    test('Deve criar Solicitacao com dados corretos', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: '12345678901',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 28,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Limpeza Residencial',
        descricao: 'Limpeza completa da casa',
        valor: 150.0,
        categoria: 'Casa',
        prestador: prestador,
      );

      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: '11999888777',
        senha: '654321',
        email: 'michel@email.com',
        cpfCnpj: '98765432100',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Preciso de limpeza urgente',
        descricao: 'Preciso de uma limpeza completa na minha casa',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 15, 10, 30),
        statusSolicitacao: 'Pendente',
      );

      expect(solicitacao.id, 1);
      expect(solicitacao.titulo, 'Preciso de limpeza urgente');
      expect(solicitacao.statusSolicitacao, 'Pendente');
      expect(solicitacao.cliente, cliente);
      expect(solicitacao.prestador, prestador);
    });

    test('Deve serializar Solicitacao salvando apenas nome e cpfCnpj', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: '12345678901',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 28,
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
        senha: '654321',
        email: 'michel@email.com',
        cpfCnpj: '98765432100',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Serviço de jardinagem',
        descricao: 'Preciso de cuidados com meu jardim',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 15, 14, 20),
        statusSolicitacao: 'Pendente',
      );

      final solicitacaoMap = solicitacao.toMap();

      expect(solicitacaoMap['cliente']['nome'], 'Michel Cliente');
      expect(solicitacaoMap['cliente']['cpfCnpj'], '98765432100');
      expect(solicitacaoMap['prestador']['nome'], 'Laura Silva');
      expect(solicitacaoMap['prestador']['cpfCnpj'], '12345678901');
    });

    test('Deve deserializar Solicitacao corretamente', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: '11888777666',
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: '12345678901',
        tipoConta: false,
        logradouro: 'Av. Principal, 456',
        cep: '87654321',
        idade: 28,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Pintura',
        descricao: 'Pintura de paredes',
        valor: 300.0,
        categoria: 'Reforma',
        prestador: prestador,
      );

      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: '11999888777',
        senha: '654321',
        email: 'michel@email.com',
        cpfCnpj: '98765432100',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
        solicitacao: null,
      );

      final solicitacaoOriginal = Solicitacao(
        id: 1,
        titulo: 'Pintura urgente',
        descricao: 'Preciso pintar quarto',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 15, 16, 45),
        statusSolicitacao: 'Aceita',
      );

      final solicitacaoMap = solicitacaoOriginal.toMap();
      final solicitacaoDeserializada = Solicitacao.fromMap(solicitacaoMap);

      expect(solicitacaoDeserializada.id, solicitacaoOriginal.id);
      expect(solicitacaoDeserializada.titulo, solicitacaoOriginal.titulo);
      expect(solicitacaoDeserializada.statusSolicitacao, solicitacaoOriginal.statusSolicitacao);
      expect(solicitacaoDeserializada.cliente.nome, solicitacaoOriginal.cliente.nome);
      expect(solicitacaoDeserializada.prestador.nome, solicitacaoOriginal.prestador.nome);
    });
  });
}