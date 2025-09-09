import 'package:flutter/material.dart';
import '../controllers/prestador_solicitacoes_andamento_controller.dart';

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
                    solicitacao['descricao'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetalheRow(String label, String value) {
    return Row(
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
    );
  }

  Widget _buildFiltros() {
    return Container(
      height: 50,
      child: Row(
        children: [
          _buildBotaoFiltro('Todas'),
          SizedBox(width: 12),
          _buildBotaoFiltro('Aceita'),
          SizedBox(width: 12),
          _buildBotaoFiltro('Recusada'),
        ],
      ),
    );
  }

  Widget _buildBotaoFiltro(String filtro) {
    final isSelected = _filtroSelecionado == filtro;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSelecionado = filtro;
          _aplicarFiltro();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.red[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          filtro,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
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
                        'Minhas Solicitações',
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

              _buildFiltros(),

              SizedBox(height: 20),

              if (!_isLoading) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _filtroSelecionado == 'Todas'
                        ? '${_solicitacoesFiltradas.length} solicitações encontradas:'
                        : '${_solicitacoesFiltradas.length} solicitações ${_filtroSelecionado.toLowerCase()}s:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],

              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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
                      color: Colors.red[400],
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

  Widget _buildSolicitacaoCard(Map<String, dynamic> solicitacao, int index) {
    String status = solicitacao['statusSolicitacao'] ?? 'Pendente';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitacao['titulo'] ?? 'Sem título',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _controller.getStatusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              'Serviço: ${solicitacao['servico']?['nome'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 4),

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

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _controller.formatarValor(solicitacao['servico']?['valor']),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red[600],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _mostrarDetalhesSolicitacao(solicitacao),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Ver Detalhes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}