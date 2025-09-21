import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_models.dart';
import 'dart:async';

class ChatPrestadorClienteController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ChatRoom? _room;
  ChatRoom? get room => _room;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  ChatUser? _usuarioAtual;
  ChatUser? get usuarioAtual => _usuarioAtual;

  ChatUser? _outroUsuario;
  ChatUser? get outroUsuario => _outroUsuario;

  Map<String, dynamic>? _solicitacao;
  String? _roomId;

  bool _outroUsuarioDigitando = false;
  bool get outroUsuarioDigitando => _outroUsuarioDigitando;
  Timer? _typingTimer;

  Function(bool)? onLoadingChanged;
  Function(List<ChatMessage>)? onMessagesChanged;
  Function(String)? onError;
  Function()? onUpdateUI;
  Function(bool)? onTypingChanged;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<ChatMessage>)? messagesCallback,
    Function(String)? errorCallback,
    Function()? updateUICallback,
    Function(bool)? typingCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onMessagesChanged = messagesCallback;
    onError = errorCallback;
    onUpdateUI = updateUICallback;
    onTypingChanged = typingCallback;
  }

  Future<void> inicializarChat({
    required Map<String, dynamic> solicitacao,
    required String cpfUsuarioAtual,
    required String nomeUsuarioAtual,
    required bool isCliente,
  }) async {
    try {
      _isLoading = true;
      onLoadingChanged?.call(true);

      _solicitacao = solicitacao;
      _roomId = "solicitacao_${solicitacao['id']}";

      print("=== INICIALIZANDO CHAT (REALTIME DB) ===");
      print("Room ID: $_roomId");
      print("Usuário atual: $nomeUsuarioAtual ($cpfUsuarioAtual)");
      print("É cliente: $isCliente");

      _usuarioAtual = _criarUsuario(
        cpf: cpfUsuarioAtual,
        nome: nomeUsuarioAtual,
      );

      if (isCliente) {
        _outroUsuario = _criarUsuario(
          cpf: solicitacao['prestador']['cpfCnpj'],
          nome: solicitacao['prestador']['nome'],
        );
      } else {
        _outroUsuario = _criarUsuario(
          cpf: solicitacao['cliente']['cpfCnpj'],
          nome: solicitacao['cliente']['nome'],
        );
      }

      print("Outro usuário: ${_outroUsuario!.fullName} (${_outroUsuario!.id})");

      await _registrarUsuarios();

      await _obterOuCriarRoom();

      _escutarMensagens();

      _escutarIndicadorDigitacao();

      _isLoading = false;
      onLoadingChanged?.call(false);
      onUpdateUI?.call();

      print("Chat inicializado com sucesso!");
      print("======================================");

    } catch (e) {
      _isLoading = false;
      onLoadingChanged?.call(false);
      onError?.call("Erro ao inicializar chat: $e");
      print("Erro ao inicializar chat: $e");
    }
  }

  ChatUser _criarUsuario({required String cpf, required String nome}) {
    List<String> partesNome = nome.trim().split(' ');
    String firstName = partesNome.isNotEmpty ? partesNome[0] : nome;
    String lastName = partesNome.length > 1 ? partesNome.skip(1).join(' ') : '';

    return ChatUser(
      id: cpf,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<void> _registrarUsuarios() async {
    try {
      await _ref.child('chat/users/${_usuarioAtual!.id}').set(_usuarioAtual!.toMap());
      print("Usuário atual registrado: ${_usuarioAtual!.firstName}");

      await _ref.child('chat/users/${_outroUsuario!.id}').set(_outroUsuario!.toMap());
      print("Outro usuário registrado: ${_outroUsuario!.firstName}");

    } catch (e) {
      print("Erro ao registrar usuários: $e");
    }
  }

  Future<void> _obterOuCriarRoom() async {
    try {
      print("=== OBTENDO/CRIANDO ROOM ===");

      final snapshot = await _ref.child('chat/rooms/$_roomId').get();

      if (snapshot.exists) {
        final roomData = Map<String, dynamic>.from(snapshot.value as Map);
        _room = ChatRoom.fromMap(_roomId!, roomData);
        print("Room existente encontrada: ${_room!.name}");
      } else {
        _room = ChatRoom(
          id: _roomId!,
          name: "Solicitação: ${_solicitacao!['titulo']}",
          userIds: [_usuarioAtual!.id, _outroUsuario!.id],
          createdAt: DateTime.now(),
        );

        await _ref.child('chat/rooms/$_roomId').set(_room!.toMap());
        print("Nova Room criada: ${_room!.name}");
      }

      print("==========================");
    } catch (e) {
      print("Erro ao obter/criar Room: $e");
      throw Exception("Erro ao criar conversa: $e");
    }
  }

  void _escutarMensagens() {
    if (_roomId != null) {
      _ref.child('chat/messages/$_roomId').orderByChild('createdAt').onValue.listen(
            (event) {
          if (event.snapshot.exists) {
            final messagesData = Map<String, dynamic>.from(event.snapshot.value as Map);

            _messages = messagesData.entries
                .map((entry) {
              final messageData = Map<String, dynamic>.from(entry.value as Map);
              return ChatMessage.fromMap(messageData);
            })
                .toList();

            _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            _marcarMensagensComoLidas();

            print("Mensagens carregadas: ${_messages.length}");
            onMessagesChanged?.call(_messages);
            onUpdateUI?.call();
          } else {
            _messages = [];
            onMessagesChanged?.call(_messages);
            onUpdateUI?.call();
          }
        },
        onError: (error) {
          print("Erro ao escutar mensagens: $error");
          onError?.call("Erro ao carregar mensagens");
        },
      );
    }
  }

  void _escutarIndicadorDigitacao() {
    if (_roomId != null && _outroUsuario != null) {
      _ref.child('chat/typing/$_roomId/${_outroUsuario!.id}').onValue.listen(
            (event) {
          final isTyping = event.snapshot.value == true;
          if (_outroUsuarioDigitando != isTyping) {
            _outroUsuarioDigitando = isTyping;
            onTypingChanged?.call(isTyping);
            onUpdateUI?.call();
          }
        },
        onError: (error) {
          print("Erro ao escutar indicador de digitação: $error");
        },
      );
    }
  }

  Future<void> _marcarMensagensComoLidas() async {
    if (_roomId == null || _usuarioAtual == null) return;

    try {
      final mensagensNaoLidas = _messages.where((msg) =>
      msg.authorId != _usuarioAtual!.id && msg.status != 'read'
      ).toList();

      for (final message in mensagensNaoLidas) {
        await _ref.child('chat/messages/$_roomId/${message.id}').update({
          'status': 'read'
        });
      }
    } catch (e) {
      print("Erro ao marcar mensagens como lidas: $e");
    }
  }

  Future<void> enviarMensagem(String texto) async {
    if (_roomId == null || texto.trim().isEmpty || _usuarioAtual == null) return;

    try {
      final messageId = _ref.child('chat/messages/$_roomId').push().key;
      if (messageId == null) return;

      final agora = DateTime.now().toUtc();

      final message = ChatMessage(
        id: messageId,
        text: texto.trim(),
        authorId: _usuarioAtual!.id,
        createdAt: agora,
        status: 'sending',
      );

      pararDigitacao();

      await _ref.child('chat/messages/$_roomId/$messageId').set(message.toMap());

      await _ref.child('chat/messages/$_roomId/$messageId').update({
        'status': 'sent'
      });

      await _ref.child('chat/rooms/$_roomId').update({
        'lastMessage': texto.trim(),
        'lastMessageTime': agora.millisecondsSinceEpoch,
      });

      print("Mensagem enviada: $texto");

    } catch (e) {
      print("Erro ao enviar mensagem: $e");
      onError?.call("Erro ao enviar mensagem");
    }
  }

  void indicarDigitacao() {
    if (_roomId != null && _usuarioAtual != null) {
      _ref.child('chat/typing/$_roomId/${_usuarioAtual!.id}').set(true);

      _typingTimer?.cancel();

      _typingTimer = Timer(Duration(seconds: 3), () {
        pararDigitacao();
      });
    }
  }

  void pararDigitacao() {
    if (_roomId != null && _usuarioAtual != null) {
      _ref.child('chat/typing/$_roomId/${_usuarioAtual!.id}').set(false);
      _typingTimer?.cancel();
    }
  }

  String get tituloChat {
    if (_outroUsuario != null) {
      return _outroUsuario!.fullName;
    }
    return "Chat";
  }

  String get subtituloChat {
    if (_solicitacao != null) {
      return "Sobre: ${_solicitacao!['servico']?['nome'] ?? 'Serviço'}";
    }
    return "";
  }

  void dispose() {
    _messages.clear();
    _room = null;
    _usuarioAtual = null;
    _outroUsuario = null;
    _solicitacao = null;
    _roomId = null;
    _typingTimer?.cancel();
  }
}