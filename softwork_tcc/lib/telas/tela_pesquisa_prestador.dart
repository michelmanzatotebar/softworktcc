import 'package:flutter/material.dart';
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

  void _pesquisarPrestador(String query) {
    _prestadorPesquisaController.pesquisarPrestadores(query);
  }

  void _abrirPerfilPrestador(Map<String, dynamic> prestador) {
    print("Redirecionado para o perfil do prestador: ${prestador['nome']} - CPF/CNPJ: ${prestador['cpfCnpj']}");
    // TODO: Navegar para tela de perfil do prestador
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

              if (_prestadorController.text.isNotEmpty) ...[
                Text(
                  _isSearchingPrestadores
                      ? 'Buscando prestadores...'
                      : 'Prestadores encontrados: ${_prestadoresEncontrados.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 16),
              ],

              Expanded(
                child: _prestadorController.text.isEmpty
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
                        'Digite para buscar prestadores',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                    : _isSearchingPrestadores
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
                          Icons.person_off,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum prestador encontrado',
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
                  itemCount: _prestadoresEncontrados.length,
                  itemBuilder: (context, index) {
                    final prestador = _prestadoresEncontrados[index];
                    return _buildPrestadorCard(prestador);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrestadorCard(Map<String, dynamic> prestador) {
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestador['nome'] ?? '',
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
                          'Prestador Autônomo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (prestador['logradouro'] != null && prestador['logradouro'].toString().isNotEmpty) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prestador['logradouro'],
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
                      if (prestador['telefone'] != null && prestador['telefone'].toString().isNotEmpty) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              prestador['telefone'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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

            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[600]!, width: 2),
                ),
                child: ElevatedButton(
                  onPressed: () => _abrirPerfilPrestador(prestador),
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
                        Icons.person,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ver Perfil',
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