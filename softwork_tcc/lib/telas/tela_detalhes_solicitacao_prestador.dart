import 'package:flutter/material.dart';
import '../controllers/tela_detalhes_solicitacao_prestador_controller.dart';

class TelaDetalhesSolicitacaoPrestador extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  final String prestadorNome;
  final String prestadorCpfCnpj;

  const TelaDetalhesSolicitacaoPrestador({
    Key? key,
    required this.solicitacao,
    required this.prestadorNome,
    required this.prestadorCpfCnpj,
  }) : super(key: key);

  @override
  _TelaDetalhesSolicitacaoPrestadorState createState() => _TelaDetalhesSolicitacaoPrestadorState();
}

class _TelaDetalhesSolicitacaoPrestadorState extends State<TelaDetalhesSolicitacaoPrestador> {
  final TelaDetalhesSolicitacaoPrestadorController _controller = TelaDetalhesSolicitacaoPrestadorController();

  @override
  void initState() {
    super.initState();
    _inicializarController();
  }

  Future<void> _inicializarController() async {
    await _controller.inicializarDados(
      widget.solicitacao,
      updateUI: () {
        setState(() {});
      },
      messageCallback: (String message, bool isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      },
      navigateBack: () {
        Navigator.pop(context);
      },
    );
  }

  void _aceitarSolicitacao() {
    _controller.aceitarSolicitacao();
  }

  void _recusarSolicitacao() {
    _controller.recusarSolicitacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Detalhes da Solicitação',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ),

            if (_controller.isLoading)
              Container(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações Gerais',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 15),
                          _controller.buildInfoRow('Título', _controller.titulo ?? 'N/A'),
                          _controller.buildInfoRow('Status', _controller.statusSolicitacao ?? 'N/A'),
                          _controller.buildInfoRow('Data', _controller.formatarData(_controller.dataSolicitacao ?? '')),
                          SizedBox(height: 8),
                          Text(
                            'Descrição:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              _controller.descricao ?? 'Sem descrição',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Serviço Solicitado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 15),
                          _controller.buildInfoRow('Nome', _controller.servico?['nome']?.toString() ?? 'N/A'),
                          _controller.buildInfoRow('Categoria', widget.solicitacao['categoria']?.toString() ?? 'N/A'),
                          _controller.buildInfoRow('Valor', _controller.formatarValor(_controller.servico?['valor'])),
                          _controller.buildInfoRow('Descrição', _controller.servico?['descricao']?.toString() ?? 'N/A'),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 15),
                          _controller.buildInfoRow('Nome', _controller.getClienteNome()),
                          _controller.buildInfoRow('Idade', _controller.getClienteIdade()),
                          _controller.buildInfoRow('Email', _controller.getClienteEmail()),
                          _controller.buildInfoRow('Telefone', _controller.getClienteTelefone()),
                          _controller.buildInfoRow('Logradouro', _controller.getClienteLogradouro()),
                          _controller.buildInfoRow('CEP', _controller.getClienteCep()),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    if (!_controller.isLoading) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _recusarSolicitacao,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[100],
                                  foregroundColor: Colors.red[700],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.red[300]!),
                                  ),
                                ),
                                child: Text(
                                  'Recusar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _aceitarSolicitacao,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Aceitar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_controller.isLoading) ...[
                      Container(
                        height: 55,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}