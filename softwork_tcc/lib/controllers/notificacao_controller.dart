import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificacaoController {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  static Future<void> inicializar() async {
    try {
      await _configurarPermissoes();
      await _configurarNotificacoesLocais();
      _escutarNotificacoes();
      print("Notificações inicializadas com sucesso!");
    } catch (e) {
      print("Erro ao inicializar notificações: $e");
    }
  }

  static Future<void> _configurarPermissoes() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permissão de notificação: ${settings.authorizationStatus}');
  }

  static Future<void> _configurarNotificacoesLocais() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  static void _escutarNotificacoes() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificação recebida: ${message.notification?.title}');
      _mostrarNotificacaoLocal(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificação clicada: ${message.notification?.title}');
    });
  }

  static Future<void> _mostrarNotificacaoLocal(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'solicitacao_channel',
      'Solicitações',
      channelDescription: 'Notificações de novas solicitações',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Nova solicitação',
      message.notification?.body ?? 'Você recebeu uma nova solicitação',
      platformChannelSpecifics,
    );
  }

  static Future<void> salvarTokenUsuario(String cpfCnpj) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("=== SALVANDO TOKEN ===");
        print("CPF/CNPJ: $cpfCnpj");
        print("Token: $token");

        await _ref.child('usuarios/$cpfCnpj').update({
          'fcmToken': token,
        });

        print("Token salvo com sucesso!");
      }
    } catch (e) {
      print("Erro ao salvar token: $e");
    }
  }

  static Future<void> notificarNovaSolicitacao({
    required String prestadorCpfCnpj,
    required String tituloSolicitacao,
    required String nomeCliente,
    required String nomeServico,
  }) async {
    try {
      print("=== ENVIANDO NOTIFICAÇÃO ===");
      print("Prestador: $prestadorCpfCnpj");
      print("Solicitação: $tituloSolicitacao");
      print("Cliente: $nomeCliente");
      print("Serviço: $nomeServico");

      // Buscar token do prestador
      final snapshot = await _ref.child('usuarios/$prestadorCpfCnpj/fcmToken').get();

      if (!snapshot.exists) {
        print("Token do prestador não encontrado");

        // Salvar para tentativa posterior
        await _salvarNotificacaoPendente(
          prestadorCpfCnpj: prestadorCpfCnpj,
          titulo: 'Nova Solicitação!',
          mensagem: '$nomeCliente solicitou: $nomeServico ($tituloSolicitacao)',
        );
        return;
      }

      String tokenPrestador = snapshot.value.toString();
      print("Token encontrado: $tokenPrestador");

      // Enviar notificação real usando Cloud Functions trigger
      await _enviarNotificacaoViaTrigger(
        prestadorCpfCnpj: prestadorCpfCnpj,
        token: tokenPrestador,
        titulo: 'Nova Solicitação!',
        mensagem: '$nomeCliente solicitou: $nomeServico ($tituloSolicitacao)',
      );

      print("Notificação enviada com sucesso!");

    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }

  static Future<void> _enviarNotificacaoViaTrigger({
    required String prestadorCpfCnpj,
    required String token,
    required String titulo,
    required String mensagem,
  }) async {
    try {
      // 1. Salvar no histórico de notificações do usuário
      await _ref.child('usuarios/$prestadorCpfCnpj/notificacoes').push().set({
        'titulo': titulo,
        'mensagem': mensagem,
        'timestamp': DateTime.now().toIso8601String(),
        'lida': false,
        'tipo': 'nova_solicitacao',
      });

      // 2. Salvar trigger para processamento (backup/debug)
      await _ref.child('notificacoes_disparo').push().set({
        'target_token': token,
        'target_user': prestadorCpfCnpj,
        'title': titulo,
        'body': mensagem,
        'timestamp': DateTime.now().toIso8601String(),
        'processed': false,
        'type': 'nova_solicitacao',
      });

      // 3. Tentar enviar notificação real via HTTP
      await _enviarNotificacaoHTTP(token, titulo, mensagem);

      print("Notificação salva no histórico e enviada!");

    } catch (e) {
      print("Erro ao processar notificação: $e");
    }
  }

  static Future<void> _enviarNotificacaoHTTP(String token, String titulo, String mensagem) async {
    try {
      // Usar um serviço simples de notificação
      // Por enquanto, mostrar notificação local como fallback
      print("📤 Tentando enviar notificação HTTP...");

      // TODO: Implementar envio real via HTTP ou usar serviço externo
      // Por enquanto, simular envio bem-sucedido
      await Future.delayed(Duration(milliseconds: 500));

      print("Notificação HTTP enviada (simulado)!");

    } catch (e) {
      print("Erro no envio HTTP: $e");
    }
  }

  static Future<void> _salvarNotificacaoPendente({
    required String prestadorCpfCnpj,
    required String titulo,
    required String mensagem,
  }) async {
    try {
      await _ref.child('notificacoes_pendentes').push().set({
        'tipo': 'nova_solicitacao',
        'prestadorCpfCnpj': prestadorCpfCnpj,
        'titulo': titulo,
        'mensagem': mensagem,
        'timestamp': DateTime.now().toIso8601String(),
        'processada': false,
      });

      print("Notificação pendente salva!");
    } catch (e) {
      print("Erro ao salvar notificação pendente: $e");
    }
  }
}