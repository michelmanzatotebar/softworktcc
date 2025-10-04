import 'package:flutter/material.dart';
import '../controllers/cliente_comunidade_controller.dart';

class TelaClienteComunidade extends StatefulWidget {
  final String clienteNome;
  final String clienteCpfCnpj;

  const TelaClienteComunidade({
    Key? key,
    required this.clienteNome,
    required this.clienteCpfCnpj,
  }) : super(key: key);

  @override
  _TelaClienteComunidadeState createState() => _TelaClienteComunidadeState();
}

class _TelaClienteComunidadeState extends State<TelaClienteComunidade> with SingleTickerProviderStateMixin {
  final ClienteComunidadeController _controller = ClienteComunidadeController();
  late TabController _tabController;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _categoriaSelecionada;
  double _notaSelecionada = 5.0;

  int _opcaoAvaliarSelecionada = 0;
  int _opcaoSugestoesSelecionada = 0;
  int _opcaoDuvidasSelecionada = 0;

  bool _isLoading = false;
  List<Map<String, dynamic>> _solicitacoesFinalizadas = [];
  List<Map<String, dynamic>> _minhasAvaliacoes = [];
  List<Map<String, dynamic>> _avaliacoesComunidade = [];
  List<String> _solicitacoesAvaliadas = [];

  final List<String> _categorias = [
    'Casa e Manutenção',
    'Limpeza e Organização',
    'Cuidados Pessoais',
    'Pet Services',
    'Tecnologia e Digital',
    'Beleza e Estética',
    'Transporte e Entrega',
    'Alimentação e Gastronomia',
    'Eventos e Entretenimento',
    'Educação e Ensino',
    'Consultoria e Assessoria',
    'Jardim e Paisagismo',
    'Saúde e Bem-estar',
    'Arte e Criação',
    'Serviços Automotivos',
    'Serviços Administrativos',
    'Serviços de Emergência',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _configurarCallbacks();
    _carregarDados();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool loading) {
        setState(() {
          _isLoading = loading;
        });
      },
      solicitacoesFinalizadasCallback: (List<Map<String, dynamic>> solicitacoes) {
        setState(() {
          _solicitacoesFinalizadas = solicitacoes;
        });
      },
      minhasAvaliacoesCallback: (List<Map<String, dynamic>> avaliacoes) {
        setState(() {
          _minhasAvaliacoes = avaliacoes;
        });
      },
      avaliacoesComunidadeCallback: (List<Map<String, dynamic>> avaliacoes) {
        setState(() {
          _avaliacoesComunidade = avaliacoes;
        });
      },
      solicitacoesAvaliadasCallback: (List<String> solicitacoesAvaliadas) {
        setState(() {
          _solicitacoesAvaliadas = solicitacoesAvaliadas;
        });
      },
      messageCallback: (String message, bool isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }

