import 'package:flutter/material.dart';
import 'solicitacao_controller.dart';

class TelaPrincipalPrestadorController {
  final SolicitacaoController _solicitacaoController = SolicitacaoController();

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

      List<Map<String, dynamic>> todasSolicitacoes = await _solicitacaoController.carregarSolicitacoesPorPrestador(prestadorCpfCnpj);

      solicitacoesPendentes = todasSolicitacoes.where((solicitacao) =>
      solicitacao['statusSolicitacao'] == 'Pendente'
      ).toList();

      onSolicitacoesLoaded?.call(solicitacoesPendentes);

    } catch (e) {
      print("Erro ao carregar solicitações do prestador: $e");
      onError?.call("Erro ao carregar solicitações");
    } finally {
      isLoading = false;
      onLoadingChanged?.call(false);
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
}