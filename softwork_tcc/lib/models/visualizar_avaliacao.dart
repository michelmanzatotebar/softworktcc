import 'cliente.dart';
import 'avaliacao.dart';

class VisualizarAvaliacao {
  int id;
  Cliente cliente;
  Avaliacao avaliacao;

  VisualizarAvaliacao({
    required this.id,
    required this.cliente,
    required this.avaliacao,
  });

  VisualizarAvaliacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        cliente = Cliente.fromMap(map['cliente']),
        avaliacao = Avaliacao.fromMap(map['avaliacao']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente.toMap(),
      'avaliacao': avaliacao.toMap(),
    };
  }
}