import 'package:flutter/material.dart';
import '../controllers/servicos_pesquisa_controller.dart';
import '../controllers/tela_principal_cliente_controller.dart';

class UltimoServicoVerificado {
  static Map<String, dynamic>? servico;
  static Function(Map<String, dynamic>)? onServicoAdicionado;
}

class TelaPesquisaServicos extends StatefulWidget {
  final String? clienteCpfCnpj;

  const TelaPesquisaServicos({Key? key, this.clienteCpfCnpj}) : super(key: key);

  @override
  _TelaPesquisaServicosState createState() => _TelaPesquisaServicosState();
}

class _TelaPesquisaServicosState extends State<TelaPesquisaServicos> {
  final _servicoController = TextEditingController();
  final ServicosPesquisaController _servicosPesquisaController = ServicosPesquisaController();

  bool _isSearchingServicos = false;
  List<Map<String, dynamic>> _servicosEncontrados = [];
  List<String> _categorias = [];
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _carregarCategorias();
  }

  void _configurarCallbacks() {
    _servicosPesquisaController.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isSearchingServicos = isLoading;
        });
      },
      resultsCallback: (List<Map<String, dynamic>> resultados) {
        setState(() {
          _servicosEncontrados = resultados;
        });
      },
      categoriasCallback: (List<String> categorias) {
        setState(() {
          _categorias = categorias;
        });
      },
      errorCallback: (String mensagem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _carregarCategorias() {
    _servicosPesquisaController.carregarCategorias();
  }

  void _pesquisarServico(String query) {
    _servicosPesquisaController.pesquisarServicos(query, categoriaFiltro: _categoriaSelecionada);
  }

  void _aplicarFiltroCategoria(String? categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
    });
    _pesquisarServico(_servicoController.text);
  }

  void _limparFiltros() {
    setState(() {
      _categoriaSelecionada = null;
      _servicoController.clear();
      _servicosEncontrados = [];
    });
  }

  Widget _buildServicoCard(Map<String, dynamic> servico) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            servico['nome'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            servico['categoria'] ?? '',
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          if (servico['prestadorNome'] != null && servico['prestadorNome'].toString().isNotEmpty)
            Row(
              children: [
                Text(
                  'Prestador: ${servico['prestadorNome']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _verPerfilPrestador(servico),
                  child: Text(
                    'ver perfil',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 4),
          if (servico['descricao'] != null && servico['descricao'].toString().isNotEmpty)
            Text(
              servico['descricao'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  servico['valorFormatado'] ?? 'R\$ ${servico['valor']?.toStringAsFixed(2) ?? '0,00'}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _abrirDetalhesServico(servico),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ver serviço',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarFiltroCategoria() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filtrar por categoria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  if (_categoriaSelecionada != null)
                    TextButton(
                      onPressed: () {
                        _aplicarFiltroCategoria(null);
                        Navigator.pop(context);
                      },
                      child: Text('Limpar'),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = _categorias[index];
                    final isSelected = _categoriaSelecionada == categoria;

                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.red : Colors.grey,
                      ),
                      title: Text(categoria),
                      onTap: () {
                        _aplicarFiltroCategoria(categoria);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirDetalhesServico(Map<String, dynamic> servico) {
    _salvarUltimoServicoVerificado(servico);

    if (UltimoServicoVerificado.onServicoAdicionado != null) {
      UltimoServicoVerificado.onServicoAdicionado!(servico);
    }

    print("Redirecionado para tela de solicitar serviço: ${servico['nome']} - ID: ${servico['id']}");
  }

  void _verPerfilPrestador(Map<String, dynamic> servico) {
    print("Redirecionando para o perfil do prestador: ${servico['prestadorNome']}");
  }

  void _salvarUltimoServicoVerificado(Map<String, dynamic> servico) {
    Map<String, dynamic> servicoLimpo = {
      'id': servico['id'],
      'nome': servico['nome'],
      'descricao': servico['descricao'],
      'categoria': servico['categoria'],
      'valor': servico['valor'],
      'valorFormatado': servico['valorFormatado'],
      'prestadorNome': servico['prestadorNome'],
      'prestadorCpfCnpj': servico['prestadorCpfCnpj'],
    };
    UltimoServicoVerificado.servico = servicoLimpo;
  }

  @override
  void dispose() {
    _servicoController.dispose();
    super.dispose();
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
                        'Buscar Serviços',
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

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _servicoController,
                        onChanged: _pesquisarServico,
                        decoration: InputDecoration(
                          hintText: 'Qual serviço deseja procurar?',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _mostrarFiltroCategoria,
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _categoriaSelecionada != null ? Colors.red[600] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: _categoriaSelecionada != null ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_categoriaSelecionada != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, size: 16, color: Colors.red[600]),
                      SizedBox(width: 4),
                      Text(
                        _categoriaSelecionada!,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _aplicarFiltroCategoria(null),
                        child: Icon(Icons.close, size: 16, color: Colors.red[600]),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20),

              if (_servicoController.text.isNotEmpty) ...[
                Text(
                  _isSearchingServicos
                      ? 'Buscando serviços...'
                      : 'Serviços encontrados: ${_servicosEncontrados.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 16),
              ],

              if (_isSearchingServicos)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.red[600],
                    ),
                  ),
                )
              else if (_servicosEncontrados.isEmpty && _servicoController.text.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum serviço encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tente buscar por outro termo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_servicosEncontrados.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _servicosEncontrados.length,
                      itemBuilder: (context, index) {
                        final servico = _servicosEncontrados[index];
                        return _buildServicoCard(servico);
                      },
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Digite para buscar serviços',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Use o filtro para buscar por categoria',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
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