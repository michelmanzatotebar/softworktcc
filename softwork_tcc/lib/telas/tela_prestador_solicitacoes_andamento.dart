import 'package:flutter/material.dart';
import '../controllers/prestador_solicitacoes_andamento_controller.dart';
import '../telas/chat_prestador_cliente.dart';

class TelaPrestadorSolicitacoesAndamento extends StatefulWidget {
  final String nomeUsuario;
  final String cpfCnpj;

  const TelaPrestadorSolicitacoesAndamento({
    Key? key,
    required this.nomeUsuario,
    required this.cpfCnpj,
  }) : super(key: key);

  @override
  _TelaPrestadorSolicitacoesAndamentoState createState() => _TelaPrestadorSolicitacoesAndamentoState();
}

class _TelaPrestadorSolicitacoesAndamentoState extends State<TelaPrestadorSolicitacoesAndamento> {
  final PrestadorSolicitacoesAndamentoController _controller = PrestadorSolicitacoesAndamentoController();

  List<Map<String, dynamic>> _solicitacoes = [];
  List<Map<String, dynamic>> _solicitacoesFiltradas = [];
  bool _isLoading = true;
  String _filtroSelecionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _carregarSolicitacoes();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      solicitacoesCallback: (List<Map<String, dynamic>> solicitacoes) {
        setState(() {
          _solicitacoes = solicitacoes;
          _aplicarFiltro();
        });
      },
      errorCallback: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _carregarSolicitacoes() {
    _controller.carregarSolicitacoesPrestador(widget.cpfCnpj);
  }

  void _aplicarFiltro() {
    setState(() {
      if (_filtroSelecionado == 'Todas') {
        _solicitacoesFiltradas = List.from(_solicitacoes);
      } else {
        _solicitacoesFiltradas = _solicitacoes.where((solicitacao) {
          String status = solicitacao['statusSolicitacao'] ?? '';
          return status.toLowerCase() == _filtroSelecionado.toLowerCase();
        }).toList();
      }
    });
  }

  void _mostrarModalStatus(Map<String, dynamic> solicitacao) {
    String statusAtual = solicitacao['statusSolicitacao'] ?? '';
    List<String> opcoes = _controller.getOpcoesStatus(statusAtual);
    String? statusSelecionado;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                'Definir Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Status atual: $statusAtual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...opcoes.map((opcao) {
                    return RadioListTile<String>(
                      title: Text(opcao),
                      value: opcao,
                      groupValue: statusSelecionado,
                      activeColor: Colors.red[600],
                      onChanged: (String? value) {
                        setStateModal(() {
                          statusSelecionado = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: statusSelecionado != null
                      ? () async {
                    Navigator.of(context).pop();
                    await _controller.atualizarStatusSolicitacao(
                      solicitacao['id'],
                      statusSelecionado!,
                    );
                    _carregarSolicitacoes();
                  }
                      : null,
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
      },
    );
  }

  void _mostrarDetalhesSolicitacao(Map<String, dynamic> solicitacao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detalhes da Solicitação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetalheRow('Título:', solicitacao['titulo'] ?? 'N/A'),
                SizedBox(height: 8),
                _buildDetalheRow('Status:', solicitacao['statusSolicitacao'] ?? 'N/A'),
                SizedBox(height: 8),
                _buildDetalheRow('Data:', _controller.formatarDataCompleta(solicitacao['dataSolicitacao'] ?? '')),
                SizedBox(height: 8),
                _buildDetalheRow('Serviço:', solicitacao['servico']?['nome'] ?? 'N/A'),
                SizedBox(height: 8),
                _buildDetalheRow('Valor:', _controller.formatarValor(solicitacao['servico']?['valor'])),
                SizedBox(height: 8),
                _buildDetalheRow('Cliente:', solicitacao['cliente']?['nome'] ?? 'N/A'),
                SizedBox(height: 12),
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    solicitacao['descricao'] ?? 'Nenhuma descrição fornecida',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetalheRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                        'Solicitações em Andamento',
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
              SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFiltroChip('Todas'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Aceita'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Em andamento'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Concluída'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Finalizado'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Recusada'),
                    SizedBox(width: 8),
                    _buildFiltroChip('Cancelada'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (_solicitacoesFiltradas.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    _filtroSelecionado == 'Todas'
                        ? '${_solicitacoesFiltradas.length} solicitações encontradas:'
                        : '${_solicitacoesFiltradas.length} solicitações ${_filtroSelecionado.toLowerCase()}s:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                  ),
                )
                    : _solicitacoesFiltradas.isEmpty
                    ? Center(
                  child: Text(
                    _filtroSelecionado == 'Todas'
                        ? 'Nenhuma solicitação encontrada'
                        : 'Nenhuma solicitação ${_filtroSelecionado.toLowerCase()} encontrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _solicitacoesFiltradas.length,
                  itemBuilder: (context, index) {
                    final solicitacao = _solicitacoesFiltradas[index];
                    return _buildSolicitacaoCard(solicitacao, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String filtro) {
    bool isSelected = _filtroSelecionado == filtro;
    return FilterChip(
      label: Text(
        filtro,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.red[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filtroSelecionado = filtro;
          _aplicarFiltro();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.red[600],
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.red[600]! : Colors.red[400]!,
        width: 1.5,
      ),
    );
  }

  Widget _buildSolicitacaoCard(Map<String, dynamic> solicitacao, int index) {
    String status = solicitacao['statusSolicitacao'] ?? 'Pendente';
    bool podeAlterarStatus = _controller.podeAlterarStatus(status);
    bool chatDisponivel = ['Aceita', 'Em andamento', 'Concluída', 'Cancelada', 'Finalizado'].contains(status) && !['Pendente', 'Recusada'].contains(status);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    solicitacao['titulo'] ?? 'Serviço',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _controller.getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Serviço: ${solicitacao['servico']?['nome'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Categoria: ${solicitacao['servico']?['categoria'] ?? solicitacao['categoria'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cliente: ${solicitacao['cliente']?['nome'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Data: ${_controller.formatarData(solicitacao['dataSolicitacao'] ?? '')}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (solicitacao['descricao'] != null && solicitacao['descricao'].isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                solicitacao['descricao'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            SizedBox(height: 16),
            Text(
              _controller.formatarValor(solicitacao['servico']?['valor'] ?? solicitacao['valor']),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                if (podeAlterarStatus)
                  SizedBox(
                    width: 110,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _mostrarModalStatus(solicitacao),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Definir Status',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                if (podeAlterarStatus && chatDisponivel) SizedBox(width: 8),
                if (chatDisponivel)
                  SizedBox(
                    width: 80,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPrestadorCliente(
                              solicitacao: solicitacao,
                              cpfUsuarioAtual: widget.cpfCnpj,
                              nomeUsuarioAtual: widget.nomeUsuario,
                              isCliente: false,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Chat',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                Spacer(),
                IconButton(
                  onPressed: () => _mostrarDetalhesSolicitacao(solicitacao),
                  icon: Icon(Icons.info_outline),
                  color: Colors.red[600],
                  iconSize: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}