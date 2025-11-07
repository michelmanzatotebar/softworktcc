import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificacoesPrestadorController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  StreamSubscription? _notificacoesSubscription;

  Function(bool)? onLoadingChanged;
  Function(List<Map<String, dynamic>>)? onNotificacoesChanged;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? notificacoesCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onNotificacoesChanged = notificacoesCallback;
    onError = errorCallback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(_isLoading);
  }
//carrega notificacoes do prestador
  Future<void> carregarNotificacoesPrestador(String prestadorCpfCnpj) async {
    try {
      _setLoading(true);

      await _cancelarListener();

      _notificacoesSubscription = _ref
          .child('usuarios/$prestadorCpfCnpj/notificacoes')
          .orderByChild('timestamp')
          .onValue
          .listen(
            (event) {
          try {
            if (event.snapshot.exists) {
              Map<dynamic, dynamic> notificacoesData = event.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> notificacoes = [];

              notificacoesData.forEach((key, value) {
                Map<String, dynamic> notificacao = Map<String, dynamic>.from(value);
                notificacao['id'] = key;
                notificacoes.add(notificacao);
              });

              // Ordenar por data (mais recente primeiro)
              notificacoes.sort((a, b) {
                DateTime dataA = DateTime.parse(a['timestamp']);
                DateTime dataB = DateTime.parse(b['timestamp']);
                return dataB.compareTo(dataA);
              });

              onNotificacoesChanged?.call(notificacoes);
              print("Notificações carregadas: ${notificacoes.length}");

            } else {
              onNotificacoesChanged?.call([]);
              print("Nenhuma notificação encontrada");
            }

            if (_isLoading) {
              _setLoading(false);
            }
          } catch (e) {
            print("Erro ao processar notificações: $e");
            if (_isLoading) {
              _setLoading(false);
            }
            onError?.call("Erro ao carregar notificações");
          }
        },
        onError: (error) {
          print("Erro no listener de notificações: $error");
          if (_isLoading) {
            _setLoading(false);
          }
          onError?.call("Erro ao escutar notificações");
        },
      );

    } catch (e) {
      print("Erro ao inicializar listener de notificações: $e");
      _setLoading(false);
      onError?.call("Erro ao carregar notificações");
    }
  }

  Future<void> _cancelarListener() async {
    if (_notificacoesSubscription != null) {
      await _notificacoesSubscription!.cancel();
      _notificacoesSubscription = null;
    }
  }
//apos abrir determina como lida
  Future<void> marcarTodasComoLidas(String prestadorCpfCnpj) async {
    try {
      _setLoading(true);

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
      onError?.call("Erro ao marcar notificações como lidas");
    } finally {
      _setLoading(false);
    }
  }

  String formatarData(String dataISO) {
    try {
      DateTime data = DateTime.parse(dataISO);
      DateTime agora = DateTime.now();

      Duration diferenca = agora.difference(data);

      if (diferenca.inMinutes < 1) {
        return 'Agora';
      } else if (diferenca.inHours < 1) {
        return '${diferenca.inMinutes} min atrás';
      } else if (diferenca.inDays < 1) {
        return '${diferenca.inHours} horas atrás';
      } else if (diferenca.inDays == 1) {
        return 'Ontem';
      } else if (diferenca.inDays < 7) {
        return '${diferenca.inDays} dias atrás';
      } else {
        return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      }
    } catch (e) {
      return 'Data inválida';
    }
  }

  String getTipoNotificacao(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'nova_solicitacao':
        return 'Nova Solicitação';
      case 'solicitacao_aceita':
        return 'Solicitação Aceita';
      case 'solicitacao_concluida':
        return 'Solicitação Concluída';
      default:
        return 'Notificação';
    }
  }
//definir cor do staus
  Color getCorTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'nova_solicitacao':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void dispose() {
    _cancelarListener();
  }
}