import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class PrestadorComunidadeController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  StreamSubscription? _avaliacoesSubscription;
  StreamSubscription? _duvidasSubscription;
  StreamSubscription? _sugestoesSubscription;

  Function(List<Map<String, dynamic>>)? onAvaliacoesChanged;
  Function(List<Map<String, dynamic>>)? onDuvidasChanged;
  Function(List<Map<String, dynamic>>)? onSugestoesChanged;

  void setCallbacks({
    Function(List<Map<String, dynamic>>)? avaliacoesCallback,
    Function(List<Map<String, dynamic>>)? duvidasCallback,
    Function(List<Map<String, dynamic>>)? sugestoesCallback,
  }) {
    onAvaliacoesChanged = avaliacoesCallback;
    onDuvidasChanged = duvidasCallback;
    onSugestoesChanged = sugestoesCallback;
  }

  void buscarAvaliacoesPrestador(String prestadorCpfCnpj) {
    _avaliacoesSubscription?.cancel();

    _avaliacoesSubscription = _database.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> avaliacoes = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Avaliacao' && item['prestador'] != null) {
            Map<String, dynamic> prestador = Map<String, dynamic>.from(item['prestador'] as Map);

            if (prestador['cpfCnpj'] == prestadorCpfCnpj) {
              avaliacoes.add(item);
            }
          }
        });

        avaliacoes.sort((a, b) {
          DateTime dataA = DateTime.tryParse(a['dataCriacao']?.toString() ?? '') ?? DateTime.now();
          DateTime dataB = DateTime.tryParse(b['dataCriacao']?.toString() ?? '') ?? DateTime.now();
          return dataB.compareTo(dataA);
        });

        onAvaliacoesChanged?.call(avaliacoes);
      } else {
        onAvaliacoesChanged?.call([]);
      }
    });
  }

  void buscarDuvidasPorCategorias(String prestadorCpfCnpj) async {
    try {
      final servicosSnapshot = await _database.child('servicos').get();

      Set<String> categoriasPrestador = {};

      if (servicosSnapshot.exists) {
        Map<dynamic, dynamic> servicosData = servicosSnapshot.value as Map<dynamic, dynamic>;

        servicosData.forEach((key, value) {
          Map<String, dynamic> servico = Map<String, dynamic>.from(value);

          if (servico['prestador'] != null) {
            Map<String, dynamic> prestador = Map<String, dynamic>.from(servico['prestador'] as Map);

            if (prestador['cpfCnpj'] == prestadorCpfCnpj && servico['categoria'] != null) {
              categoriasPrestador.add(servico['categoria'].toString());
            }
          }
        });
      }

      _duvidasSubscription?.cancel();

      _duvidasSubscription = _database.child('avaliacao').onValue.listen((event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> duvidasData = event.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> duvidas = [];

          duvidasData.forEach((key, value) {
            Map<String, dynamic> item = Map<String, dynamic>.from(value);
            item['id'] = key;

            if (item['categoria'] == 'Duvida') {
              String categoriaDuvida = item['categoriaServico']?.toString() ?? '';

              if (categoriasPrestador.contains(categoriaDuvida)) {
                if (item['cliente'] != null) {
                  Map<String, dynamic> cliente = Map<String, dynamic>.from(item['cliente'] as Map);
                  item['clienteNome'] = cliente['nome'] ?? 'Cliente';
                }

                duvidas.add(item);
              }
            }
          });

          duvidas.sort((a, b) {
            String statusA = a['status']?.toString() ?? 'pendente';
            String statusB = b['status']?.toString() ?? 'pendente';

            if (statusA == 'pendente' && statusB != 'pendente') return -1;
            if (statusA != 'pendente' && statusB == 'pendente') return 1;

            DateTime dataA = DateTime.tryParse(a['dataCriacao']?.toString() ?? '') ?? DateTime.now();
            DateTime dataB = DateTime.tryParse(b['dataCriacao']?.toString() ?? '') ?? DateTime.now();
            return dataB.compareTo(dataA);
          });

          onDuvidasChanged?.call(duvidas);
        } else {
          onDuvidasChanged?.call([]);
        }
      });
    } catch (e) {
      onDuvidasChanged?.call([]);
      print('Erro ao buscar dúvidas: $e');
    }
  }

  void buscarSugestoesComunidade() {
    _sugestoesSubscription?.cancel();

    _sugestoesSubscription = _database.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> sugestoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> sugestoes = [];

        sugestoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Sugestao') {
            if (item['cliente'] != null) {
              Map<String, dynamic> cliente = Map<String, dynamic>.from(item['cliente'] as Map);
              item['clienteNome'] = cliente['nome'] ?? 'Cliente';
            }

            item['categoria'] = item['categoriaServico'] ?? '';
            sugestoes.add(item);
          }
        });

        sugestoes.sort((a, b) {
          DateTime dataA = DateTime.tryParse(a['dataCriacao']?.toString() ?? '') ?? DateTime.now();
          DateTime dataB = DateTime.tryParse(b['dataCriacao']?.toString() ?? '') ?? DateTime.now();
          return dataB.compareTo(dataA);
        });

        onSugestoesChanged?.call(sugestoes);
      } else {
        onSugestoesChanged?.call([]);
      }
    });
  }

  Future<void> responderDuvida(String duvidaId, String resposta, String prestadorCpfCnpj) async {
    try {
      await _database.child('avaliacao').child(duvidaId).update({
        'resposta': resposta,
        'status': 'respondida',
        'prestadorResponsavel': prestadorCpfCnpj,
        'dataResposta': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao responder dúvida: $e');
    }
  }

  Future<void> editarRespostaDuvida(String duvidaId, String novaResposta) async {
    try {
      await _database.child('avaliacao').child(duvidaId).update({
        'resposta': novaResposta,
        'dataResposta': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao editar resposta: $e');
    }
  }

  Future<void> excluirRespostaDuvida(String duvidaId) async {
    try {
      await _database.child('avaliacao').child(duvidaId).update({
        'resposta': null,
        'status': 'pendente',
        'prestadorResponsavel': null,
        'dataResposta': null,
      });
    } catch (e) {
      throw Exception('Erro ao excluir resposta: $e');
    }
  }

  void dispose() {
    _avaliacoesSubscription?.cancel();
    _duvidasSubscription?.cancel();
    _sugestoesSubscription?.cancel();
  }
}