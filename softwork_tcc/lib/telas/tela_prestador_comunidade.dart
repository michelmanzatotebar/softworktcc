import 'package:flutter/material.dart';
import '../controllers/prestador_comunidade_controller.dart';

class TelaPrestadorComunidade extends StatefulWidget {
  final String prestadorNome;
  final String prestadorCpfCnpj;

  const TelaPrestadorComunidade({
    Key? key,
    required this.prestadorNome,
    required this.prestadorCpfCnpj,
  }) : super(key: key);

  @override
  _TelaPrestadorComunidadeState createState() => _TelaPrestadorComunidadeState();
}

class _TelaPrestadorComunidadeState extends State<TelaPrestadorComunidade> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PrestadorComunidadeController _controller = PrestadorComunidadeController();

  bool _isLoadingAvaliacoes = false;
  bool _isLoadingDuvidas = false;
  bool _isLoadingSugestoes = false;

  List<Map<String, dynamic>> _avaliacoes = [];
  List<Map<String, dynamic>> _duvidas = [];
  List<Map<String, dynamic>> _sugestoes = [];

  final _respostaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _configurarCallbacks();
    _carregarDados();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      avaliacoesCallback: (List<Map<String, dynamic>> avaliacoes) {
        setState(() {
          _avaliacoes = avaliacoes;
          _isLoadingAvaliacoes = false;
        });
      },
      duvidasCallback: (List<Map<String, dynamic>> duvidas) {
        setState(() {
          _duvidas = duvidas;
          _isLoadingDuvidas = false;
        });
      },
      sugestoesCallback: (List<Map<String, dynamic>> sugestoes) {
        setState(() {
          _sugestoes = sugestoes;
          _isLoadingSugestoes = false;
        });
      },
    );
  }

  void _carregarDados() {
    setState(() {
      _isLoadingAvaliacoes = true;
      _isLoadingDuvidas = true;
      _isLoadingSugestoes = true;
    });

    _controller.buscarAvaliacoesPrestador(widget.prestadorCpfCnpj);
    _controller.buscarDuvidasPorCategorias(widget.prestadorCpfCnpj);
    _controller.buscarSugestoesComunidade();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _respostaController.dispose();
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
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Comunidade',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: [
                  Tab(text: 'Avaliações'),
                  Tab(text: 'Sugestões'),
                  Tab(text: 'Dúvidas'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvaliacoesTab(),
                  _buildSugestoesTab(),
                  _buildDuvidasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvaliacoesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.red[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Visualize as avaliações dos seus serviços!',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text(
            'Avaliações Recebidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          if (_isLoadingAvaliacoes)
            Center(child: CircularProgressIndicator(color: Colors.red[600]))
          else if (_avaliacoes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma avaliação encontrada nos seus serviços',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ..._avaliacoes.map((avaliacao) {
              return _buildAvaliacaoCard(avaliacao);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAvaliacaoCard(Map<String, dynamic> avaliacao) {
    String nomeCliente = avaliacao['cliente']?['nome'] ?? 'Cliente';
    String nomeServico = avaliacao['servico']?['nome'] ?? 'Serviço';
    String categoria = avaliacao['servico']?['categoria'] ?? '';
    double nota = avaliacao['nota']?.toDouble() ?? 0.0;
    String comentario = avaliacao['descricao'] ?? '';
    String tituloSolicitacao = avaliacao['tituloSolicitacao'] ?? '';
    String descricaoSolicitacao = avaliacao['descricaoSolicitacao'] ?? '';

    return Container(
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red[100],
                child: Icon(Icons.person, color: Colors.red[600], size: 20),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeCliente,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < nota ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            nomeServico,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            categoria,
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          if (tituloSolicitacao.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Título: $tituloSolicitacao',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
          if (descricaoSolicitacao.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              descricaoSolicitacao,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (comentario.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Text(
                comentario,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSugestoesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Veja as sugestões da comunidade para melhorar!',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text(
            'Sugestões da Comunidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          if (_isLoadingSugestoes)
            Center(child: CircularProgressIndicator(color: Colors.red[600]))
          else if (_sugestoes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma sugestão encontrada na comunidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ..._sugestoes.map((sugestao) {
              return _buildSugestaoCard(sugestao);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSugestaoCard(Map<String, dynamic> sugestao) {
    String nomeCliente = sugestao['clienteNome'] ?? 'Cliente';
    String titulo = sugestao['titulo'] ?? '';
    String descricao = sugestao['descricao'] ?? '';
    String categoria = sugestao['categoria'] ?? '';

    return Container(
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[600], size: 20),
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
                ),
              ),
              Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text(
            categoria,
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (descricao.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDuvidasTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.orange[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Responda dúvidas das categorias que você atua!',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Text(
            'Dúvidas das Suas Categorias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          if (_isLoadingDuvidas)
            Center(child: CircularProgressIndicator(color: Colors.red[600]))
          else if (_duvidas.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma dúvida encontrada nas suas categorias',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ..._duvidas.map((duvida) {
              return _buildDuvidaCard(duvida);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildDuvidaCard(Map<String, dynamic> duvida) {
    String nomeCliente = duvida['clienteNome'] ?? 'Cliente';
    String titulo = duvida['titulo'] ?? '';
    String descricao = duvida['descricao'] ?? '';
    String categoria = duvida['categoriaServico'] ?? '';
    String status = duvida['status'] ?? 'pendente';
    bool respondida = status == 'respondida';
    String resposta = duvida['resposta'] ?? '';
    String duvidaId = duvida['id'] ?? '';

    return Container(
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange[100],
                child: Icon(Icons.person, color: Colors.orange[600], size: 20),
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
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: respondida ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: respondida ? Colors.green[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Text(
                  respondida ? 'Respondida' : 'Pendente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: respondida ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            categoria,
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (descricao.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
          if (respondida && resposta.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sua Resposta:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _mostrarDialogEditarResposta(duvidaId, titulo, resposta),
                        child: Icon(Icons.edit, color: Colors.blue, size: 18),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmarExcluirResposta(duvidaId),
                        child: Icon(Icons.delete, color: Colors.red, size: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    resposta,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _mostrarDialogResponder(duvidaId, titulo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Responder Dúvida',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarDialogResponder(String duvidaId, String tituloDuvida) {
    _respostaController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Responder Dúvida',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloDuvida,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _respostaController,
                  maxLines: 5,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Digite sua resposta...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.red[600]!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _respostaController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmarResposta(duvidaId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarResposta(String duvidaId) {
    if (_respostaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, digite uma resposta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Envio'),
          content: Text('Deseja realmente enviar esta resposta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _enviarResposta(duvidaId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarResposta(String duvidaId) async {
    try {
      await _controller.responderDuvida(
        duvidaId,
        _respostaController.text.trim(),
        widget.prestadorCpfCnpj,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      _respostaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar resposta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogEditarResposta(String duvidaId, String tituloDuvida, String respostaAtual) {
    _respostaController.text = respostaAtual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Resposta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloDuvida,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _respostaController,
                  maxLines: 5,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Digite sua resposta...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.red[600]!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _respostaController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmarEdicaoResposta(duvidaId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEdicaoResposta(String duvidaId) {
    if (_respostaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, digite uma resposta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Edição'),
          content: Text('Deseja realmente salvar as alterações?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _editarResposta(duvidaId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editarResposta(String duvidaId) async {
    try {
      await _controller.editarRespostaDuvida(
        duvidaId,
        _respostaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta editada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      _respostaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar resposta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarExcluirResposta(String duvidaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir esta resposta? A dúvida voltará ao status pendente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _excluirResposta(duvidaId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _excluirResposta(String duvidaId) async {
    try {
      await _controller.excluirRespostaDuvida(duvidaId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir resposta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}