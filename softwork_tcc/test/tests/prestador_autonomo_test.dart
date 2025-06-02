import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';
import 'package:softwork_tcc/models/solicitacao.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/cliente.dart';

void main() {
  group('PrestadorAutonomo - Testes Unitários', () {
    test('Deve criar PrestadorAutonomo sem solicitação (0..*)', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      expect(prestador.id, 1);
      expect(prestador.nome, 'Laura Silva');
      expect(prestador.tipoConta, false);
      expect(prestador.solicitacao, isNull);
      expect(prestador.idade, 28);
    });

    test('Deve criar PrestadorAutonomo com solicitação', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      final servico = Servico(
        id: 1,
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Casa',
        prestador: prestador,
      );


      final cliente = Cliente(
        id: 2,
        nome: 'Michel Cliente',
        telefone: 11999888777,
        senha: '654321',
        email: 'michel@email.com',
        cpfCnpj: 98765432100,
        tipoConta: true,
        idade: 30,
        solicitacao: null,
      );


      final solicitacao = Solicitacao(
        id: 1,
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime.now(),
        statusSolicitacao: 'Pendente',
      );


      prestador.solicitacao = solicitacao;


      expect(prestador.solicitacao, isNotNull);
      expect(prestador.solicitacao!.id, 1);
      expect(prestador.solicitacao!.statusSolicitacao, 'Pendente');
    });

    test('Deve serializar PrestadorAutonomo sem solicitação', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      final prestadorMap = prestador.toMap();


      expect(prestadorMap['id'], 1);
      expect(prestadorMap['nome'], 'Laura Silva');
      expect(prestadorMap['solicitacao'], isNull);
      expect(prestadorMap['tipoConta'], false);
    });

    test('Deve deserializar PrestadorAutonomo com solicitacao null', () {

      final prestadorMap = {
        'id': 1,
        'nome': 'Laura Silva',
        'telefone': 11888777666,
        'senha': '123456',
        'email': 'laura@email.com',
        'cpfCnpj': 12345678901,
        'tipoConta': false,
        'idade': 28,
        'solicitacao': null, // Null explícito
      };


      final prestador = PrestadorAutonomo.fromMap(prestadorMap);


      expect(prestador.id, 1);
      expect(prestador.nome, 'Laura Silva');
      expect(prestador.solicitacao, isNull);
      expect(prestador.tipoConta, false);
    });

    test('Deve manter herança de Pessoa', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      expect(prestador.nome, 'Laura Silva');
      expect(prestador.telefone, 11888777666);
      expect(prestador.email, 'laura@email.com');
      expect(prestador.cpfCnpj, 12345678901);
      expect(prestador.tipoConta, false); // false = prestador
    });

    test('Deve validar ciclo serialização/deserialização completo', () {
      // Arrange
      final prestadorOriginal = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      final map = prestadorOriginal.toMap();
      final prestadorReconstruido = PrestadorAutonomo.fromMap(map);


      expect(prestadorReconstruido.id, prestadorOriginal.id);
      expect(prestadorReconstruido.nome, prestadorOriginal.nome);
      expect(prestadorReconstruido.telefone, prestadorOriginal.telefone);
      expect(prestadorReconstruido.email, prestadorOriginal.email);
      expect(prestadorReconstruido.solicitacao, prestadorOriginal.solicitacao);
      expect(prestadorReconstruido.tipoConta, prestadorOriginal.tipoConta);
    });
  });

  group('PrestadorAutonomo - Testes de Negócio', () {
    test('Deve permitir prestador aceitar solicitação', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );

      // Simular que o prestador aceita uma solicitação
      expect(prestador.solicitacao, isNull); // Inicialmente sem solicitação

      // TODO: Implementar método aceitar() se existir
      // prestador.aceitar(solicitacao);
    });

    test('Deve validar que prestador pode ter múltiplos serviços', () {

      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Silva',
        telefone: 11888777666,
        senha: '123456',
        email: 'laura@email.com',
        cpfCnpj: 12345678901,
        tipoConta: false,
        idade: 28,
        solicitacao: null,
      );


      final servicoLimpeza = Servico(
        id: 1,
        nome: 'Limpeza',
        descricao: 'Limpeza residencial',
        valor: 150.0,
        categoria: 'Casa',
        prestador: prestador,
      );

      final servicoJardinagem = Servico(
        id: 2,
        nome: 'Jardinagem',
        descricao: 'Cuidados com jardim',
        valor: 200.0,
        categoria: 'Jardim',
        prestador: prestador,
      );

      // Assert - Ambos serviços devem referenciar o mesmo prestador
      expect(servicoLimpeza.prestador, prestador);
      expect(servicoJardinagem.prestador, prestador);
      expect(servicoLimpeza.prestador.nome, servicoJardinagem.prestador.nome);
    });
  });
}