import 'prestador_autonomo.dart';

class Servico {
  int id;
  String nome;
  String descricao;
  double valor;
  String categoria;
  PrestadorAutonomo prestador;

  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.prestador,
  });

  Servico.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        nome = map['nome'],
        descricao = map['descricao'],
        valor = map['valor'].toDouble(),
        categoria = map['categoria'],
        prestador = PrestadorAutonomo.fromMap(map['prestador']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'valor': valor,
      'categoria': categoria,
      'prestador': prestador.toMap(),
    };
  }
}