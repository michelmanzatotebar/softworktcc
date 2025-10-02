import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'notificacao_controller.dart';

class ClienteSolicitacoesAndamentoController {
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

  Future<void> carregarSolicitacoesCliente(String clienteCpfCnpj) async {
    try {
      _setLoading(true);

      await _cancelarListener();

      _solicitacoesSubscription = _ref.child('solicitacoes').onValue.listen(
            (event) {
          try {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> solicitacoesData = event.snapshot.value as Map<dynamic, dynamic>;
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
              print("Solicitações do cliente atualizadas em tempo real: ${solicitacoesDoCliente.length}");
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

      final snapshot = await _ref.child('solicitacoes/$solicitacaoId').get();
      if (!snapshot.exists) {
        throw Exception("Solicitação não encontrada");
      }

      Map<String, dynamic> solicitacao = Map<String, dynamic>.from(snapshot.value as Map);

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': novoStatus,
      });

      if (confirmado) {
        await NotificacaoController.notificarMudancaStatus(
          clienteCpfCnpj: solicitacao['cliente']['cpfCnpj'] ?? '',
          tituloSolicitacao: solicitacao['titulo'] ?? 'Solicitação',
          nomePrestador: solicitacao['prestador']['nome'] ?? 'Prestador',
          tipoStatus: 'finalizada',
          solicitacaoId: solicitacaoId,
        );
      }

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
      case 'pendente':
        return 'Pendente';
      case 'aceita':
        return 'Aceita';
      case 'em andamento':
        return 'Em Andamento';
      case 'recusada':
        return 'Recusada';
      case 'cancelada':
        return 'Cancelada';
      case 'concluída':
        return 'Concluído\npelo prestador';
      case 'finalizado':
        return 'Finalizado';
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

  void dispose() {
    _cancelarListener();
  }
}