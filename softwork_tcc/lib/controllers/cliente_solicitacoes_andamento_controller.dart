import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ClienteSolicitacoesAndamentoController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  Function(bool)? onLoadingChanged;
  Function(List<Map<String, dynamic>>)? onSolicitacoesChanged;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? solicitacoesCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onSolicitacoesChanged = solicitacoesCallback;
    onError = errorCallback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(_isLoading);
  }

  Future<void> carregarSolicitacoesCliente(String clienteCpfCnpj) async {
    _setLoading(true);

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

        onSolicitacoesChanged?.call(solicitacoesDoCliente);
        print("Solicitações do cliente carregadas: ${solicitacoesDoCliente.length}");
      } else {
        onSolicitacoesChanged?.call([]);
        print("Nenhuma solicitação encontrada");
      }
    } catch (e) {
      print("Erro ao carregar solicitações: $e");
      onError?.call("Erro ao carregar solicitações");
      onSolicitacoesChanged?.call([]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelarSolicitacao(String solicitacaoId) async {
    try {
      _setLoading(true);

      await _ref.child('solicitacoes/$solicitacaoId').remove();

      print("Solicitação excluída pelo cliente");
    } catch (e) {
      print("Erro ao cancelar solicitação: $e");
      onError?.call("Erro ao cancelar solicitação");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> definirConclusaoSolicitacao(String solicitacaoId, bool confirmado) async {
    try {
      _setLoading(true);

      String novoStatus = confirmado ? 'Finalizado' : 'Em andamento';

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': novoStatus,
      });

      print("Conclusão definida - Status: $novoStatus");
    } catch (e) {
      print("Erro ao definir conclusão: $e");
      onError?.call("Erro ao definir conclusão da solicitação");
    } finally {
      _setLoading(false);
    }
  }

  String formatarStatus(String status) {
    switch (status.toLowerCase()) {
      case 'concluída':
        return 'Concluído\npelo prestador';
      default:
        return status;
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

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return const Color(0xFFFF9800);
      case 'aceita':
        return const Color(0xFF4CAF50);
      case 'em andamento':
        return const Color(0xFF81C784);
      case 'recusada':
        return const Color(0xFFF44336);
      case 'cancelada':
        return const Color(0xFFF44336);
      case 'concluída':
        return const Color(0xFF2196F3);
      case 'finalizado':
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF757575);
    }
  }

  bool podeCancelar(String status) {
    return status.toLowerCase() == 'pendente';
  }

  bool podeDefinirConclusao(String status) {
    return status.toLowerCase() == 'concluída';
  }
}