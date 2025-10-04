import 'package:firebase_database/firebase_database.dart';

class ClienteComunidadeController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Function(bool)? _loadingCallback;
  Function(List<Map<String, dynamic>>)? _solicitacoesFinalizadasCallback;
  Function(List<Map<String, dynamic>>)? _minhasAvaliacoesCallback;
  Function(List<Map<String, dynamic>>)? _avaliacoesComunidadeCallback;
  Function(String, bool)? _messageCallback;
  Function(List<String>)? _solicitacoesAvaliadasCallback;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? solicitacoesFinalizadasCallback,
    Function(List<Map<String, dynamic>>)? minhasAvaliacoesCallback,
    Function(List<Map<String, dynamic>>)? avaliacoesComunidadeCallback,
    Function(String, bool)? messageCallback,
    Function(List<String>)? solicitacoesAvaliadasCallback,
  }) {
    _loadingCallback = loadingCallback;
    _solicitacoesFinalizadasCallback = solicitacoesFinalizadasCallback;
    _minhasAvaliacoesCallback = minhasAvaliacoesCallback;
    _avaliacoesComunidadeCallback = avaliacoesComunidadeCallback;
    _messageCallback = messageCallback;
    _solicitacoesAvaliadasCallback = solicitacoesAvaliadasCallback;
  }

  void carregarSolicitacoesFinalizadas(String clienteCpfCnpj) {
    _loadingCallback?.call(true);

    _ref.child('solicitacoes').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> solicitacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> solicitacoesFinalizadas = [];

        solicitacoesData.forEach((key, value) {
          Map<String, dynamic> solicitacao = Map<String, dynamic>.from(value);
          solicitacao['id'] = key;

          if (solicitacao['statusSolicitacao'] == 'Finalizado' &&
              solicitacao['cliente']?['cpfCnpj'] == clienteCpfCnpj) {
            solicitacoesFinalizadas.add(solicitacao);
          }
        });

        _solicitacoesFinalizadasCallback?.call(solicitacoesFinalizadas);
      } else {
        _solicitacoesFinalizadasCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  void carregarMinhasAvaliacoes(String clienteCpfCnpj) {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> minhasAvaliacoes = [];
        List<String> solicitacoesAvaliadas = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> avaliacao = Map<String, dynamic>.from(value);
          avaliacao['id'] = key;

          if (avaliacao['categoria'] == 'Avaliacao' &&
              avaliacao['cliente']?['cpfCnpj'] == clienteCpfCnpj) {
            minhasAvaliacoes.add(avaliacao);

            String? solicitacaoId = avaliacao['solicitacaoId']?.toString();
            if (solicitacaoId != null && solicitacaoId.isNotEmpty) {
              solicitacoesAvaliadas.add(solicitacaoId);
              print('Solicitação avaliada encontrada: $solicitacaoId');
            }
          }
        });

        print('Total de solicitações avaliadas: ${solicitacoesAvaliadas.length}');
        print('IDs: $solicitacoesAvaliadas');

        _minhasAvaliacoesCallback?.call(minhasAvaliacoes);
        _solicitacoesAvaliadasCallback?.call(solicitacoesAvaliadas);
      } else {
        _minhasAvaliacoesCallback?.call([]);
        _solicitacoesAvaliadasCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  void carregarAvaliacoesComunidade() {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> avaliacoesComunidade = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> avaliacao = Map<String, dynamic>.from(value);
          avaliacao['id'] = key;

          if (avaliacao['categoria'] == 'Avaliacao') {
            avaliacoesComunidade.add(avaliacao);
          }
        });

        _avaliacoesComunidadeCallback?.call(avaliacoesComunidade);
      } else {
        _avaliacoesComunidadeCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  Future<void> salvarAvaliacao({
    required Map<String, dynamic> solicitacao,
    required double nota,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      final avaliacaoRef = _ref.child('avaliacao').push();

      Map<String, dynamic> avaliacaoData = {
        'id': avaliacaoRef.key,
        'titulo': solicitacao['titulo'] ?? '',
        'descricao': descricao,
        'categoria': 'Avaliacao',
        'servico': solicitacao['servico'],
        'cliente': solicitacao['cliente'],
        'prestador': solicitacao['prestador'],
        'nota': nota,
        'tituloSolicitacao': solicitacao['titulo'] ?? '',
        'descricaoSolicitacao': solicitacao['descricao'] ?? '',
        'solicitacaoId': solicitacao['id'] ?? '',
      };

      await avaliacaoRef.set(avaliacaoData);

      _messageCallback?.call('Avaliação enviada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao enviar avaliação: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  void dispose() {
  }
}