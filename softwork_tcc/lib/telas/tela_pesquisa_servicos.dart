import 'package:flutter/material.dart';
import '../controllers/servicos_pesquisa_controller.dart';

// Classe para armazenar o último serviço verificado globalmente
class UltimoServicoVerificado {
  static Map<String, dynamic>? servico;
}

class TelaPesquisaServicos extends StatefulWidget {
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
    // Reaplica a pesquisa com o novo filtro se há texto no campo
    if (_servicoController.text.isNotEmpty) {
      _pesquisarServico(_servicoController.text);
    }
  }

  void _mostrarFiltroCategoria() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtrar por Categoria',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              ListTile(
                leading: Icon(
                  _categoriaSelecionada == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _categoriaSelecionada == null ? Colors.red : Colors.grey,
                ),
                title: Text('Todas as categorias'),
                onTap: () {
                  _aplicarFiltroCategoria(null);
                  Navigator.pop(context);
                },
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _categorias.length,
                  itemBuilder: (context, index) {
                    String categoria = _categorias[index];
                    bool isSelected = _categoriaSelecionada == categoria;

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
    // Salva o último serviço verificado
    _salvarUltimoServicoVerificado(servico);

    print("Redirecionado para o perfil do serviço: ${servico['nome']} - ID: ${servico['id']}");
    // TODO: Navegar para tela de detalhes do serviço
  }

  void _salvarUltimoServicoVerificado(Map<String, dynamic> servico) {
    // Remove dados desnecessários para evitar problemas de serialização
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

    // Aqui você pode usar SharedPreferences ou outra forma de persistência
    // Por simplicidade, vou usar uma variável estática global
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
                child: TextField(
                  controller: _servicoController,
                  onChanged: _pesquisarServico,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do serviço...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_servicoController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _servicoController.clear();
                              _pesquisarServico('');
                            },
                            child: Icon(Icons.close, color: Colors.grey[600]),
                          ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _mostrarFiltroCategoria,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _categoriaSelecionada != null ? Colors.red : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: _categoriaSelecionada != null ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 20),

              if (_servicoController.text.isNotEmpty) ...[
                Row(
                  children: [
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
                    if (_categoriaSelecionada != null) ...[
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          _categoriaSelecionada!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16),
              ],

              Expanded(
                child: _servicoController.text.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search,
                          size: 40,
                          color: Colors.grey[400],
                        ),
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
                    ],
                  ),
                )
                    : _isSearchingServicos
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : _servicosEncontrados.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.work_off,
                          size: 40,
                          color: Colors.grey[400],
                        ),
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
                        'Tente digitar um nome diferente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _servicosEncontrados.length,
                  itemBuilder: (context, index) {
                    final servico = _servicosEncontrados[index];
                    return _buildServicoCard(servico);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicoCard(Map<String, dynamic> servico) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
                        servico['nome'] ?? '',
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
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          servico['categoria'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (servico['prestadorNome'] != null && servico['prestadorNome'].toString().isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                servico['prestadorNome'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (servico['descricao'] != null && servico['descricao'].toString().isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                servico['descricao'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 12),

            Text(
              servico['valorFormatado'] ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green[600],
              ),
            ),

            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[600]!, width: 2),
                ),
                child: ElevatedButton(
                  onPressed: () => _abrirDetalhesServico(servico),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ver Serviço',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}