import 'package:flutter/material.dart';
import '../controllers/perfil_prestador_controller.dart';

class TelaPerfilPrestador extends StatefulWidget {
  final String prestadorCpfCnpj;

  const TelaPerfilPrestador({
    Key? key,
    required this.prestadorCpfCnpj,
  }) : super(key: key);

  @override
  _TelaPerfilPrestadorState createState() => _TelaPerfilPrestadorState();
}

class _TelaPerfilPrestadorState extends State<TelaPerfilPrestador> {
  final PerfilPrestadorController _controller = PerfilPrestadorController();
  int _secaoSelecionada = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _carregarDados();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      dataCallback: () {
        setState(() {});
      },
      errorCallback: (String erro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _carregarDados() async {
    await _controller.carregarDadosPrestador(widget.prestadorCpfCnpj);
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
              child: Column(
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
                            'Perfil do Prestador',
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

                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _secaoSelecionada = 0;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _secaoSelecionada == 0 ? Colors.red[600] : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Informações',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _secaoSelecionada == 0 ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _secaoSelecionada = 1;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _secaoSelecionada == 1 ? Colors.red[600] : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Serviços',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _secaoSelecionada == 1 ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _secaoSelecionada = 2;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _secaoSelecionada == 2 ? Colors.red[600] : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Avaliações',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _secaoSelecionada == 2 ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red[600],
                ),
              )
                  : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    if (_secaoSelecionada == 0) ..._buildSecaoInformacoes(),
                    if (_secaoSelecionada == 1) ..._buildSecaoServicos(),
                    if (_secaoSelecionada == 2) ..._buildSecaoAvaliacoes(),

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

  List<Widget> _buildSecaoInformacoes() {
    double mediaAvaliacoes = _controller.getMediaAvaliacoes();
    int notaInteira = mediaAvaliacoes.floor();

    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _controller.getNome(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _controller.getIdade(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 18,
                    color: index < notaInteira ? Colors.amber[600] : Colors.grey[300],
                  );
                }),
                SizedBox(width: 8),
                Text(
                  mediaAvaliacoes.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' (${_controller.getTotalAvaliacoes()} avaliações)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Divider(color: Colors.grey[200]),
            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.grey[600], size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _controller.getEmail(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, color: Colors.grey[600], size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _controller.getTelefone(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _controller.getLogradouro(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      SizedBox(height: 20),

      Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '${_controller.getTotalServicos()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Serviços',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                      SizedBox(width: 4),
                      Text(
                        mediaAvaliacoes.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Média',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '${_controller.getTotalAvaliacoes()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.red[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Avaliações',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      SizedBox(height: 20),

      Text(
        'Sobre mim',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),

      SizedBox(height: 12),

      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _controller.temBiografia() ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _controller.getBiografia(),
          style: TextStyle(
            fontSize: 14,
            color: _controller.temBiografia() ? Colors.grey[700] : Colors.grey[500],
            height: 1.5,
            fontStyle: _controller.temBiografia() ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSecaoServicos() {
    List<Map<String, dynamic>> servicos = _controller.getServicos();

    return [
      Text(
        'Serviços Oferecidos (${servicos.length})',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 12),

      if (servicos.isEmpty)
        Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Não possui serviços',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        )
      else
        ...servicos.map((servico) {
          return _buildServicoCard(
            nome: servico['nome']?.toString() ?? 'Serviço',
            categoria: servico['categoria']?.toString() ?? '',
            descricao: servico['descricao']?.toString() ?? '',
            valor: servico['valor']?.toDouble() ?? 0.0,
          );
        }).toList(),
    ];
  }

  List<Widget> _buildSecaoAvaliacoes() {
    List<Map<String, dynamic>> avaliacoes = _controller.getAvaliacoes();

    return [
      Text(
        'Avaliações Recebidas (${avaliacoes.length})',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 12),

      if (avaliacoes.isEmpty)
        Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Não possui avaliações',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        )
      else
        ...avaliacoes.map((avaliacao) {
          return _buildAvaliacaoCard(
            nomeCliente: avaliacao['cliente']?['nome']?.toString() ?? 'Cliente',
            servico: avaliacao['servico']?['nome']?.toString() ?? 'Serviço',
            nota: avaliacao['nota']?.toDouble() ?? 0.0,
            comentario: avaliacao['descricao']?.toString() ?? '',
          );
        }).toList(),
    ];
  }

  Widget _buildServicoCard({
    required String nome,
    required String categoria,
    required String descricao,
    required double valor,
  }) {
    return Container(
      width: double.infinity,
      height: 150,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    categoria,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      descricao,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _controller.formatarValor(valor),
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvaliacaoCard({
    required String nomeCliente,
    required String servico,
    required double nota,
    required String comentario,
  }) {
    int notaInteira = nota.floor();

    return Container(
      height: 180,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.red[600], size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nomeCliente,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: index < notaInteira ? Colors.amber[600] : Colors.grey[300],
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Serviço: $servico',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.comment, color: Colors.amber[700], size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comentario,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}