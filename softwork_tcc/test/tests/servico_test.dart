import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';

void main() {
  group('Servico - Testes Unitários', () {
    test('Deve criar Serviço com valor correto', () {
      // Arrange
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura',
        telefone: 11888777666,
        senha: '123',
        email: 'laura@email.com',
        cpfCnpj: 98765432100,
        tipoConta: false,
        idade: 35,
        solicitacao: null,
      );

      // Act
      final servico = Servico(
        id: 1,
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.50,
        categoria: 'Casa',
        prestador: prestador,
      );

      // Assert
      expect(servico.valor, 150.50);
      expect(servico.nome, 'Limpeza');
      expect(servico.prestador, prestador);
      expect(servico.prestador.solicitacao, isNull);
    });

    test('Deve validar categoria do serviço', () {
      // Arrange
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura',
        telefone: 11888777666,
        senha: '123',
        email: 'laura@email.com',
        cpfCnpj: 98765432100,
        tipoConta: false,
        idade: 35,
        solicitacao: null,
      );

      final servico = Servico(
        id: 1,
        nome: 'Jardinagem',
        descricao: 'Cuidados com jardim',
        valor: 200.0,
        categoria: 'Jardinagem',
        prestador: prestador,
      );

      // Assert
      expect(servico.categoria, 'Jardinagem');
      expect(servico.categoria.isNotEmpty, true);
      expect(servico.prestador.solicitacao, isNull);
    });

    test('Deve serializar e deserializar Serviço corretamente', () {
      // Arrange
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura',
        telefone: 11888777666,
        senha: '123',
        email: 'laura@email.com',
        cpfCnpj: 98765432100,
        tipoConta: false,
        idade: 35,

      );

      final servicoOriginal = Servico(
        id: 1,
        nome: 'Jardinagem',
        descricao: 'Cuidados com jardim',
        valor: 200.0,
        categoria: 'Jardinagem',
        prestador: prestador,
      );

      // Act - Serializar
      final servicoMap = servicoOriginal.toMap();

      // Act - Deserializar
      final servicoDeserializado = Servico.fromMap(servicoMap);


      expect(servicoDeserializado.id, servicoOriginal.id);
      expect(servicoDeserializado.nome, servicoOriginal.nome);
      expect(servicoDeserializado.valor, servicoOriginal.valor);
      expect(servicoDeserializado.prestador.nome, servicoOriginal.prestador.nome);
      expect(servicoDeserializado.prestador.solicitacao, isNull);
    });
  });
}