import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';

class PrestadorSolicitacoesAndamentoController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<void> carregarSolicitacoesPrestador(String prestadorCpfCnpj) async {
    _setLoading(true);

    try {
      final snapshot = await _ref.child('solicitacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> solicitacoesData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> solicitacoesDoPrestador = [];

        solicitacoesData.forEach((key, value) {
          Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
          solicitacao['id'] = key;

          // MUDANÇA: Agora traz TODAS as solicitações do prestador que NÃO são pendentes
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
        print("Solicitações do prestador carregadas: ${solicitacoesDoPrestador.length}");
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
      case 'recusada':
        return const Color(0xFFF44336);
      case 'concluida':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF757575);
    }
  }
}