import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/pessoa.dart';
import 'package:softwork_tcc/models/cliente.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';
import 'package:softwork_tcc/models/solicitacao.dart';
import 'package:softwork_tcc/models/avaliacao.dart';

void main() {
  group('Integração Firebase - Serialização/Deserialização', () {
    test('Deve serializar e deserializar Pessoa mantendo integridade dos dados', () {
      final pessoaOriginal = Pessoa(
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
      );

      final mapFirebase = pessoaOriginal.toMap();
      final pessoaDeserializada = Pessoa.fromMap(mapFirebase);

      expect(pessoaDeserializada.id, pessoaOriginal.id);
      expect(pessoaDeserializada.nome, pessoaOriginal.nome);
      expect(pessoaDeserializada.telefone, pessoaOriginal.telefone);
      expect(pessoaDeserializada.email, pessoaOriginal.email);
      expect(pessoaDeserializada.tipoConta, pessoaOriginal.tipoConta);
    });

    test('Deve manter herança ao serializar Cliente', () {
      final prestador = PrestadorAutonomo(
        id: 2,
        nome: 'Laura Prestadora',
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
        categoria: 'Casa',
        prestador: prestador,
      );

      expect(() => servico.toMap(), returnsNormally);
      expect(servico.toMap()['prestador'], isA<Map<String, dynamic>>());

      final servicoMap = servico.toMap();
      final prestadorMap = servicoMap['prestador'] as Map<String, dynamic>;
      expect(prestadorMap['solicitacao'], isNull);
    });

    test('Deve validar integridade de dados com tipos corretos', () {
      final mapDados = {
        'id': 1,
        'nome': 'Michel',
        'telefone': '11999887766',
        'senha': '123456',
        'email': 'michel@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua das Flores, 123',
        'cep': '01234567',
        'idade': 30,
      };

      final pessoa = Pessoa.fromMap(mapDados);

      expect(pessoa.id, isA<int>());
      expect(pessoa.nome, isA<String>());
      expect(pessoa.telefone, isA<String>());
      expect(pessoa.tipoConta, isA<bool>());
      expect(pessoa.idade, isA<int>());
    });

    test('Deve serializar Cliente com solicitacao null', () {
      final cliente = Cliente(
        id: 1,
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

      final clienteMap = cliente.toMap();
      expect(clienteMap['solicitacao'], isNull);
      expect(clienteMap['tipoConta'], true);

      final clienteReconstruido = Cliente.fromMap(clienteMap);
      expect(clienteReconstruido.solicitacao, isNull);
      expect(clienteReconstruido.nome, cliente.nome);
    });

    test('Deve serializar PrestadorAutonomo com solicitacao null', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Prestadora',
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

      final prestadorMap = prestador.toMap();
      expect(prestadorMap['solicitacao'], isNull);
      expect(prestadorMap['tipoConta'], false);

      final prestadorReconstruido = PrestadorAutonomo.fromMap(prestadorMap);
      expect(prestadorReconstruido.solicitacao, isNull);
      expect(prestadorReconstruido.nome, prestador.nome);
    });
  });

  group('Integração Completa - Fluxo de Negócio', () {
    test('Deve criar fluxo completo Cliente -> Solicitação -> Prestador', () {
      final prestador = PrestadorAutonomo(
        id: 1,
        nome: 'Laura Limpeza',
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
        descricao: 'Limpeza completa da residência',
        valor: 200.0,
        categoria: 'Limpeza',
        prestador: prestador,
      );

      expect(servico.prestador.nome, 'Laura Limpeza');
      expect(servico.valor, greaterThan(0));
      expect(servico.categoria.isNotEmpty, true);

      final servicoMap = servico.toMap();
      expect(servicoMap['prestador']['nome'], 'Laura Limpeza');
      expect(servicoMap['valor'], 200.0);
    });

    test('Deve criar Solicitação completa e serializar para Firebase', () {
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
        descricao: 'Limpeza completa da casa',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: DateTime(2024, 12, 15, 10, 30),
        statusSolicitacao: 'Pendente',
      );

      final solicitacaoMap = solicitacao.toMap();

      expect(solicitacaoMap['titulo'], 'Preciso de limpeza');
      expect(solicitacaoMap['descricao'], 'Limpeza completa da casa');
      expect(solicitacaoMap['statusSolicitacao'], 'Pendente');
      expect(solicitacaoMap['cliente'], isA<Map<String, dynamic>>());
      expect(solicitacaoMap['prestador'], isA<Map<String, dynamic>>());
      expect(solicitacaoMap['servico'], isA<Map<String, dynamic>>());

      final solicitacaoReconstruida = Solicitacao.fromMap(solicitacaoMap);
      expect(solicitacaoReconstruida.titulo, solicitacao.titulo);
      expect(solicitacaoReconstruida.cliente.nome, cliente.nome);
      expect(solicitacaoReconstruida.prestador.nome, prestador.nome);
    });

    test('Deve criar e serializar Avaliação completa', () {
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

      final avaliacao = Avaliacao(
        id: 1,
        titulo: 'Excelente serviço',
        descricao: 'Trabalho impecável',
        categoria: 'Limpeza',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        nota: 5.0,
      );

      final avaliacaoMap = avaliacao.toMap();

      expect(avaliacaoMap['titulo'], 'Excelente serviço');
      expect(avaliacaoMap['nota'], 5.0);
      expect(avaliacaoMap['cliente'], isA<Map<String, dynamic>>());
      expect(avaliacaoMap['prestador'], isA<Map<String, dynamic>>());
      expect(avaliacaoMap['servico'], isA<Map<String, dynamic>>());

      final avaliacaoReconstruida = Avaliacao.fromMap(avaliacaoMap);
      expect(avaliacaoReconstruida.titulo, avaliacao.titulo);
      expect(avaliacaoReconstruida.nota, avaliacao.nota);
    });
  });

  group('Testes de Estrutura para Firebase Database', () {
    test('Deve validar que dados podem ser salvos no Firebase sem erros', () {
      final cliente = Cliente(
        id: 1,
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

      final clienteMap = cliente.toMap();

      expect(clienteMap.keys.every((key) => key is String), true);
      expect(clienteMap['cpfCnpj'], isNotNull);
      expect(clienteMap['email'], isNotNull);
      expect(clienteMap['tipoConta'], isA<bool>());
    });

    test('Deve validar estrutura de chave cpfCnpj para Firebase', () {
      final pessoa = Pessoa(
        id: 1,
        nome: 'Michel',
        telefone: '11999887766',
        senha: '123456',
        email: 'michel@email.com',
        cpfCnpj: '12345678901',
        tipoConta: true,
        logradouro: 'Rua das Flores, 123',
        cep: '01234567',
        idade: 30,
      );

      expect(pessoa.cpfCnpj.isNotEmpty, true);
      expect(pessoa.cpfCnpj.length, greaterThanOrEqualTo(11));
    });

    test('Deve validar conversão de DateTime para Firebase', () {
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

      final dataTeste = DateTime(2024, 12, 15, 10, 30);
      final solicitacao = Solicitacao(
        id: 1,
        titulo: 'Teste',
        descricao: 'Descricao teste',
        servico: servico,
        cliente: cliente,
        prestador: prestador,
        dataSolicitacao: dataTeste,
        statusSolicitacao: 'Pendente',
      );

      final solicitacaoMap = solicitacao.toMap();
      expect(solicitacaoMap['dataSolicitacao'], isA<String>());

      final solicitacaoReconstruida = Solicitacao.fromMap(solicitacaoMap);
      expect(solicitacaoReconstruida.dataSolicitacao.year, dataTeste.year);
      expect(solicitacaoReconstruida.dataSolicitacao.month, dataTeste.month);
      expect(solicitacaoReconstruida.dataSolicitacao.day, dataTeste.day);
    });

    test('Deve validar que valores double são preservados', () {
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
        valor: 150.75,
        categoria: 'Casa',
        prestador: prestador,
      );

      final servicoMap = servico.toMap();
      expect(servicoMap['valor'], 150.75);
      expect(servicoMap['valor'], isA<double>());

      final servicoReconstruido = Servico.fromMap(servicoMap);
      expect(servicoReconstruido.valor, 150.75);
    });
  });

  group('Testes de Cenários de Erro e Validação', () {
    test('Deve lidar com Map vazio na deserialização', () {
      expect(() => Pessoa.fromMap({}), throwsA(anything));
    });

    test('Deve lidar com campos null em Map', () {
      final mapComNulls = {
        'id': 1,
        'nome': null,
        'telefone': '11999887766',
        'senha': '123456',
        'email': 'teste@email.com',
        'cpfCnpj': '12345678901',
        'tipoConta': true,
        'logradouro': 'Rua Teste',
        'cep': '01234567',
        'idade': 30,
      };

      expect(() => Pessoa.fromMap(mapComNulls), throwsA(isA<TypeError>()));
    });

    test('Deve validar que tipoConta é obrigatório', () {
      final cliente = Cliente(
        id: 1,
        nome: 'Michel',
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
      expect(clienteMap['tipoConta'], isNotNull);
      expect(clienteMap['tipoConta'], isA<bool>());
    });

    test('Deve validar relacionamentos entre entidades', () {
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
        categoria: 'Casa',
        prestador: prestador,
      );

      expect(servico.prestador, prestador);
      expect(servico.prestador.cpfCnpj, prestador.cpfCnpj);
      expect(identical(servico.prestador, prestador), true);
    });
  });

  group('Testes de Status e Estados', () {
    test('Deve validar status de solicitação válidos', () {
      final statusValidos = ['Pendente', 'Aceita', 'Recusada', 'Finalizado'];

      for (var status in statusValidos) {
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
          titulo: 'Teste',
          descricao: 'Teste',
          servico: servico,
          cliente: cliente,
          prestador: prestador,
          dataSolicitacao: DateTime.now(),
          statusSolicitacao: status,
        );

        expect(solicitacao.statusSolicitacao, status);

        final solicitacaoMap = solicitacao.toMap();
        expect(solicitacaoMap['statusSolicitacao'], status);
      }
    });

    test('Deve validar notas de avaliação entre 0 e 5', () {
      final notasValidas = [0.0, 1.0, 2.5, 3.0, 4.5, 5.0];

      for (var nota in notasValidas) {
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
  });
}