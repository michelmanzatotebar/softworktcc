import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'solicitacao_controller.dart';

class TelaPrincipalPrestadorController {
  final SolicitacaoController _solicitacaoController = SolicitacaoController();
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  StreamSubscription? _solicitacoesSubscription;

  bool isLoading = false;
  List<Map<String, dynamic>> solicitacoesPendentes = [];

  Function(bool)? onLoadingChanged;
  Function(List<Map<String, dynamic>>)? onSolicitacoesLoaded;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? solicitacoesCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onSolicitacoesLoaded = solicitacoesCallback;
    onError = errorCallback;
  }

  Future<void> carregarSolicitacoesPrestador(String prestadorCpfCnpj) async {
    try {
      isLoading = true;
      onLoadingChanged?.call(true);

      await _cancelarListener();

      _solicitacoesSubscription = _ref.child('solicitacoes').onValue.listen(
            (event) {
          try {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> solicitacoesData = event.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> todasSolicitacoes = [];

              solicitacoesData.forEach((key, value) {
                Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
                solicitacao['id'] = key;

                // Usar a estrutura correta: solicitacao['prestador']['cpfCnpj']
                if (solicitacao['prestador'] != null &&
                    solicitacao['prestador']['cpfCnpj'].toString() == prestadorCpfCnpj) {
                  todasSolicitacoes.add(solicitacao);
                }
              });

              solicitacoesPendentes = todasSolicitacoes.where((solicitacao) =>
              solicitacao['statusSolicitacao'] == 'Pendente'
              ).toList();

              solicitacoesPendentes.sort((a, b) {
                try {
                  DateTime dataA = DateTime.parse(a['dataSolicitacao']);
                  DateTime dataB = DateTime.parse(b['dataSolicitacao']);
                  return dataB.compareTo(dataA);
                } catch (e) {
                  return 0;
                }
              });

              onSolicitacoesLoaded?.call(solicitacoesPendentes);

              print("Solicitações atualizadas em tempo real: ${solicitacoesPendentes.length}");

            } else {
              solicitacoesPendentes = [];
              onSolicitacoesLoaded?.call(solicitacoesPendentes);
              print("Nenhuma solicitação encontrada no banco");
            }

            if (isLoading) {
              isLoading = false;
              onLoadingChanged?.call(false);
            }

          } catch (e) {
            print("Erro ao processar solicitações em tempo real: $e");
            if (isLoading) {
              isLoading = false;
              onLoadingChanged?.call(false);
            }
            onError?.call("Erro ao carregar solicitações");
          }
        },
        onError: (error) {
          print("Erro no listener de solicitações: $error");
          if (isLoading) {
            isLoading = false;
            onLoadingChanged?.call(false);
          }
          onError?.call("Erro ao escutar solicitações");
        },
      );

    } catch (e) {
      print("Erro ao inicializar listener de solicitações: $e");
      isLoading = false;
      onLoadingChanged?.call(false);
      onError?.call("Erro ao carregar solicitações");
    }
  }

  Future<void> _cancelarListener() async {
    if (_solicitacoesSubscription != null) {
      await _solicitacoesSubscription!.cancel();
      _solicitacoesSubscription = null;
    }
  }

  String formatarDataSimples(String dataISO) {
    try {
      DateTime dataUtc = DateTime.parse(dataISO);
      DateTime dataLocal = dataUtc.toLocal();
      return '${dataLocal.day.toString().padLeft(2, '0')}/${dataLocal.month.toString().padLeft(2, '0')}/${dataLocal.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String formatarValorSimples(dynamic valor) {
    if (valor != null) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return 'R\$ 0,00';
  }

  String resumirDescricao(String? descricao, {int maxLength = 50}) {
    if (descricao == null || descricao.isEmpty) return 'Sem descrição';

    if (descricao.length <= maxLength) {
      return descricao;
    }

    return '${descricao.substring(0, maxLength)}...';
  }

  void dispose() {
    _cancelarListener();
  }
}