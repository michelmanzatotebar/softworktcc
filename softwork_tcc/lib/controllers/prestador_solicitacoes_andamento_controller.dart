import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'notificacao_controller.dart';

class PrestadorSolicitacoesAndamentoController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  StreamSubscription? _solicitacoesSubscription;

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
// Carrega e escuta mudanças nas solicitações do prestador em tempo real
  Future<void> carregarSolicitacoesPrestador(String prestadorCpfCnpj) async {
    try {
      _setLoading(true);

      await _cancelarListener();

      _solicitacoesSubscription = _ref.child('solicitacoes').onValue.listen(
            (event) {
          try {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> solicitacoesData = event.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> solicitacoesDoPrestador = [];

              solicitacoesData.forEach((key, value) {
                Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
                solicitacao['id'] = key;

                if (solicitacao['prestador'] != null &&
                    solicitacao['prestador']['cpfCnpj'].toString() == prestadorCpfCnpj &&
                    solicitacao['statusSolicitacao'] != 'Pendente') {
                  solicitacoesDoPrestador.add(solicitacao);
                }
              });

              solicitacoesDoPrestador.sort((a, b) {
                DateTime dataA = DateTime.parse(a['dataSolicitacao']);
                DateTime dataB = DateTime.parse(b['dataSolicitacao']);
                return dataB.compareTo(dataA);
              });

              onSolicitacoesChanged?.call(solicitacoesDoPrestador);
              print("Solicitações do prestador atualizadas em tempo real: ${solicitacoesDoPrestador.length}");
            } else {
              onSolicitacoesChanged?.call([]);
              print("Nenhuma solicitação encontrada");
            }

            if (_isLoading) {
              _setLoading(false);
            }
          } catch (e) {
            print("Erro ao processar solicitações em tempo real: $e");
            if (_isLoading) {
              _setLoading(false);
            }
            onError?.call("Erro ao carregar solicitações");
          }
        },
        onError: (error) {
          print("Erro no listener de solicitações: $error");
          if (_isLoading) {
            _setLoading(false);
          }
          onError?.call("Erro ao escutar solicitações");
        },
      );
    } catch (e) {
      print("Erro ao inicializar listener de solicitações: $e");
      _setLoading(false);
      onError?.call("Erro ao carregar solicitações");
    }
  }

  Future<void> _cancelarListener() async {
    if (_solicitacoesSubscription != null) {
      await _solicitacoesSubscription!.cancel();
      _solicitacoesSubscription = null;
    }
  }
// Atualiza status da solicitação e notifica o cliente
  Future<void> atualizarStatusSolicitacao(String solicitacaoId, String novoStatus) async {
    try {
      _setLoading(true);

      final snapshot = await _ref.child('solicitacoes/$solicitacaoId').get();
      if (!snapshot.exists) {
        throw Exception("Solicitação não encontrada");
      }

      Map<String, dynamic> solicitacao = Map<String, dynamic>.from(snapshot.value as Map);

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': novoStatus,
      });

      String tipoStatus = _converterStatusParaTipo(novoStatus);

      await NotificacaoController.notificarMudancaStatus(
        clienteCpfCnpj: solicitacao['cliente']['cpfCnpj'] ?? '',
        tituloSolicitacao: solicitacao['titulo'] ?? 'Solicitação',
        nomePrestador: solicitacao['prestador']['nome'] ?? 'Prestador',
        tipoStatus: tipoStatus,
        solicitacaoId: solicitacaoId,
      );

      print("Status atualizado para: $novoStatus");
    } catch (e) {
      print("Erro ao atualizar status: $e");
      onError?.call("Erro ao atualizar status da solicitação");
    } finally {
      _setLoading(false);
    }
  }

  String _converterStatusParaTipo(String status) {
    switch (status.toLowerCase()) {
      case 'em andamento':
        return 'em_andamento';
      case 'cancelada':
        return 'cancelada';
      case 'concluída':
        return 'concluida';
      default:
        return status.toLowerCase().replaceAll(' ', '_');
    }
  }
// Formata texto do status para exibição
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
// Formata valor para moeda brasileira
  String formatarValor(dynamic valor) {
    if (valor != null) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return 'R\$ 0,00';
  }
// Retorna cor correspondente ao status
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
// Retorna opções de status disponíveis baseado no status atual
  List<String> getOpcoesStatus(String statusAtual) {
    switch (statusAtual.toLowerCase()) {
      case 'aceita':
        return ['Em andamento', 'Cancelada'];
      case 'em andamento':
        return ['Cancelada', 'Concluída'];
      default:
        return [];
    }
  }

  bool podeAlterarStatus(String status) {
    return ['Aceita', 'Em andamento'].contains(status);
  }

  void dispose() {
    _cancelarListener();
  }
}