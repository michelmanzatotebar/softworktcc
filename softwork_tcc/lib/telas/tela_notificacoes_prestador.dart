import 'package:flutter/material.dart';
import '../controllers/notificacoes_prestador_controller.dart';

class TelaNotificacoesPrestador extends StatefulWidget {
  final String nomeUsuario;
  final String cpfCnpj;

  const TelaNotificacoesPrestador({
    Key? key,
    required this.nomeUsuario,
    required this.cpfCnpj,
  }) : super(key: key);

  @override
  _TelaNotificacoesPrestadorState createState() => _TelaNotificacoesPrestadorState();
}

class _TelaNotificacoesPrestadorState extends State<TelaNotificacoesPrestador> {
  final NotificacoesPrestadorController _controller = NotificacoesPrestadorController();

  List<Map<String, dynamic>> _notificacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _carregarNotificacoes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      notificacoesCallback: (List<Map<String, dynamic>> notificacoes) {
        setState(() {
          _notificacoes = notificacoes;
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

  void _carregarNotificacoes() {
    _controller.carregarNotificacoesPrestador(widget.cpfCnpj);
  }

  void _marcarTodasComoLidas() async {
    await _controller.marcarTodasComoLidas(widget.cpfCnpj);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todas as notificações foram marcadas como lidas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildNotificacaoCard(Map<String, dynamic> notificacao, int index) {
    bool isLida = notificacao['lida'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLida ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLida ? Colors.grey[200]! : Colors.red[200]!,
          width: isLida ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isLida ? 0.05 : 0.1),
            spreadRadius: 1,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _controller.getCorTipo(notificacao['tipo']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _controller.getTipoNotificacao(notificacao['tipo']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              if (!isLida)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(width: 8),
              Text(
                _controller.formatarData(notificacao['timestamp'] ?? ''),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Text(
            notificacao['titulo'] ?? 'Sem título',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isLida ? FontWeight.w500 : FontWeight.w700,
              color: isLida ? Colors.grey[700] : Colors.black87,
            ),
          ),

          SizedBox(height: 8),

          Text(
            notificacao['mensagem'] ?? 'Sem descrição',
            style: TextStyle(
              fontSize: 14,
              color: isLida ? Colors.grey[600] : Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int naoLidas = _notificacoes.where((n) => n['lida'] == false).length;

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
                        'Notificações',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (naoLidas > 0)
                    GestureDetector(
                      onTap: _marcarTodasComoLidas,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Marcar todas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 40),
                ],
              ),

              SizedBox(height: 30),

              if (!_isLoading && _notificacoes.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      '${_notificacoes.length} notificações:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (naoLidas > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$naoLidas novas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 20),
              ],

              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                  ),
                )
                    : _notificacoes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quando houver novas notificações,\nelas aparecerão aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) {
                    return _buildNotificacaoCard(_notificacoes[index], index);
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