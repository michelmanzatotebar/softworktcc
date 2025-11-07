import 'package:firebase_database/firebase_database.dart';

class ClienteComunidadeController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Function(bool)? _loadingCallback;
  Function(List<Map<String, dynamic>>)? _solicitacoesFinalizadasCallback;
  Function(List<Map<String, dynamic>>)? _minhasAvaliacoesCallback;
  Function(List<Map<String, dynamic>>)? _avaliacoesComunidadeCallback;
  Function(String, bool)? _messageCallback;
  Function(List<String>)? _solicitacoesAvaliadasCallback;
  Function(List<Map<String, dynamic>>)? _minhasSugestoesCallback;
  Function(List<Map<String, dynamic>>)? _sugestoesComunidadeCallback;
  Function(List<Map<String, dynamic>>)? _minhasDuvidasCallback;
  Function(List<Map<String, dynamic>>)? _duvidasComunidadeCallback;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? solicitacoesFinalizadasCallback,
    Function(List<Map<String, dynamic>>)? minhasAvaliacoesCallback,
    Function(List<Map<String, dynamic>>)? avaliacoesComunidadeCallback,
    Function(String, bool)? messageCallback,
    Function(List<String>)? solicitacoesAvaliadasCallback,
    Function(List<Map<String, dynamic>>)? minhasSugestoesCallback,
    Function(List<Map<String, dynamic>>)? sugestoesComunidadeCallback,
    Function(List<Map<String, dynamic>>)? minhasDuvidasCallback,
    Function(List<Map<String, dynamic>>)? duvidasComunidadeCallback,
  }) {
    _loadingCallback = loadingCallback;
    _solicitacoesFinalizadasCallback = solicitacoesFinalizadasCallback;
    _minhasAvaliacoesCallback = minhasAvaliacoesCallback;
    _avaliacoesComunidadeCallback = avaliacoesComunidadeCallback;
    _messageCallback = messageCallback;
    _solicitacoesAvaliadasCallback = solicitacoesAvaliadasCallback;
    _minhasSugestoesCallback = minhasSugestoesCallback;
    _sugestoesComunidadeCallback = sugestoesComunidadeCallback;
    _minhasDuvidasCallback = minhasDuvidasCallback;
    _duvidasComunidadeCallback = duvidasComunidadeCallback;
  }
// Carrega solicitações finalizadas do cliente para avaliação
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
// Carrega avaliações criadas pelo cliente
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
// Cria nova avaliação para um prestador
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

  void carregarMinhasSugestoes(String clienteCpfCnpj) {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> minhasSugestoes = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Sugestao' &&
              item['cliente']?['cpfCnpj'] == clienteCpfCnpj) {
            minhasSugestoes.add(item);
          }
        });

        _minhasSugestoesCallback?.call(minhasSugestoes);
      } else {
        _minhasSugestoesCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  void carregarSugestoesComunidade() {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> sugestoesComunidade = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Sugestao') {
            sugestoesComunidade.add(item);
          }
        });

        _sugestoesComunidadeCallback?.call(sugestoesComunidade);
      } else {
        _sugestoesComunidadeCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  void carregarMinhasDuvidas(String clienteCpfCnpj) {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> minhasDuvidas = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Duvida' &&
              item['cliente']?['cpfCnpj'] == clienteCpfCnpj) {
            minhasDuvidas.add(item);
          }
        });

        _minhasDuvidasCallback?.call(minhasDuvidas);
      } else {
        _minhasDuvidasCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }

  void carregarDuvidasComunidade() {
    _loadingCallback?.call(true);

    _ref.child('avaliacao').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> duvidasComunidade = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;

          if (item['categoria'] == 'Duvida') {
            duvidasComunidade.add(item);
          }
        });

        _duvidasComunidadeCallback?.call(duvidasComunidade);
      } else {
        _duvidasComunidadeCallback?.call([]);
      }
      _loadingCallback?.call(false);
    });
  }
// Cria nova sugestão na comunidade
  Future<void> salvarSugestao({
    required String clienteNome,
    required String clienteCpfCnpj,
    required String categoria,
    required String titulo,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      final sugestaoRef = _ref.child('avaliacao').push();

      Map<String, dynamic> sugestaoData = {
        'id': sugestaoRef.key,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': 'Sugestao',
        'categoriaServico': categoria,
        'cliente': {
          'nome': clienteNome,
          'cpfCnpj': clienteCpfCnpj,
        },
      };

      await sugestaoRef.set(sugestaoData);

      _messageCallback?.call('Sugestão enviada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao enviar sugestão: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }
// Cria nova dúvida na comunidade
  Future<void> salvarDuvida({
    required String clienteNome,
    required String clienteCpfCnpj,
    required String categoria,
    required String titulo,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      final duvidaRef = _ref.child('avaliacao').push();

      Map<String, dynamic> duvidaData = {
        'id': duvidaRef.key,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': 'Duvida',
        'categoriaServico': categoria,
        'cliente': {
          'nome': clienteNome,
          'cpfCnpj': clienteCpfCnpj,
        },
      };

      await duvidaRef.set(duvidaData);

      _messageCallback?.call('Dúvida enviada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao enviar dúvida: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> atualizarAvaliacao({
    required String avaliacaoId,
    required double nota,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$avaliacaoId').update({
        'nota': nota,
        'descricao': descricao,
      });

      _messageCallback?.call('Avaliação atualizada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao atualizar avaliação: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> excluirAvaliacao(String avaliacaoId) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$avaliacaoId').remove();

      _messageCallback?.call('Avaliação excluída com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao excluir avaliação: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> atualizarSugestao({
    required String sugestaoId,
    required String categoria,
    required String titulo,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$sugestaoId').update({
        'categoriaServico': categoria,
        'titulo': titulo,
        'descricao': descricao,
      });

      _messageCallback?.call('Sugestão atualizada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao atualizar sugestão: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> excluirSugestao(String sugestaoId) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$sugestaoId').remove();

      _messageCallback?.call('Sugestão excluída com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao excluir sugestão: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> atualizarDuvida({
    required String duvidaId,
    required String categoria,
    required String titulo,
    required String descricao,
  }) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$duvidaId').update({
        'categoriaServico': categoria,
        'titulo': titulo,
        'descricao': descricao,
      });

      _messageCallback?.call('Dúvida atualizada com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao atualizar dúvida: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }

  Future<void> excluirDuvida(String duvidaId) async {
    try {
      _loadingCallback?.call(true);

      await _ref.child('avaliacao/$duvidaId').remove();

      _messageCallback?.call('Dúvida excluída com sucesso!', true);
      _loadingCallback?.call(false);
    } catch (e) {
      _messageCallback?.call('Erro ao excluir dúvida: ${e.toString()}', false);
      _loadingCallback?.call(false);
    }
  }
}