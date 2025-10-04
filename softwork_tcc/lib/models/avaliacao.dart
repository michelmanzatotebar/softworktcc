import 'servico.dart';
import 'cliente.dart';
import 'prestador_autonomo.dart';

class Avaliacao {
  int id;
  String titulo;
  String descricao;
  String categoria;
  Servico? servico;
  Cliente cliente;
  PrestadorAutonomo prestador;
  double? nota;

  Avaliacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    this.servico,
    required this.cliente,
    required this.prestador,
    this.nota,
  });

  Avaliacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        titulo = map['titulo'],
        descricao = map['descricao'],
        categoria = map['categoria'],
        servico = map['servico'] != null ? Servico.fromMap(map['servico']) : null,
        cliente = Cliente.fromMap(map['cliente']),
        prestador = PrestadorAutonomo.fromMap(map['prestador']),
        nota = map['nota']?.toDouble();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'servico': servico?.toMap(),
      'cliente': cliente.toMap(),
      'prestador': prestador.toMap(),
      'nota': nota,
    };
  }

  void avaliar(Cliente cliente, Servico servico, double nota, String descricao) {
  }

  void criarSugestao(Cliente cliente, String categoria, String titulo, String descricao) {
  }

  void criarDuvida(Cliente cliente, String categoria, String titulo, String descricao) {
  }
}