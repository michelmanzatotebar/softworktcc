import 'servico.dart';
import 'cliente.dart';
import 'prestador_autonomo.dart';

class Solicitacao {
  int id;
  String titulo;
  String descricao;
  Servico servico;
  Cliente cliente;
  PrestadorAutonomo prestador;
  DateTime dataSolicitacao;
  String statusSolicitacao;

  Solicitacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.servico,
    required this.cliente,
    required this.prestador,
    required this.dataSolicitacao,
    required this.statusSolicitacao,
  });

  Solicitacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        titulo = map['titulo'],
        descricao = map['descricao'],
        servico = Servico.fromMap(map['servico']),
        cliente = Cliente.fromMap(map['cliente']),
        prestador = PrestadorAutonomo.fromMap(map['prestador']),
        dataSolicitacao = DateTime.parse(map['dataSolicitacao']),
        statusSolicitacao = map['statusSolicitacao'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'servico': servico.toMap(),
      'cliente': cliente.toMap(),
      'prestador': prestador.toMap(),
      'dataSolicitacao': dataSolicitacao.toIso8601String(),
      'statusSolicitacao': statusSolicitacao,
    };
  }
}