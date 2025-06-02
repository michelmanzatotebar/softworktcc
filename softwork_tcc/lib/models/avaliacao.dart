import 'servico.dart';
import 'cliente.dart';
import 'prestador_autonomo.dart';

class Avaliacao {
  int id;
  String titulo;
  String descricao;
  String categoria;
  Servico servico;
  Cliente cliente;
  PrestadorAutonomo prestador;

  Avaliacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.servico,
    required this.cliente,
    required this.prestador,
  });

  Avaliacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        titulo = map['titulo'],
        descricao = map['descricao'],
        categoria = map['categoria'],
        servico = Servico.fromMap(map['servico']),
        cliente = Cliente.fromMap(map['cliente']),
        prestador = PrestadorAutonomo.fromMap(map['prestador']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'servico': servico.toMap(),
      'cliente': cliente.toMap(),
      'prestador': prestador.toMap(),
    };
  }
}