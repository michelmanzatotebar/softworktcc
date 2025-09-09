import 'package:flutter/material.dart';
import '../controllers/tela_cliente_solicitacao_controller.dart';

class TelaClienteSolicitacaoServico extends StatefulWidget {
  final Map<String, dynamic>? servico;
  final String clienteNome;
  final String clienteCpfCnpj;

  const TelaClienteSolicitacaoServico({
    Key? key,
    this.servico,
    required this.clienteNome,
    required this.clienteCpfCnpj,
  }) : super(key: key);

  @override
  _TelaClienteSolicitacaoServicoState createState() => _TelaClienteSolicitacaoServicoState();
}

class _TelaClienteSolicitacaoServicoState extends State<TelaClienteSolicitacaoServico> {
  final TelaClienteSolicitacaoController _controller = TelaClienteSolicitacaoController();
  String? _erroTitulo;
  String? _erroDescricao;

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _controller.configurarDadosCliente(
        nome: widget.clienteNome,
        cpfCnpj: widget.clienteCpfCnpj,
      );

      _controller.carregarInformacoesPrestador(
        widget.servico!,
        onComplete: () {
          if (mounted) setState(() {});
        },
      );
    }
  }

  void _solicitarServico() {
    _controller.servicoAtual = widget.servico;
    _mostrarModalSolicitacao();
  }

  void _mostrarModalSolicitacao() {
    _erroTitulo = null;
    _erroDescricao = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Nova Solicitação',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _controller.limparCampos();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo do Título com validação
                            TextFormField(
                              controller: _controller.tituloController,
                              maxLength: 50,
                              decoration: InputDecoration(
                                labelText: 'Título da solicitação',
                                hintText: 'Ex: Limpeza urgente da casa',
                                helperText: 'Mínimo 3 caracteres',
                                helperStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroTitulo != null ? Colors.red : Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroTitulo != null ? Colors.red : Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroTitulo != null ? Colors.red : Colors.red[600]!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              onChanged: (value) {
                                setStateDialog(() {
                                  if (value.trim().isEmpty) {
                                    _erroTitulo = 'Título é obrigatório';
                                  } else if (value.trim().length < 3) {
                                    _erroTitulo = 'Título deve ter pelo menos 3 caracteres';
                                  } else {
                                    _erroTitulo = null;
                                  }
                                });
                              },
                            ),
                            if (_erroTitulo != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  _erroTitulo!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            SizedBox(height: 15),

                            // Campo da Descrição com validação
                            TextFormField(
                              controller: _controller.descricaoController,
                              maxLines: 4,
                              maxLength: 200,
                              decoration: InputDecoration(
                                labelText: 'Descrição detalhada',
                                hintText: 'Descreva o que você precisa...',
                                helperText: 'Mínimo 10 caracteres',
                                helperStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroDescricao != null ? Colors.red : Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroDescricao != null ? Colors.red : Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _erroDescricao != null ? Colors.red : Colors.red[600]!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              onChanged: (value) {
                                setStateDialog(() {
                                  if (value.trim().isEmpty) {
                                    _erroDescricao = 'Descrição é obrigatória';
                                  } else if (value.trim().length < 10) {
                                    _erroDescricao = 'Descrição deve ter pelo menos 10 caracteres';
                                  } else {
                                    _erroDescricao = null;
                                  }
                                });
                              },
                            ),
                            if (_erroDescricao != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  _erroDescricao!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            child: OutlinedButton(
                              onPressed: () {
                                _controller.limparCampos();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Container(
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () => _avancarSolicitacao(setStateDialog),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Avançar',
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _avancarSolicitacao(StateSetter setStateDialog) {
    String titulo = _controller.tituloController.text.trim();
    String descricao = _controller.descricaoController.text.trim();

    bool temErro = false;

    // Validação do título
    if (titulo.isEmpty) {
      setStateDialog(() {
        _erroTitulo = 'Título é obrigatório';
      });
      temErro = true;
    } else if (titulo.length < 3) {
      setStateDialog(() {
        _erroTitulo = 'Título deve ter pelo menos 3 caracteres';
      });
      temErro = true;
    } else {
      setStateDialog(() {
        _erroTitulo = null;
      });
    }

    // Validação da descrição
    if (descricao.isEmpty) {
      setStateDialog(() {
        _erroDescricao = 'Descrição é obrigatória';
      });
      temErro = true;
    } else if (descricao.length < 10) {
      setStateDialog(() {
        _erroDescricao = 'Descrição deve ter pelo menos 10 caracteres';
      });
      temErro = true;
    } else {
      setStateDialog(() {
        _erroDescricao = null;
      });
    }

    if (!temErro) {
      Navigator.pop(context);
      _controller.revisarSolicitacao(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
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
            ),

            Expanded(
              child: _controller.isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
                  : SingleChildScrollView(
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
                            'Informações do Serviço',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 15),

                          _buildInfoRow('Nome', widget.servico?['nome'] ?? 'N/A'),
                          _buildInfoRow('Descrição', widget.servico?['descricao'] ?? 'N/A'),
                          _buildInfoRow('Categoria', widget.servico?['categoria'] ?? 'N/A'),
                          _buildInfoRow('Valor', _controller.formatarValor(widget.servico?['valor'])),
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
                                'Informações do Prestador',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
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
                            _buildInfoRow('Nome', _controller.prestadorInfo?['nome'] ?? 'N/A'),
                            _buildInfoRow('Idade', _controller.prestadorInfo?['idade']?.toString() ?? 'N/A'),
                            _buildInfoRow('Email', _controller.prestadorInfo?['email'] ?? 'N/A'),
                            _buildInfoRow('Telefone', _controller.formatarTelefone(_controller.prestadorInfo?['telefone'] ?? '')),
                            _buildInfoRow('Logradouro', _controller.prestadorInfo?['logradouro'] ?? 'N/A'),
                            _buildInfoRow('CEP', _controller.formatarCep(_controller.prestadorInfo?['cep'] ?? '')),
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
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _solicitarServico,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Solicitar Serviço',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}