import 'package:flutter/material.dart';
import '../controllers/chat_prestador_cliente_controller.dart';
import '../models/chat_models.dart';

class ChatPrestadorCliente extends StatefulWidget {
  final Map<String, dynamic> solicitacao;
  final String cpfUsuarioAtual;
  final String nomeUsuarioAtual;
  final bool isCliente;

  const ChatPrestadorCliente({
    Key? key,
    required this.solicitacao,
    required this.cpfUsuarioAtual,
    required this.nomeUsuarioAtual,
    required this.isCliente,
  }) : super(key: key);

  @override
  _ChatPrestadorClienteState createState() => _ChatPrestadorClienteState();
}

class _ChatPrestadorClienteState extends State<ChatPrestadorCliente> {
  final ChatPrestadorClienteController _controller = ChatPrestadorClienteController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  List<ChatMessage> _messages = [];
  bool _outroUsuarioDigitando = false;

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _inicializarChat();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      messagesCallback: (List<ChatMessage> messages) {
        setState(() {
          _messages = messages;
        });
        _scrollParaBaixo();
      },
      errorCallback: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
      updateUICallback: () {
        if (mounted) {
          setState(() {});
        }
      },
      typingCallback: (bool isTyping) {
        setState(() {
          _outroUsuarioDigitando = isTyping;
        });
      },
    );
  }

  void _inicializarChat() {
    _controller.inicializarChat(
      solicitacao: widget.solicitacao,
      cpfUsuarioAtual: widget.cpfUsuarioAtual,
      nomeUsuarioAtual: widget.nomeUsuarioAtual,
      isCliente: widget.isCliente,
    );
  }

  void _scrollParaBaixo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _enviarMensagem() {
    final texto = _textController.text.trim();
    if (texto.isNotEmpty && !_isChatBloqueado()) {
      _controller.enviarMensagem(texto);
      _textController.clear();
      setState(() {});
    }
  }

  bool _isChatBloqueado() {
    String status = widget.solicitacao['statusSolicitacao']?.toString().toLowerCase() ?? '';
    return status == 'cancelada' || status == 'finalizado';
  }

  String _getMensagemRodape() {
    String status = widget.solicitacao['statusSolicitacao']?.toString().toLowerCase() ?? '';
    if (status == 'cancelada') {
      return 'Chat finalizado, solicitação cancelada.';
    } else if (status == 'finalizado') {
      return 'Serviço finalizado.';
    }
    return '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8),
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
        title: _isLoading
            ? Text(
          'Carregando...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _controller.tituloChat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (_controller.subtituloChat.isNotEmpty)
              Text(
                _controller.subtituloChat,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (_outroUsuarioDigitando && !_isChatBloqueado())
              Text(
                'digitando...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.red[600],
              size: 24,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Início da conversa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isChatBloqueado()
                        ? 'Chat não está mais disponível para envio'
                        : 'Envie a primeira mensagem!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          if (_getMensagemRodape().isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange[50],
              child: Text(
                _getMensagemRodape(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          if (!_isChatBloqueado())
            _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isAuthor(widget.cpfUsuarioAtual);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    _controller.outroUsuario?.initials ?? '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.red[600] : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: isMe ? Radius.circular(20) : Radius.circular(4),
                      bottomRight: isMe ? Radius.circular(4) : Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.timeFormatted,
                            style: TextStyle(
                              color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 4),
                            _buildStatusIcon(message.status),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.red[600],
                  child: Text(
                    _controller.usuarioAtual?.initials ?? '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
          ),
        );
      case 'sent':
        return Icon(Icons.done, size: 14, color: Colors.white.withOpacity(0.7));
      case 'delivered':
        return Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.7));
      case 'read':
        return Icon(Icons.done_all, size: 14, color: Colors.blue[300]);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                maxLength: 500,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  if (text.trim().isNotEmpty) {
                    _controller.indicarDigitacao();
                  } else {
                    _controller.pararDigitacao();
                  }
                },
                onSubmitted: (_) => _enviarMensagem(),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _enviarMensagem,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}