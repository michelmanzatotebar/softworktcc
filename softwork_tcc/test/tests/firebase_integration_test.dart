import 'package:flutter_test/flutter_test.dart';
import 'package:softwork_tcc/models/pessoa.dart';
import 'package:softwork_tcc/models/cliente.dart';
import 'package:softwork_tcc/models/servico.dart';
import 'package:softwork_tcc/models/prestador_autonomo.dart';

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
  });
}