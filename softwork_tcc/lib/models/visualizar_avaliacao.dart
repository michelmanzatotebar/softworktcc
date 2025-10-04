import 'prestador_autonomo.dart';
import 'avaliacao.dart';

class VisualizarAvaliacao {
  int id;
  PrestadorAutonomo prestador;
  List<Avaliacao> avaliacoes;

  VisualizarAvaliacao({
    required this.id,
    required this.prestador,
    required this.avaliacoes,
  });

  VisualizarAvaliacao.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        prestador = PrestadorAutonomo.fromMap(map['prestador']),
        avaliacoes = (map['avaliacoes'] as List)
            .map((item) => Avaliacao.fromMap(item))
            .toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prestador': prestador.toMap(),
      'avaliacoes': avaliacoes.map((a) => a.toMap()).toList(),
    };
  }

  List<Avaliacao> visualizarAvaliacoes(PrestadorAutonomo prestador) {
    return [];
  }

  List<Avaliacao> filtrarPorCategoria(String categoria) {
    return avaliacoes.where((av) => av.categoria == categoria).toList();
  }

  List<Avaliacao> filtrarPorServico(String servico) {
    return [];
  }

  bool responderDuvida(String categoria, String resposta) {
    bool temServico = avaliacoes.any((av) =>
    av.servico?.categoria == categoria &&
        av.servico?.prestador.id == prestador.id
    );

    if (!temServico) {
      return false;
    }

    return true;
  }
}