import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tela_login.dart';
import 'tela_pesquisa_prestador.dart';
import '../controllers/prestador_pesquisa_controller.dart';

class TelaPrincipalCliente extends StatefulWidget {
  final String nomeUsuario;
  final String cpfCnpj;

  const TelaPrincipalCliente({
    Key? key,
    required this.nomeUsuario,
    required this.cpfCnpj,
  }) : super(key: key);

  @override
  _TelaPrincipalClienteState createState() => _TelaPrincipalClienteState();
}

class _TelaPrincipalClienteState extends State<TelaPrincipalCliente> {
  final _servicoController = TextEditingController();

  bool _isLoading = false;
  bool _showServicoResults = false;
  OverlayEntry? _servicoOverlay;
  final LayerLink _servicoLayerLink = LayerLink();

  List<Map<String, dynamic>> _servicosEncontrados = [];
  List<Map<String, dynamic>> _servicosRecentesPesquisados = [];

  @override
  void initState() {
    super.initState();
  }

  String _formatarDataAtual() {
    final agora = DateTime.now();

    final diasSemana = [
      'Segunda', 'Terça', 'Quarta', 'Quinta',
      'Sexta', 'Sábado', 'Domingo'
    ];

    final meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    final diaSemana = diasSemana[agora.weekday - 1];
    final dia = agora.day;
    final mes = meses[agora.month - 1];
    final ano = agora.year;

    if (agora.weekday == 6 || agora.weekday == 7) {
      return '$diaSemana, $dia de $mes $ano';
    } else {
      return '$diaSemana Feira, $dia de $mes $ano';
    }
  }

  void _mostrarMenuPerfil() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        20,
        80,
        MediaQuery.of(context).size.width - 320,
        0,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Container(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nomeUsuario,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Cliente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue[600],
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print("Editar perfil");
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Editar Perfil',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.red[600],
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () {
                          Navigator.pop(context);
                          _logout();
                        },
                        child: Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => TelaLogin()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Erro ao fazer logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pesquisarServico(String query) {
    // TODO: Implementar lógica de pesquisa de serviços
    print("Pesquisando serviços: $query");

    if (query.isNotEmpty) {
      _mostrarMenuServicos();
    } else {
      _esconderMenuServicos();
    }
  }

  void _mostrarMenuServicos() {
    _esconderMenuServicos();

    _servicoOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _servicoLayerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _servicosEncontrados.isEmpty
                  ? Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Nenhum serviço encontrado',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _servicosEncontrados.length,
                itemBuilder: (context, index) {
                  final servico = _servicosEncontrados[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        title: Text(
                          servico['nome'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              servico['categoria'] ?? '',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'R\$ ${servico['valor']?.toStringAsFixed(2) ?? '0,00'}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        onTap: () {
                          _esconderMenuServicos();
                          _verificarServico(servico);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_servicoOverlay!);
  }

  void _esconderMenuServicos() {
    _servicoOverlay?.remove();
    _servicoOverlay = null;
  }

  void _verificarServico(Map<String, dynamic> servico) {
    // TODO: Navegar para tela de verificar serviço
    print("Verificar serviço: ${servico['nome']}");

    setState(() {
      _servicosRecentesPesquisados.removeWhere((s) => s['id'] == servico['id']);

      _servicosRecentesPesquisados.insert(0, servico);
      if (_servicosRecentesPesquisados.length > 5) {
        _servicosRecentesPesquisados.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _esconderMenuServicos();
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
              // Header com perfil e data
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _mostrarMenuPerfil();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatarDataAtual(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Título
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Buscar Prestadores Autônomos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaPesquisaPrestador(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600]),
                        SizedBox(width: 12),
                        Text(
                          'Qual prestador deseja procurar?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF5757).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          print("Navegar para Comunidade");
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5757),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  'Comunidade',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 15,
                                top: 15,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFFFF5757),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFB71C1C).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          print("Navegar para Minhas Solicitações");
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFFB71C1C),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  'Minhas solicitações',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 15,
                                top: 15,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFFB71C1C),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Buscar serviços',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              CompositedTransformTarget(
                link: _servicoLayerLink,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _servicoController,
                    onChanged: _pesquisarServico,
                    decoration: InputDecoration(
                      hintText: 'Qual serviço deseja procurar?',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_servicosRecentesPesquisados.isNotEmpty) ...[
                      Text(
                        'Serviços recentes pesquisados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _servicosRecentesPesquisados.length,
                          itemBuilder: (context, index) {
                            final servico = _servicosRecentesPesquisados[index];
                            return _buildServicoCard(servico, isRecente: true);
                          },
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Center(
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
                                'Nenhum serviço recente encontrado',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicoCard(Map<String, dynamic> servico, {bool isRecente = false}) {
    String descricao = servico['descricao'] ?? '';
    bool descricaoLonga = descricao.length > 80;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecente ? Colors.blue[200]! : Colors.grey[300]!,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              servico['nome'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isRecente)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Recente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
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
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              descricaoLonga
                  ? '${descricao.substring(0, 80)}...'
                  : descricao,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${servico['valor']?.toStringAsFixed(2) ?? '0,00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[600],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _verificarServico(servico),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verificar serviço',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                        ),
                      ],
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