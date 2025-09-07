import 'package:flutter/material.dart';
import '../controllers/tela_detalhes_solicitacao_controller.dart';
import 'tela_principal_cliente.dart';

class TelaDetalhesSolicitacao extends StatefulWidget {
  final Map<String, dynamic> dadosSolicitacao;

  const TelaDetalhesSolicitacao({Key? key, required this.dadosSolicitacao}) : super(key: key);

  @override
  _TelaDetalhesSolicitacaoState createState() => _TelaDetalhesSolicitacaoState();
}

class _TelaDetalhesSolicitacaoState extends State<TelaDetalhesSolicitacao> {
  final TelaDetalhesSolicitacaoController _controller = TelaDetalhesSolicitacaoController();

  @override
  void initState() {
    super.initState();
    _inicializarController();
  }

  Future<void> _inicializarController() async {
    await _controller.inicializarDados(
      widget.dadosSolicitacao,
      updateUI: () {
        setState(() {});
      },
      messageCallback: (String message, bool isSuccess) {
        _mostrarAlerta(message, isSuccess);
      },
      navigateBack: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TelaPrincipalCliente(
            nomeUsuario: _controller.clienteNome ?? 'Cliente',
            cpfCnpj: _controller.clienteCpfCnpj ?? '',
          )),
              (Route<dynamic> route) => false,
        );
      },
      clienteNome: widget.dadosSolicitacao['cliente']?['nome']?.toString(),
      clienteCpfCnpj: widget.dadosSolicitacao['cliente']?['cpfCnpj']?.toString(),
    );
  }

  void _cancelarSolicitacao() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _mostrarAlerta(String mensagem, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(isSuccess ? 'Sucesso!' : 'Erro!'),
            ],
          ),
          content: Text(mensagem),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
                        'Revisar Solicitação',
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
                            'Informações da Solicitação',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Título:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (!_controller.editandoTitulo)
                                GestureDetector(
                                  onTap: _controller.iniciarEdicaoTitulo,
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),

                          if (_controller.editandoTitulo) ...[
                            TextField(
                              controller: _controller.tituloEditController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _controller.salvarTitulo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Text('Salvar'),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _controller.cancelarEdicaoTitulo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Text('Cancelar'),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                _controller.titulo ?? 'Sem título',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Descrição:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (!_controller.editandoDescricao)
                                GestureDetector(
                                  onTap: _controller.iniciarEdicaoDescricao,
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),

                          if (_controller.editandoDescricao) ...[
                            TextField(
                              controller: _controller.descricaoEditController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _controller.salvarDescricao,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Text('Salvar'),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _controller.cancelarEdicaoDescricao,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Text('Cancelar'),
                                ),
                              ],
                            ),
                          ] else ...[
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
                          _controller.buildInfoRow('Categoria', _controller.categoria ?? 'N/A'),
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
                          Row(
                            children: [
                              Text(
                                'Prestador',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                              Spacer(),
                              if (_controller.isLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),

                          if (!_controller.isLoading) ...[
                            _controller.buildInfoRow('Nome', _controller.getPrestadorNome()),
                            _controller.buildInfoRow('Idade', _controller.getPrestadorIdade()),
                            _controller.buildInfoRow('Email', _controller.getPrestadorEmail()),
                            _controller.buildInfoRow('Telefone', _controller.getPrestadorTelefone()),
                            _controller.buildInfoRow('Logradouro', _controller.getPrestadorLogradouro()),
                            _controller.buildInfoRow('CEP', _controller.getPrestadorCep()),
                          ] else ...[
                            Container(
                              height: 150,
                              child: Center(
                                child: Text(
                                  'Carregando dados do prestador...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                onPressed: _cancelarSolicitacao,
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
                                  'Cancelar',
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
                                onPressed: _controller.confirmarSolicitacao,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Confirmar',
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