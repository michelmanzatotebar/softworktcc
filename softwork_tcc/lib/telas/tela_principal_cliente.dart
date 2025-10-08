import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tela_login.dart';
import 'tela_perfil_prestador.dart';
import 'tela_pesquisa_prestador.dart';
import 'tela_pesquisa_servicos.dart';
import 'tela_cliente_solicitacoes_andamento.dart';
import 'tela_notificacoes_cliente.dart';
import '../controllers/prestador_pesquisa_controller.dart';
import '../controllers/tela_principal_cliente_controller.dart';
import '../controllers/cliente_notificacoes_controller.dart';
import '../telas/tela_cliente_solicitacao_servico.dart';
import 'tela_cliente_comunidade.dart';

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
  final TelaPrincipalClienteController _principalController = TelaPrincipalClienteController();
  final ClienteNotificacoesController _notificacoesController = ClienteNotificacoesController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _servicosRecentesPesquisados = [];
  int _contadorNotificacoes = 0;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _configurarNotificacoesCliente();
    _carregarServicosRecentes();
  }

  @override
  void dispose() {
    _notificacoesController.dispose();
    super.dispose();
  }

  void _configurarCallbacks() {
    _principalController.setCallbacks(
      servicosRecentesCallback: (List<Map<String, dynamic>> servicosRecentes) {
        setState(() {
          _servicosRecentesPesquisados = servicosRecentes;
        });
      },
      errorCallback: (String erro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: Colors.red,
          ),
        );
      },
      loadingCallback: (bool loading) {
        setState(() {
          _isLoading = loading;
        });
      },
    );
  }

  void _configurarNotificacoesCliente() {
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
      errorCallback: (String erro) {
        print("Erro nas notificações: $erro");
      },
    );

    _notificacoesController.iniciarListenerNotificacoes(widget.cpfCnpj);
  }

  void _carregarServicosRecentes() {
    _principalController.carregarServicosRecentes(widget.cpfCnpj);
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

  void _logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TelaLogin()),
            (route) => false,
      );
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  void _navegarParaPesquisaServicos() async {
    UltimoServicoVerificado.onServicoAdicionado = (servico) {
      _principalController.adicionarServicoRecente(servico, widget.cpfCnpj);
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPesquisaServicos(
          clienteCpfCnpj: widget.cpfCnpj,
          clienteNome: widget.nomeUsuario,
        ),
      ),
    );

    UltimoServicoVerificado.onServicoAdicionado = null;
  }

  void _navegarParaPesquisaPrestador() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPesquisaPrestador(),
      ),
    );
  }

  void _navegarParaMinhasSolicitacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaClienteSolicitacoesAndamento(
          nomeUsuario: widget.nomeUsuario,
          cpfCnpj: widget.cpfCnpj,
        ),
      ),
    );
  }

  Widget _buildServicoCard(Map<String, dynamic> servico, {bool isRecente = false}) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  servico['nome'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isRecente)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recente',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
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
                onTap: () => _verServicoDetalhes(servico),
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

  void _verServicoDetalhes(Map<String, dynamic> servico) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaClienteSolicitacaoServico(
          servico: servico,
          clienteNome: widget.nomeUsuario,
          clienteCpfCnpj: widget.cpfCnpj,
        ),
      ),
    );

    print("Ver detalhes do serviço: ${servico['nome']}");
  }

  void _verPerfilPrestador(Map<String, dynamic> servico) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPerfilPrestador(
          prestadorCpfCnpj: servico['prestadorCpfCnpj'] ?? '',
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
                    onTap: _mostrarMenuPerfil,
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
                          builder: (context) => TelaNotificacoesCliente(
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
                onTap: _navegarParaPesquisaPrestador,
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

              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
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
                        builder: (context) => TelaClienteComunidade(
                          clienteNome: widget.nomeUsuario,
                          clienteCpfCnpj: widget.cpfCnpj,
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
                              color: Color(0xFFB71C1C),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _navegarParaMinhasSolicitacoes,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'Minhas Solicitações',
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
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: Text(
                  'Buscar Serviços',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 20),

              GestureDetector(
                onTap: _navegarParaPesquisaServicos,
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
                          'Qual serviço deseja procurar?',
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

              SizedBox(height: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_servicosRecentesPesquisados.isNotEmpty) ...[
                      Center(
                        child: Text(
                          'Serviço recente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildServicoCard(_servicosRecentesPesquisados[0], isRecente: true),
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
            ],
          ),
        ),
      ),
    );
  }
}