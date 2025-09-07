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
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Título',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _controller.tituloController,
                      decoration: InputDecoration(
                        hintText: 'Título da solicitação',
                        border: OutlineInputBorder(
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
                          _erroTitulo = null;
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

                    Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller.descricaoController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Descrição da solicitação',
                          border: OutlineInputBorder(
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
                            _erroDescricao = null;
                          });
                        },
                      ),
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

                    SizedBox(height: 20),

                    Container(
                      width: double.infinity,
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

    if (titulo.isEmpty) {
      setStateDialog(() {
        _erroTitulo = 'Título é obrigatório';
      });
      temErro = true;
    } else {
      setStateDialog(() {
        _erroTitulo = null;
      });
    }

    if (descricao.isEmpty) {
      setStateDialog(() {
        _erroDescricao = 'Descrição é obrigatória';
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
                    Text(
                      'Detalhes do Serviço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red[600],
                      ),
                    ),
                    SizedBox(height: 15),

                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.build,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nome do Serviço',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      widget.servico?['nome'] ?? 'Serviço não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Categoria',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      widget.servico?['categoria'] ?? 'Categoria não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Valor',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _controller.formatarValor(widget.servico?['valor']),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Descrição',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      widget.servico?['descricao'] ?? 'Descrição não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Prestador do Serviço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red[600],
                      ),
                    ),
                    SizedBox(height: 15),

                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nome',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _controller.prestadorInfo?['nome'] ?? 'Nome não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Idade',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _controller.prestadorInfo?['idade']?.toString() ?? 'Idade não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Logradouro',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _controller.prestadorInfo?['logradouro'] ?? 'Logradouro não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CEP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _controller.prestadorInfo?['cep'] != null
                                          ? _controller.formatarCep(_controller.prestadorInfo!['cep'].toString())
                                          : 'CEP não disponível',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _solicitarServico,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Criar solicitação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

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