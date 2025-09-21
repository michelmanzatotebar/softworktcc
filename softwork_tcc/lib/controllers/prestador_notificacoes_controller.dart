import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../controllers/notificacao_controller.dart';

class PrestadorNotificacoesController {
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

  Future<void> iniciarListenerNotificacoes(String prestadorCpfCnpj) async {
    try {
      print("=== INICIANDO LISTENER DE NOTIFICAÇÕES ===");
      print("Prestador: $prestadorCpfCnpj");

      await _cancelarListener();

      _notificacoesSubscription = _ref
          .child('usuarios/$prestadorCpfCnpj/notificacoes')
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
                await _verificarSeENovaNotificacao(maisRecente, prestadorCpfCnpj);
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

      print("Listener de notificações iniciado com sucesso!");

    } catch (e) {
      print("Erro ao inicializar listener de notificações: $e");
      onError?.call("Erro ao carregar notificações");
    }
  }

  DateTime? _ultimaNotificacaoMostrada;

  Future<void> _verificarSeENovaNotificacao(Map<String, dynamic> notificacao, String prestadorCpfCnpj) async {
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

        // NOVO: Marcar como lida após mostrar notificação local
        await marcarNotificacaoComoLida(prestadorCpfCnpj, notificacao['id']);

        print("🔔 Nova notificação detectada, mostrada e marcada como lida!");
      }
    } catch (e) {
      print("Erro ao verificar nova notificação: $e");
    }
  }

  Future<void> marcarNotificacaoComoLida(String prestadorCpfCnpj, String notificacaoId) async {
    try {
      await _ref.child('usuarios/$prestadorCpfCnpj/notificacoes/$notificacaoId').update({
        'lida': true,
      });
      print("Notificação marcada como lida: $notificacaoId");
    } catch (e) {
      print("Erro ao marcar notificação como lida: $e");
    }
  }

  Future<void> marcarTodasComoLidas(String prestadorCpfCnpj) async {
    try {
      final snapshot = await _ref.child('usuarios/$prestadorCpfCnpj/notificacoes').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> notificacoes = snapshot.value as Map<dynamic, dynamic>;

        Map<String, dynamic> updates = {};
        notificacoes.forEach((key, value) {
          if (value['lida'] == false) {
            updates['$key/lida'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await _ref.child('usuarios/$prestadorCpfCnpj/notificacoes').update(updates);
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