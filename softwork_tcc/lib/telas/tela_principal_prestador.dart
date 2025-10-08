import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tela_login.dart';
import 'tela_gerenciar_servicos_prestador.dart';
import 'tela_detalhes_solicitacao_prestador.dart';
import 'tela_perfil_prestador.dart';
import 'tela_prestador_solicitacoes_andamento.dart';
import 'tela_notificacoes_prestador.dart';
import '../controllers/tela_principal_prestador_controller.dart';
import '../controllers/prestador_notificacoes_controller.dart';
import '../telas/tela_prestador_comunidade.dart';

class TelaPrincipalPrestador extends StatefulWidget {
  final String nomeUsuario;
  final String cpfCnpj;

  const TelaPrincipalPrestador({
    Key? key,
    required this.nomeUsuario,
    required this.cpfCnpj,
  }) : super(key: key);

  @override
  _TelaPrincipalPrestadorState createState() => _TelaPrincipalPrestadorState();
}

class _TelaPrincipalPrestadorState extends State<TelaPrincipalPrestador> {
  final TelaPrincipalPrestadorController _controller = TelaPrincipalPrestadorController();
  final PrestadorNotificacoesController _notificacoesController = PrestadorNotificacoesController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _solicitacoesPendentes = [];
  int _contadorNotificacoes = 0;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _configurarNotificacoes();
    _carregarSolicitacoes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notificacoesController.dispose();
    super.dispose();
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
          _solicitacoesPendentes = solicitacoes;
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

  void _configurarNotificacoes() {
    _notificacoesController.setCallbacks(
      novaNotificacaoCallback: (String mensagem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(mensagem)),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      contadorCallback: (int contador) {
        setState(() {
          _contadorNotificacoes = contador;
        });
      },
      errorCallback: (String error) {
        print("Erro nas notificações: $error");
      },
    );

    _notificacoesController.iniciarListenerNotificacoes(widget.cpfCnpj);
  }

  void _carregarSolicitacoes() {
    _controller.carregarSolicitacoesPrestador(widget.cpfCnpj);
  }

  String _formatarDataAtual() {
    final agora = DateTime.now();

    final diasSemana = [
      'Seg', 'Ter', 'Qua', 'Qui',
      'Sex', 'Sáb', 'Dom'
    ];

    final meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    final diaSemana = diasSemana[agora.weekday - 1];
    final dia = agora.day;
    final mes = meses[agora.month - 1];
    final ano = agora.year;

    return '$diaSemana, $dia $mes $ano';
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
                            'Prestador Autônomo',
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaPerfilPrestador(
                                prestadorCpfCnpj: widget.cpfCnpj,
                                isMeuPerfil: true,
                              ),
                            ),
                          );
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

  void _verificarSolicitacao(Map<String, dynamic> solicitacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesSolicitacaoPrestador(
          solicitacao: solicitacao,
          prestadorNome: widget.nomeUsuario,
          prestadorCpfCnpj: widget.cpfCnpj,
        ),
      ),
    ).then((_) {
      _carregarSolicitacoes();
    });
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
                          color: Colors.orange,
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
              'Categoria: ${solicitacao['categoria'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
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
              'Data: ${_controller.formatarDataSimples(solicitacao['dataSolicitacao'] ?? '')}',
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
                  _controller.formatarValorSimples(solicitacao['servico']?['valor']),
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => _verificarSolicitacao(solicitacao),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Verificar',
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
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaNotificacoesPrestador(
                            nomeUsuario: widget.nomeUsuario,
                            cpfCnpj: widget.cpfCnpj,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.red[600],
                            size: 18,
                          ),
                          if (_contadorNotificacoes > 0) ...[
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_contadorNotificacoes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaPrestadorComunidade(
                                prestadorNome: widget.nomeUsuario,
                                prestadorCpfCnpj: widget.cpfCnpj,
                              ),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaGerenciarServicos(
                                nomeUsuario: widget.nomeUsuario,
                                cpfCnpj: widget.cpfCnpj,
                              ),
                            ),
                          );
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
                                  'Meus serviços',
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

              SizedBox(height: 20),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaPrestadorSolicitacoesAndamento(
                                nomeUsuario: widget.nomeUsuario,
                                cpfCnpj: widget.cpfCnpj,
                              ),
                            ),
                          );
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
                                  'Solicitações em andamento',
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

              SizedBox(height: 40),

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Solicitações a verificar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              if (!_isLoading) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Solicitações pendentes: ${_solicitacoesPendentes.length}',
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
                    : _solicitacoesPendentes.isEmpty
                    ? Center(
                  child: Text(
                    'Nenhuma solicitação no momento',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _solicitacoesPendentes.length,
                  itemBuilder: (context, index) {
                    final solicitacao = _solicitacoesPendentes[index];
                    return _buildSolicitacaoCard(solicitacao, index);
                  },
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
}