  void _carregarDados() {
    _controller.carregarSolicitacoesFinalizadas(widget.clienteCpfCnpj);
    _controller.carregarMinhasAvaliacoes(widget.clienteCpfCnpj);
    _controller.carregarAvaliacoesComunidade();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
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
                  Tab(text: 'Avaliar'),
                  Tab(text: 'Sugestões'),
                  Tab(text: 'Dúvidas'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvaliarTab(),
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

  Widget _buildAvaliarTab() {
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
                    'Avalie os serviços finalizados e ajude outros clientes!',
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

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _opcaoAvaliarSelecionada = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoAvaliarSelecionada == 0 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Minhas Solicitações',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoAvaliarSelecionada == 0 ? Colors.white : Colors.grey[600],
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
                        _opcaoAvaliarSelecionada = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoAvaliarSelecionada == 1 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Minhas Avaliações',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoAvaliarSelecionada == 1 ? Colors.white : Colors.grey[600],
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
                        _opcaoAvaliarSelecionada = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoAvaliarSelecionada == 2 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ver Avaliações',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoAvaliarSelecionada == 2 ? Colors.white : Colors.grey[600],
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
          SizedBox(height: 20),

          if (_opcaoAvaliarSelecionada == 0) ...[
            Text(
              'Serviços Finalizados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Colors.red[600]))
            else if (_solicitacoesFinalizadas.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Nenhuma solicitação finalizada encontrada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ..._solicitacoesFinalizadas.map((solicitacao) {
                return _buildServicoFinalizadoCard(solicitacao);
              }).toList(),
          ] else if (_opcaoAvaliarSelecionada == 1) ...[
            Text(
              'Minhas Avaliações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Colors.red[600]))
            else if (_minhasAvaliacoes.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Nenhuma avaliação encontrada, faça avaliações de suas solicitações',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ..._minhasAvaliacoes.map((avaliacao) {
                return _buildAvaliacaoCard(avaliacao);
              }).toList(),
          ] else ...[
            Text(
              'Avaliações da Comunidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Colors.red[600]))
            else if (_avaliacoesComunidade.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Nenhuma avaliação encontrada na comunidade',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ..._avaliacoesComunidade.map((avaliacao) {
                return _buildAvaliacaoCard(avaliacao);
              }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildServicoFinalizadoCard(Map<String, dynamic> solicitacao) {
    String nomeServico = solicitacao['servico']?['nome'] ?? 'Serviço';
    String nomePrestador = solicitacao['prestador']?['nome'] ?? 'Prestador';
    String categoria = solicitacao['servico']?['categoria'] ?? '';
    double valor = solicitacao['servico']?['valor']?.toDouble() ?? 0.0;
    String valorFormatado = 'R\$ ${valor.toStringAsFixed(2)}';
    String titulo = solicitacao['titulo'] ?? '';
    String descricao = solicitacao['descricao'] ?? '';
    String solicitacaoId = solicitacao['id']?.toString() ?? '';

    bool jaAvaliado = _solicitacoesAvaliadas.contains(solicitacaoId);

    print('Verificando solicitação ID: $solicitacaoId');
    print('Lista de avaliadas: $_solicitacoesAvaliadas');
    print('Já avaliado: $jaAvaliado');

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeServico,
                      style: TextStyle(
                        fontSize: 16,
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: jaAvaliado ? Colors.green[50] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jaAvaliado ? 'Avaliado' : 'Finalizado',
                  style: TextStyle(
                    color: jaAvaliado ? Colors.green[700] : Colors.purple[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (titulo.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              'Título: $titulo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
          if (descricao.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 8),
          Text(
            'Prestador: $nomePrestador',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Spacer(),
              Text(
                valorFormatado,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: jaAvaliado ? null : () => _mostrarDialogAvaliar(solicitacao),
              style: ElevatedButton.styleFrom(
                backgroundColor: jaAvaliado ? Colors.grey[400] : Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (jaAvaliado) ...[
                    Icon(Icons.check_circle, size: 18),
                    SizedBox(width: 8),
                  ],
                  Text(
                    jaAvaliado ? 'Serviço Avaliado' : 'Avaliar Serviço',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvaliacaoCard(Map<String, dynamic> avaliacao) {
    String nomeCliente = avaliacao['cliente']?['nome'] ?? 'Cliente';
    String nomeServico = avaliacao['servico']?['nome'] ?? 'Serviço';
    String nomePrestador = avaliacao['prestador']?['nome'] ?? 'Prestador';
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
          SizedBox(height: 4),
          Text(
            'Prestador: $nomePrestador',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          if (comentario.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarDialogAvaliar(Map<String, dynamic> solicitacao) {
    String nomeServico = solicitacao['servico']?['nome'] ?? 'Serviço';
    String nomePrestador = solicitacao['prestador']?['nome'] ?? 'Prestador';

    setState(() {
      _notaSelecionada = 5.0;
      _descricaoController.clear();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Avaliar Serviço',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeServico,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Prestador: $nomePrestador',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sua Nota',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              _notaSelecionada = (index + 1).toDouble();
                            });
                          },
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color: index < _notaSelecionada
                                ? Colors.amber
                                : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _descricaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escreva sua avaliação...',
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
                    _descricaoController.clear();
                    _notaSelecionada = 5.0;
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _controller.salvarAvaliacao(
                      solicitacao: solicitacao,
                      nota: _notaSelecionada,
                      descricao: _descricaoController.text,
                    );
                    _descricaoController.clear();
                    _notaSelecionada = 5.0;
                  },
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
      },
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
                    'Compartilhe suas ideias para melhorar os serviços!',
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

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _opcaoSugestoesSelecionada = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoSugestoesSelecionada == 0 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Criar Sugestão',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoSugestoesSelecionada == 0 ? Colors.white : Colors.grey[600],
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
                        _opcaoSugestoesSelecionada = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoSugestoesSelecionada == 1 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Minhas Sugestões',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoSugestoesSelecionada == 1 ? Colors.white : Colors.grey[600],
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
                        _opcaoSugestoesSelecionada = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoSugestoesSelecionada == 2 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ver Sugestões',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoSugestoesSelecionada == 2 ? Colors.white : Colors.grey[600],
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
          SizedBox(height: 20),

          if (_opcaoSugestoesSelecionada == 0) ...[
            Text(
              'Nova Sugestão',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Categoria',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Selecione uma categoria'),
                  value: _categoriaSelecionada,
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título da Sugestão',
                hintText: 'Digite um título curto',
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
            SizedBox(height: 16),

            TextField(
              controller: _descricaoController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva sua sugestão...',
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
            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sugestão enviada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enviar Sugestão',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (_opcaoSugestoesSelecionada == 1) ...[
            Text(
              'Minhas Sugestões',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma sugestão encontrada, faça sugestões sobre alguma categoria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              'Sugestões da Comunidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

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
                    'Tire suas dúvidas sobre as categorias de serviços!',
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

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _opcaoDuvidasSelecionada = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoDuvidasSelecionada == 0 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Criar Dúvida',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoDuvidasSelecionada == 0 ? Colors.white : Colors.grey[600],
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
                        _opcaoDuvidasSelecionada = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoDuvidasSelecionada == 1 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Minhas Dúvidas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoDuvidasSelecionada == 1 ? Colors.white : Colors.grey[600],
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
                        _opcaoDuvidasSelecionada = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _opcaoDuvidasSelecionada == 2 ? Colors.red[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ver Dúvidas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _opcaoDuvidasSelecionada == 2 ? Colors.white : Colors.grey[600],
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
          SizedBox(height: 20),

          if (_opcaoDuvidasSelecionada == 0) ...[
            Text(
              'Nova Dúvida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Categoria',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Selecione uma categoria'),
                  value: _categoriaSelecionada,
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título da Dúvida',
                hintText: 'Digite um título curto',
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
            SizedBox(height: 16),

            TextField(
              controller: _descricaoController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva sua dúvida...',
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
            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dúvida enviada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enviar Dúvida',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (_opcaoDuvidasSelecionada == 1) ...[
            Text(
              'Minhas Dúvidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma dúvida encontrada, tire suas dúvidas sobre alguma categoria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              'Dúvidas da Comunidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Nenhuma dúvida encontrada na comunidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}