import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_models.dart';

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

  Function(bool)? onLoadingChanged;
  Function(List<ChatMessage>)? onMessagesChanged;
  Function(String)? onError;
  Function()? onUpdateUI;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<ChatMessage>)? messagesCallback,
    Function(String)? errorCallback,
    Function()? updateUICallback,
  }) {
    onLoadingChanged = loadingCallback;
    onMessagesChanged = messagesCallback;
    onError = errorCallback;
    onUpdateUI = updateUICallback;
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

      // Criar usuário atual
      _usuarioAtual = _criarUsuario(
        cpf: cpfUsuarioAtual,
        nome: nomeUsuarioAtual,
      );

      // Criar outro usuário
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

      // Registrar usuários no Realtime Database
      await _registrarUsuarios();

      // Obter ou criar Room
      await _obterOuCriarRoom();

      // Escutar mensagens
      _escutarMensagens();

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
      // Registrar usuário atual
      await _ref.child('chat/users/${_usuarioAtual!.id}').set(_usuarioAtual!.toMap());
      print("Usuário atual registrado: ${_usuarioAtual!.firstName}");

      // Registrar outro usuário
      await _ref.child('chat/users/${_outroUsuario!.id}').set(_outroUsuario!.toMap());
      print("Outro usuário registrado: ${_outroUsuario!.firstName}");

    } catch (e) {
      print("Erro ao registrar usuários: $e");
    }
  }

  Future<void> _obterOuCriarRoom() async {
    try {
      print("=== OBTENDO/CRIANDO ROOM ===");

      // Verificar se Room já existe
      final snapshot = await _ref.child('chat/rooms/$_roomId').get();

      if (snapshot.exists) {
        // Room já existe
        final roomData = Map<String, dynamic>.from(snapshot.value as Map);
        _room = ChatRoom.fromMap(_roomId!, roomData);
        print("Room existente encontrada: ${_room!.name}");
      } else {
        // Criar nova Room
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

            // Ordenar por data (mais antigas primeiro)
            _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

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

  Future<void> enviarMensagem(String texto) async {
    if (_roomId == null || texto.trim().isEmpty || _usuarioAtual == null) return;

    try {
      final messageId = _ref.child('chat/messages/$_roomId').push().key!;

      final message = ChatMessage(
        id: messageId,
        text: texto.trim(),
        authorId: _usuarioAtual!.id,
        createdAt: DateTime.now(),
      );

      await _ref.child('chat/messages/$_roomId/$messageId').set(message.toMap());

      // Atualizar última mensagem na Room
      await _ref.child('chat/rooms/$_roomId').update({
        'lastMessage': texto.trim(),
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });

      print("Mensagem enviada: $texto");

    } catch (e) {
      print("Erro ao enviar mensagem: $e");
      onError?.call("Erro ao enviar mensagem");
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
  }
}