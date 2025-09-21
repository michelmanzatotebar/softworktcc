import 'package:firebase_database/firebase_database.dart';
import '../controllers/notificacao_controller.dart';

class SolicitacaoController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> criarSolicitacao({
    required String titulo,
    required String descricao,
    required String categoria,
    required Map<String, dynamic> servico,
    required String clienteNome,
    required String clienteCpfCnpj,
    required String prestadorNome,
    required String prestadorCpfCnpj,
  }) async {
    try {
      final String solicitacaoId = _ref.child('solicitacoes').push().key!;

      final Map<String, dynamic> solicitacao = {
        'id': solicitacaoId,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria,
        'servico': servico,
        'cliente': {
          'nome': clienteNome,
          'cpfCnpj': clienteCpfCnpj,
        },
        'prestador': {
          'nome': prestadorNome,
          'cpfCnpj': prestadorCpfCnpj,
        },
        'statusSolicitacao': 'Pendente',
        'dataSolicitacao': DateTime.now().toIso8601String(),
      };

      await _ref.child('solicitacoes/$solicitacaoId').set(solicitacao);

      print("Solicitação criada com sucesso");

      // NOVO: Notificar o prestador sobre a nova solicitação
      await NotificacaoController.notificarNovaSolicitacao(
        prestadorCpfCnpj: prestadorCpfCnpj,
        tituloSolicitacao: titulo,
        nomeCliente: clienteNome,
        nomeServico: servico['nome'] ?? 'Serviço',
      );

      return solicitacao;

    } catch (e) {
      throw Exception("Erro ao criar solicitação: $e");
    }
  }

  Future<List<Map<String, dynamic>>> carregarSolicitacoesPorCliente(String clienteCpfCnpj) async {
    try {
      final snapshot = await _ref.child('solicitacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> solicitacoesData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> solicitacoesDoCliente = [];

        solicitacoesData.forEach((key, value) {
          Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
          solicitacao['id'] = key;

          if (solicitacao['cliente'] != null &&
              solicitacao['cliente']['cpfCnpj'].toString() == clienteCpfCnpj) {
            solicitacoesDoCliente.add(solicitacao);
          }
        });

        solicitacoesDoCliente.sort((a, b) {
          DateTime dataA = DateTime.parse(a['dataSolicitacao']);
          DateTime dataB = DateTime.parse(b['dataSolicitacao']);
          return dataB.compareTo(dataA);
        });

        print("Solicitações do cliente carregadas com sucesso");
        return solicitacoesDoCliente;
      } else {
        print("Nenhuma solicitação encontrada");
        return [];
      }
    } catch (e) {
      print("Erro ao carregar solicitações do cliente");
      throw Exception("Erro ao carregar solicitações: $e");
    }
  }

  Future<List<Map<String, dynamic>>> carregarSolicitacoesPorPrestador(String prestadorCpfCnpj) async {
    try {
      final snapshot = await _ref.child('solicitacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> solicitacoesData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> solicitacoesDoPrestador = [];

        solicitacoesData.forEach((key, value) {
          Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
          solicitacao['id'] = key;

          if (solicitacao['prestador'] != null &&
              solicitacao['prestador']['cpfCnpj'].toString() == prestadorCpfCnpj) {
            solicitacoesDoPrestador.add(solicitacao);
          }
        });

        solicitacoesDoPrestador.sort((a, b) {
          DateTime dataA = DateTime.parse(a['dataSolicitacao']);
          DateTime dataB = DateTime.parse(b['dataSolicitacao']);
          return dataB.compareTo(dataA);
        });

        print("Solicitações do prestador carregadas com sucesso");
        return solicitacoesDoPrestador;
      } else {
        print("Nenhuma solicitação encontrada");
        return [];
      }
    } catch (e) {
      print("Erro ao carregar solicitações do prestador");
      throw Exception("Erro ao carregar solicitações: $e");
    }
  }

  Future<void> atualizarStatusSolicitacao(String solicitacaoId, String novoStatus) async {
    try {
      if (!['Pendente', 'Aceita', 'Em andamento', 'Recusada', 'Cancelada', 'Concluída', 'Finalizado'].contains(novoStatus)) {
        throw Exception("Status inválido. Use: Pendente, Aceita, Em andamento, Recusada, Cancelada, Concluída ou Finalizado");
      }

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': novoStatus,
      });

      print("Status da solicitação atualizado para: $novoStatus");

    } catch (e) {
      throw Exception("Erro ao atualizar status: ${e.toString()}");
    }
  }

  Future<void> excluirSolicitacao(String solicitacaoId) async {
    try {
      await _ref.child('solicitacoes/$solicitacaoId').remove();
      print("Solicitação excluída com sucesso");
    } catch (e) {
      throw Exception("Erro ao excluir solicitação: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>?> buscarSolicitacaoPorId(String solicitacaoId) async {
    try {
      final snapshot = await _ref.child('solicitacoes/$solicitacaoId').get();

      if (snapshot.exists) {
        Map<String, dynamic> solicitacao = Map<String, dynamic>.from(snapshot.value as Map);
        solicitacao['id'] = solicitacaoId;
        return solicitacao;
      }

      return null;
    } catch (e) {
      throw Exception("Erro ao buscar solicitação: ${e.toString()}");
    }
  }

  Future<List<Map<String, dynamic>>> carregarTodasSolicitacoes() async {
    try {
      final snapshot = await _ref.child('solicitacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> solicitacoesData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> todasSolicitacoes = [];

        solicitacoesData.forEach((key, value) {
          Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
          solicitacao['id'] = key;
          todasSolicitacoes.add(solicitacao);
        });

        todasSolicitacoes.sort((a, b) {
          DateTime dataA = DateTime.parse(a['dataSolicitacao']);
          DateTime dataB = DateTime.parse(b['dataSolicitacao']);
          return dataB.compareTo(dataA);
        });

        return todasSolicitacoes;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Erro ao carregar todas as solicitações: ${e.toString()}");
    }
  }

  String formatarData(String dataISO) {
    try {
      DateTime data = DateTime.parse(dataISO);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String formatarDataCompleta(String dataISO) {
    try {
      DateTime data = DateTime.parse(dataISO);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String formatarValor(dynamic valor) {
    if (valor != null) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return 'R\$ 0,00';
  }
}