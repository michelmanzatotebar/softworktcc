import 'package:flutter/material.dart';

class TelaDetalhesSolicitacaoController {
  // Controladores para edição
  final TextEditingController tituloEditController = TextEditingController();
  final TextEditingController descricaoEditController = TextEditingController();

  // Estados de edição
  bool editandoTitulo = false;
  bool editandoDescricao = false;

  // Dados da solicitação
  Map<String, dynamic>? dadosSolicitacao;

  // Callbacks para atualizar a UI
  VoidCallback? onUpdateUI;

  void inicializarDados(Map<String, dynamic> dados, {VoidCallback? updateUI}) {
    dadosSolicitacao = dados;
    onUpdateUI = updateUI;

    tituloEditController.text = titulo ?? '';
    descricaoEditController.text = descricao ?? '';
  }

  // Getters para acessar os dados
  String? get titulo => dadosSolicitacao?['titulo'];
  String? get descricao => dadosSolicitacao?['descricao'];
  Map<String, dynamic>? get servico => dadosSolicitacao?['servico'];
  Map<String, dynamic>? get cliente => dadosSolicitacao?['cliente'];
  Map<String, dynamic>? get prestador => dadosSolicitacao?['prestador'];
  String? get dataSolicitacao => dadosSolicitacao?['dataSolicitacao'];
  String? get statusSolicitacao => dadosSolicitacao?['statusSolicitacao'];

  // Métodos para controlar edição do título
  void editarTitulo() {
    editandoTitulo = true;
    onUpdateUI?.call();
  }

  void salvarTitulo() {
    if (tituloEditController.text.trim().isNotEmpty) {
      if (dadosSolicitacao != null) {
        dadosSolicitacao!['titulo'] = tituloEditController.text.trim();
      }
      editandoTitulo = false;
      onUpdateUI?.call();
    }
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
    if (descricaoEditController.text.trim().isNotEmpty) {
      if (dadosSolicitacao != null) {
        dadosSolicitacao!['descricao'] = descricaoEditController.text.trim();
      }
      editandoDescricao = false;
      onUpdateUI?.call();
    }
  }

  void cancelarEdicaoDescricao() {
    descricaoEditController.text = descricao ?? '';
    editandoDescricao = false;
    onUpdateUI?.call();
  }

  String formatarData(String? dataISO) {
    if (dataISO == null) return 'N/A';

    try {
      DateTime data = DateTime.parse(dataISO);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
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
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void confirmarSolicitacao() {
    if (dadosSolicitacao != null) {
      print("=== CONFIRMANDO SOLICITAÇÃO ===");
      print("ID: ${dadosSolicitacao!['id']}");
      print("Título: ${dadosSolicitacao!['titulo']}");
      print("Descrição: ${dadosSolicitacao!['descricao']}");
      print("Data Solicitação: ${dadosSolicitacao!['dataSolicitacao']}");
      print("Status: ${dadosSolicitacao!['statusSolicitacao']}");
      print("Serviço: ${dadosSolicitacao!['servico']['nome']}");
      print("Cliente: ${dadosSolicitacao!['cliente']['nome']}");
      print("Prestador: ${dadosSolicitacao!['prestador']['nome']}");
      print("==============================");
    }
  }

  void dispose() {
    tituloEditController.dispose();
    descricaoEditController.dispose();
  }
}