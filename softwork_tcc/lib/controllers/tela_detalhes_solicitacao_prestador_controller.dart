import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'solicitacao_controller.dart';

class TelaDetalhesSolicitacaoPrestadorController {
  final SolicitacaoController _solicitacaoController = SolicitacaoController();
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? dadosSolicitacao;
  Map<String, dynamic>? dadosClienteCompletos;
  bool isLoading = false;

  VoidCallback? onUpdateUI;
  Function(String, bool)? onShowMessage;
  VoidCallback? onNavigateBack;

  Future<void> inicializarDados(
      Map<String, dynamic> solicitacao, {
        VoidCallback? updateUI,
        Function(String, bool)? messageCallback,
        VoidCallback? navigateBack,
      }) async {
    dadosSolicitacao = _processarDadosFirebase(solicitacao);
    onUpdateUI = updateUI;
    onShowMessage = messageCallback;
    onNavigateBack = navigateBack;

    await _buscarDadosClienteCompletos();

    print("=== DADOS INICIALIZADOS ===");
    print("Solicitacao completa: $dadosSolicitacao");
    print("Cliente completo: $dadosClienteCompletos");
    print("==========================");
  }

  Map<String, dynamic> _processarDadosFirebase(dynamic dados) {
    if (dados is Map) {
      Map<String, dynamic> resultado = {};
      dados.forEach((key, value) {
        if (value is Map) {
          resultado[key.toString()] = _processarDadosFirebase(value);
        } else {
          resultado[key.toString()] = value;
        }
      });
      return resultado;
    }
    return dados ?? {};
  }

  Future<void> _buscarDadosClienteCompletos() async {
    try {
      isLoading = true;
      onUpdateUI?.call();

      final clienteData = dadosSolicitacao?['cliente'];
      if (clienteData == null) {
        print("Dados do cliente não encontrados na solicitação");
        return;
      }

      final cpfCnpjCliente = clienteData['cpfCnpj']?.toString();
      if (cpfCnpjCliente == null || cpfCnpjCliente.isEmpty) {
        print("CPF/CNPJ do cliente não encontrado");
        return;
      }

      print("Buscando dados do cliente: $cpfCnpjCliente");

      final snapshot = await _ref.child('usuarios/$cpfCnpjCliente').get();

      if (snapshot.exists && snapshot.value != null) {
        dadosClienteCompletos = _processarDadosFirebase(snapshot.value);
        print("Dados do cliente carregados com sucesso");
      } else {
        print("Cliente não encontrado no banco de dados");
        dadosClienteCompletos = null;
      }
    } catch (e) {
      print("Erro ao buscar dados do cliente: $e");
      dadosClienteCompletos = null;
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }

  String? get titulo {
    return dadosSolicitacao?['titulo']?.toString();
  }

  String? get descricao {
    return dadosSolicitacao?['descricao']?.toString();
  }

  Map<String, dynamic>? get servico {
    final servicoData = dadosSolicitacao?['servico'];
    if (servicoData is Map) {
      return _processarDadosFirebase(servicoData);
    }
    return null;
  }

  Map<String, dynamic>? get cliente {
    final clienteData = dadosSolicitacao?['cliente'];
    if (clienteData is Map) {
      return _processarDadosFirebase(clienteData);
    }
    return null;
  }

  Map<String, dynamic>? get prestador {
    final prestadorData = dadosSolicitacao?['prestador'];
    if (prestadorData is Map) {
      return _processarDadosFirebase(prestadorData);
    }
    return null;
  }

  String? get dataSolicitacao {
    return dadosSolicitacao?['dataSolicitacao']?.toString();
  }

  String? get statusSolicitacao {
    return dadosSolicitacao?['statusSolicitacao']?.toString();
  }

  String getClienteNome() {
    return dadosClienteCompletos?['nome']?.toString() ??
        cliente?['nome']?.toString() ?? 'N/A';
  }

  String getClienteIdade() {
    return dadosClienteCompletos?['idade']?.toString() ?? 'N/A';
  }

  String getClienteEmail() {
    return dadosClienteCompletos?['email']?.toString() ?? 'N/A';
  }

  String getClienteTelefone() {
    String telefone = dadosClienteCompletos?['telefone']?.toString() ?? 'N/A';
    if (telefone != 'N/A' && telefone.length >= 10) {
      String numLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
      if (numLimpo.length == 11) {
        return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 7)}-${numLimpo.substring(7)}';
      } else if (numLimpo.length == 10) {
        return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 6)}-${numLimpo.substring(6)}';
      }
    }
    return telefone;
  }

  String getClienteLogradouro() {
    return dadosClienteCompletos?['logradouro']?.toString() ?? 'N/A';
  }

  String formatarData(String? dataISO) {
    if (dataISO == null || dataISO.isEmpty) return 'Data inválida';

    try {
      DateTime data = DateTime.parse(dataISO);

      List<String> meses = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ];

      String dia = data.day.toString().padLeft(2, '0');
      String mes = meses[data.month - 1];
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      return '$dia de $mes de $ano às $hora:$minuto';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';

    try {
      double valorDouble;
      if (valor is String) {
        valorDouble = double.parse(valor);
      } else if (valor is num) {
        valorDouble = valor.toDouble();
      } else {
        return 'R\$ 0,00';
      }

      return 'R\$ ${valorDouble.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> aceitarSolicitacao() async {
    if (dadosSolicitacao == null) return;

    try {
      isLoading = true;
      onUpdateUI?.call();

      final solicitacaoId = dadosSolicitacao!['id']?.toString();
      if (solicitacaoId == null || solicitacaoId.isEmpty) {
        throw Exception("ID da solicitação não encontrado");
      }

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': 'Aceita',
      });

      onShowMessage?.call('Solicitação aceita com sucesso!', true);

      await Future.delayed(Duration(seconds: 1));
      onNavigateBack?.call();

    } catch (e) {
      print("Erro ao aceitar solicitação: $e");
      onShowMessage?.call('Erro ao aceitar solicitação', false);
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }

  Future<void> recusarSolicitacao() async {
    if (dadosSolicitacao == null) return;

    try {
      isLoading = true;
      onUpdateUI?.call();

      final solicitacaoId = dadosSolicitacao!['id']?.toString();
      if (solicitacaoId == null || solicitacaoId.isEmpty) {
        throw Exception("ID da solicitação não encontrado");
      }

      await _ref.child('solicitacoes/$solicitacaoId').update({
        'statusSolicitacao': 'Recusada',
      });

      onShowMessage?.call('Solicitação recusada.', true);

      await Future.delayed(Duration(seconds: 1));
      onNavigateBack?.call();

    } catch (e) {
      print("Erro ao recusar solicitação: $e");
      onShowMessage?.call('Erro ao recusar solicitação', false);
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }
}