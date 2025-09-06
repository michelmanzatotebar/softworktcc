import 'package:flutter/material.dart';
import 'solicitacao_controller.dart';

class TelaDetalhesSolicitacaoController {
  final SolicitacaoController _solicitacaoController = SolicitacaoController();

  final TextEditingController tituloEditController = TextEditingController();
  final TextEditingController descricaoEditController = TextEditingController();

  bool editandoTitulo = false;
  bool editandoDescricao = false;
  bool isLoading = false;

  Map<String, dynamic>? dadosSolicitacao;

  VoidCallback? onUpdateUI;
  Function(String, bool)? onShowMessage;
  VoidCallback? onNavigateBack;

  void inicializarDados(Map<String, dynamic> dados, {
    VoidCallback? updateUI,
    Function(String, bool)? messageCallback,
    VoidCallback? navigateBack,
    String? clienteNome,
    String? clienteCpfCnpj,
  }) {
    dadosSolicitacao = dados;
    onUpdateUI = updateUI;
    onShowMessage = messageCallback;
    onNavigateBack = navigateBack;

    this.clienteNome = clienteNome;
    this.clienteCpfCnpj = clienteCpfCnpj;

    tituloEditController.text = titulo ?? '';
    descricaoEditController.text = descricao ?? '';
  }

  String? clienteNome;
  String? clienteCpfCnpj;

  String? get titulo => dadosSolicitacao?['titulo'];
  String? get descricao => dadosSolicitacao?['descricao'];
  Map<String, dynamic>? get servico => dadosSolicitacao?['servico'];
  Map<String, dynamic>? get cliente => dadosSolicitacao?['cliente'];
  Map<String, dynamic>? get prestador => dadosSolicitacao?['prestador'];
  String? get dataSolicitacao => dadosSolicitacao?['dataSolicitacao'];
  String? get statusSolicitacao => dadosSolicitacao?['statusSolicitacao'];

  void editarTitulo() {
    editandoTitulo = true;
    onUpdateUI?.call();
  }

  void salvarTitulo() {
    String titulo = tituloEditController.text.trim();

    if (titulo.length < 3) {
      onShowMessage?.call('Título deve ter pelo menos 3 caracteres', false);
      return;
    }

    if (dadosSolicitacao != null) {
      dadosSolicitacao!['titulo'] = titulo;
    }
    editandoTitulo = false;
    onUpdateUI?.call();
  }

  void cancelarEdicaoTitulo() {
    tituloEditController.text = titulo ?? '';
    editandoTitulo = false;
    onUpdateUI?.call();
  }

  void editarDescricao() {
    editandoDescricao = true;
    onUpdateUI?.call();
  }

  void salvarDescricao() {
    String descricao = descricaoEditController.text.trim();

    if (descricao.length < 10) {
      onShowMessage?.call('Descrição deve ter pelo menos 10 caracteres', false);
      return;
    }

    if (dadosSolicitacao != null) {
      dadosSolicitacao!['descricao'] = descricao;
    }
    editandoDescricao = false;
    onUpdateUI?.call();
  }

  void cancelarEdicaoDescricao() {
    descricaoEditController.text = descricao ?? '';
    editandoDescricao = false;
    onUpdateUI?.call();
  }

  String formatarData(String? dataISO) {
    if (dataISO == null) return 'N/A';
    return _solicitacaoController.formatarData(dataISO);
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

  Future<void> confirmarSolicitacao() async {
    if (dadosSolicitacao == null) return;

    isLoading = true;
    onUpdateUI?.call();

    try {
      final novaSolicitacao = await _solicitacaoController.criarSolicitacao(
        titulo: dadosSolicitacao!['titulo'],
        descricao: dadosSolicitacao!['descricao'],
        categoria: dadosSolicitacao!['servico']['categoria'],
        servico: dadosSolicitacao!['servico'],
        clienteNome: dadosSolicitacao!['cliente']['nome'],
        clienteCpfCnpj: dadosSolicitacao!['cliente']['cpfCnpj'],
        prestadorNome: dadosSolicitacao!['prestador']['nome'],
        prestadorCpfCnpj: dadosSolicitacao!['prestador']['cpfCnpj'],
      );

      print("=== SOLICITAÇÃO SALVA COM SUCESSO ===");
      print("ID: ${novaSolicitacao['id']}");
      print("Título: ${novaSolicitacao['titulo']}");
      print("Status: ${novaSolicitacao['statusSolicitacao']}");
      print("Cliente salvo: nome=${novaSolicitacao['cliente']['nome']}, cpf=${novaSolicitacao['cliente']['cpfCnpj']}");
      print("Prestador salvo: nome=${novaSolicitacao['prestador']['nome']}, cpf=${novaSolicitacao['prestador']['cpfCnpj']}");
      print("Dados completos do prestador estão disponíveis para exibição, mas só nome e CPF foram salvos");
      print("=====================================");

      onShowMessage?.call('Solicitação criada com sucesso!', true);

      await Future.delayed(Duration(seconds: 2));
      onNavigateBack?.call();

    } catch (e) {
      print("Erro ao confirmar solicitação: $e");
      onShowMessage?.call('Erro ao criar solicitação', false);
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }

  void dispose() {
    tituloEditController.dispose();
    descricaoEditController.dispose();
  }
}