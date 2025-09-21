import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static Future<void> mostrarNotificacaoLocal({
    required String titulo,
    required String mensagem
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'solicitacao_channel',
        'Solicitações',
        channelDescription: 'Notificações de novas solicitações',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        titulo,
        mensagem,
        platformDetails,
      );

      print("✅ Notificação local mostrada: $titulo");
    } catch (e) {
      print("Erro ao mostrar notificação local: $e");
    }
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

      // Salvar notificação no histórico do prestador
      await _salvarNotificacaoNoHistorico(
        prestadorCpfCnpj: prestadorCpfCnpj,
        titulo: 'Nova Solicitação!',
        mensagem: '$nomeCliente solicitou: $nomeServico ($tituloSolicitacao)',
      );

      print("Notificação salva com sucesso!");

    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }

  static Future<void> _salvarNotificacaoNoHistorico({
    required String prestadorCpfCnpj,
    required String titulo,
    required String mensagem,
  }) async {
    try {
      await _ref.child('usuarios/$prestadorCpfCnpj/notificacoes').push().set({
        'titulo': titulo,
        'mensagem': mensagem,
        'timestamp': DateTime.now().toIso8601String(),
        'lida': false,
        'tipo': 'nova_solicitacao',
      });

      print("Notificação salva no histórico do prestador!");
    } catch (e) {
      print("Erro ao salvar notificação no histórico: $e");
    }
  }
}