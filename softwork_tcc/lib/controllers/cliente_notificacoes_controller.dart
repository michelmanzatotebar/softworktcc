import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../controllers/notificacao_controller.dart';

class ClienteNotificacoesController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  StreamSubscription? _notificacoesSubscription;

  Function(String)? onNovaNotificacao;
  Function(int)? onContadorChanged;
  Function(String)? onError;

  void setCallbacks({
    Function(String)? novaNotificacaoCallback,
    Function(int)? contadorCallback,
    Function(String)? errorCallback,
  }) {
    onNovaNotificacao = novaNotificacaoCallback;
    onContadorChanged = contadorCallback;
    onError = errorCallback;
  }
// Inicia escuta em tempo real das notificações do cliente
  Future<void> iniciarListenerNotificacoes(String clienteCpfCnpj) async {
    try {
      print("=== INICIANDO LISTENER DE NOTIFICAÇÕES DO CLIENTE ===");
      print("Cliente: $clienteCpfCnpj");

      await _cancelarListener();

      _notificacoesSubscription = _ref
          .child('usuarios/$clienteCpfCnpj/notificacoes')
          .orderByChild('timestamp')
          .onValue
          .listen(
            (event) async {
          try {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> notificacoesData = event.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> notificacoes = [];

              notificacoesData.forEach((key, value) {
                Map<String, dynamic> notificacao = Map<String, dynamic>.from(value);
                notificacao['id'] = key;
                notificacoes.add(notificacao);
              });

              notificacoes.sort((a, b) {
                DateTime dataA = DateTime.parse(a['timestamp']);
                DateTime dataB = DateTime.parse(b['timestamp']);
                return dataB.compareTo(dataA);
              });

              List<Map<String, dynamic>> naoLidas = notificacoes
                  .where((notif) => notif['lida'] == false)
                  .toList();

              onContadorChanged?.call(naoLidas.length);

              if (naoLidas.isNotEmpty) {
                Map<String, dynamic> maisRecente = naoLidas.first;
                await _verificarSeENovaNotificacao(maisRecente, clienteCpfCnpj);
              }

              print("Notificações processadas: ${notificacoes.length} total, ${naoLidas.length} não lidas");

            } else {
              onContadorChanged?.call(0);
              print("Nenhuma notificação encontrada");
            }
          } catch (e) {
            print("Erro ao processar notificações: $e");
            onError?.call("Erro ao carregar notificações");
          }
        },
        onError: (error) {
          print("Erro no listener de notificações: $error");
          onError?.call("Erro ao escutar notificações");
        },
      );

      print("Listener de notificações do cliente iniciado com sucesso!");

    } catch (e) {
      print("Erro ao inicializar listener de notificações: $e");
      onError?.call("Erro ao carregar notificações");
    }
  }

  DateTime? _ultimaNotificacaoMostrada;
// Verifica se notificação é nova e exibe notificação local
  Future<void> _verificarSeENovaNotificacao(Map<String, dynamic> notificacao, String clienteCpfCnpj) async {
    try {
      DateTime timestampNotificacao = DateTime.parse(notificacao['timestamp']);

      if (_ultimaNotificacaoMostrada == null ||
          timestampNotificacao.isAfter(_ultimaNotificacaoMostrada!)) {

        String mensagem = "${notificacao['titulo']} - ${notificacao['mensagem']}";

        await NotificacaoController.mostrarNotificacaoLocal(
          titulo: notificacao['titulo'] ?? 'Nova Notificação',
          mensagem: notificacao['mensagem'] ?? 'Você tem uma nova notificação',
        );

        onNovaNotificacao?.call(mensagem);
        _ultimaNotificacaoMostrada = timestampNotificacao;

        await marcarNotificacaoComoLida(clienteCpfCnpj, notificacao['id']);

        print("🔔 Nova notificação detectada, mostrada e marcada como lida!");
      }
    } catch (e) {
      print("Erro ao verificar nova notificação: $e");
    }
  }
// Marca notificação específica como lida no Firebase
  Future<void> marcarNotificacaoComoLida(String clienteCpfCnpj, String notificacaoId) async {
    try {
      await _ref.child('usuarios/$clienteCpfCnpj/notificacoes/$notificacaoId').update({
        'lida': true,
      });
      print("Notificação marcada como lida: $notificacaoId");
    } catch (e) {
      print("Erro ao marcar notificação como lida: $e");
    }
  }
// Marca todas as notificações não lidas como lidas
  Future<void> marcarTodasComoLidas(String clienteCpfCnpj) async {
    try {
      final snapshot = await _ref.child('usuarios/$clienteCpfCnpj/notificacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> notificacoes = snapshot.value as Map<dynamic, dynamic>;

        Map<String, dynamic> updates = {};
        notificacoes.forEach((key, value) {
          if (value['lida'] == false) {
            updates['$key/lida'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await _ref.child('usuarios/$clienteCpfCnpj/notificacoes').update(updates);
          print("Todas as notificações marcadas como lidas");
        }
      }
    } catch (e) {
      print("Erro ao marcar todas como lidas: $e");
    }
  }

  Future<void> _cancelarListener() async {
    if (_notificacoesSubscription != null) {
      await _notificacoesSubscription!.cancel();
      _notificacoesSubscription = null;
    }
  }

  void dispose() {
    _cancelarListener();
  }
}