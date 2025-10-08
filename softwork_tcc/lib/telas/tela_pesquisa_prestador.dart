import 'package:flutter/material.dart';
import 'package:softwork_tcc/telas/tela_perfil_prestador.dart';
import '../controllers/prestador_pesquisa_controller.dart';

class TelaPesquisaPrestador extends StatefulWidget {
  @override
  _TelaPesquisaPrestadorState createState() => _TelaPesquisaPrestadorState();
}

class _TelaPesquisaPrestadorState extends State<TelaPesquisaPrestador> {
  final _prestadorController = TextEditingController();
  final PrestadorPesquisaController _prestadorPesquisaController = PrestadorPesquisaController();

  bool _isSearchingPrestadores = false;
  List<Map<String, dynamic>> _prestadoresEncontrados = [];

  @override
  void initState() {
    super.initState();
    _configurarCallbacksPrestador();
    _carregarUltimosPrestadores();
  }

  void _configurarCallbacksPrestador() {
    _prestadorPesquisaController.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isSearchingPrestadores = isLoading;
        });
      },
      resultsCallback: (List<Map<String, dynamic>> resultados) {
        setState(() {
          _prestadoresEncontrados = resultados;
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

  void _carregarUltimosPrestadores() {
    _prestadorPesquisaController.carregarUltimosPrestadores();
  }

  void _pesquisarPrestador(String query) {
    _prestadorPesquisaController.pesquisarPrestadores(query);
  }

  void _abrirPerfilPrestador(Map<String, dynamic> prestador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPerfilPrestador(
          prestadorCpfCnpj: prestador['cpfCnpj'] ?? '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prestadorController.dispose();
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
                        'Buscar Prestadores',
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
                  controller: _prestadorController,
                  onChanged: _pesquisarPrestador,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do prestador...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _prestadorController.text.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _prestadorController.clear();
                        _pesquisarPrestador('');
                      },
                      child: Icon(Icons.close, color: Colors.grey[600]),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 20),

              if (_prestadoresEncontrados.isNotEmpty) ...[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _prestadorController.text.isNotEmpty
                            ? 'Prestadores encontrados: '
                            : 'Últimos prestadores cadastrados: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      TextSpan(
                        text: '${_prestadoresEncontrados.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              Expanded(
                child: _isSearchingPrestadores
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : _prestadoresEncontrados.isEmpty
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
                          _prestadorController.text.isNotEmpty
                              ? Icons.person_off
                              : Icons.search,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _prestadorController.text.isNotEmpty
                            ? 'Nenhum prestador encontrado'
                            : 'Nenhum prestador disponível',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _prestadorController.text.isNotEmpty
                            ? 'Tente ajustar sua pesquisa'
                            : 'Aguarde novos prestadores se cadastrarem',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _prestadoresEncontrados.length,
                  itemBuilder: (context, index) {
                    final prestador = _prestadoresEncontrados[index];
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
                                radius: 25,
                                backgroundColor: Colors.red[100],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.red[600],
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prestador['nome'] ?? 'Nome não informado',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      prestador['email'] ?? 'Email não informado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (prestador['telefone'] != null && prestador['telefone'].toString().isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.grey[600], size: 16),
                                SizedBox(width: 8),
                                Text(
                                  prestador['telefone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (prestador['logradouro'] != null && prestador['logradouro'].toString().isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prestador['logradouro'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => _abrirPerfilPrestador(prestador),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Ver perfil',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}