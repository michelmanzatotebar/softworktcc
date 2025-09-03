import 'package:flutter/material.dart';
import '../controllers/tela_cliente_solicitacao_controller.dart';

class TelaClienteSolicitacaoServico extends StatefulWidget {
  final Map<String, dynamic>? servico;

  const TelaClienteSolicitacaoServico({
    Key? key,
    this.servico,
  }) : super(key: key);

  @override
  _TelaClienteSolicitacaoServicoState createState() => _TelaClienteSolicitacaoServicoState();
}

class _TelaClienteSolicitacaoServicoState extends State<TelaClienteSolicitacaoServico> {
  final TelaClienteSolicitacaoController _controller = TelaClienteSolicitacaoController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        'Solicitar Serviço',
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

              SizedBox(height: 50),

              Expanded(
                child: Center(
                  child: Text(
                    'teste deu certo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}