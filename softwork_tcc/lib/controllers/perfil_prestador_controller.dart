import 'package:firebase_database/firebase_database.dart';

class PerfilPrestadorController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  bool isLoading = false;
  Map<String, dynamic>? dadosPrestador;
  List<Map<String, dynamic>> servicosPrestador = [];
  List<Map<String, dynamic>> avaliacoesPrestador = [];

  Function(bool)? onLoadingChanged;
  Function()? onDataLoaded;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function()? dataCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onDataLoaded = dataCallback;
    onError = errorCallback;
  }

  Future<void> carregarDadosPrestador(String cpfCnpj) async {
    try {
      isLoading = true;
      onLoadingChanged?.call(true);

      await _buscarDadosUsuario(cpfCnpj);
      await _buscarServicosPrestador(cpfCnpj);
      await _buscarAvaliacoesPrestador(cpfCnpj);

      isLoading = false;
      onLoadingChanged?.call(false);
      onDataLoaded?.call();
    } catch (e) {
      print("Erro ao carregar dados do prestador: $e");
      isLoading = false;
      onLoadingChanged?.call(false);
      onError?.call("Erro ao carregar dados do prestador");
    }
  }

  Future<void> _buscarDadosUsuario(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('usuarios/$cpfCnpj').get();

      if (snapshot.exists) {
        dadosPrestador = Map<String, dynamic>.from(snapshot.value as Map);
        dadosPrestador!['cpfCnpj'] = cpfCnpj;
        print("Dados do prestador carregados com sucesso");
      } else {
        print("Prestador não encontrado");
        dadosPrestador = null;
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      throw e;
    }
  }

  Future<void> _buscarServicosPrestador(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('servicos').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> servicosData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> servicosEncontrados = [];

        servicosData.forEach((key, value) {
          Map<String, dynamic> servico = Map<String, dynamic>.from(value);
          servico['id'] = key;

          if (servico['prestador'] != null &&
              servico['prestador']['cpfCnpj'].toString() == cpfCnpj) {
            servicosEncontrados.add(servico);
          }
        });

        servicosPrestador = servicosEncontrados;
        print("Serviços do prestador carregados: ${servicosPrestador.length}");
      } else {
        servicosPrestador = [];
        print("Nenhum serviço encontrado");
      }
    } catch (e) {
      print("Erro ao buscar serviços: $e");
      throw e;
    }
  }

  Future<void> _buscarAvaliacoesPrestador(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('avaliacao').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> avaliacoesData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> avaliacoesEncontradas = [];

        avaliacoesData.forEach((key, value) {
          Map<String, dynamic> avaliacao = Map<String, dynamic>.from(value);
          avaliacao['id'] = key;

          if (avaliacao['categoria'] == 'Avaliacao' &&
              avaliacao['prestador'] != null &&
              avaliacao['prestador']['cpfCnpj'].toString() == cpfCnpj) {
            avaliacoesEncontradas.add(avaliacao);
          }
        });

        avaliacoesPrestador = avaliacoesEncontradas;
        print("Avaliações do prestador carregadas: ${avaliacoesPrestador.length}");
      } else {
        avaliacoesPrestador = [];
        print("Nenhuma avaliação encontrada");
      }
    } catch (e) {
      print("Erro ao buscar avaliações: $e");
      throw e;
    }
  }

  String getNome() {
    return dadosPrestador?['nome']?.toString() ?? 'Nome não informado';
  }

  String getIdade() {
    int? idade = dadosPrestador?['idade'];
    if (idade != null) {
      return '$idade anos';
    }
    return 'Idade não informada';
  }

  String getEmail() {
    return dadosPrestador?['email']?.toString() ?? 'Email não informado';
  }

  String getTelefone() {
    String telefone = dadosPrestador?['telefone']?.toString() ?? '';
    if (telefone.isEmpty) {
      return 'Telefone não informado';
    }

    String numLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (numLimpo.length == 11) {
      return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 7)}-${numLimpo.substring(7)}';
    } else if (numLimpo.length == 10) {
      return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 6)}-${numLimpo.substring(6)}';
    }
    return telefone;
  }

  String getLogradouro() {
    return dadosPrestador?['logradouro']?.toString() ?? 'Endereço não informado';
  }

  String getCep() {
    String cep = dadosPrestador?['cep']?.toString() ?? '';
    if (cep.isEmpty) {
      return 'CEP não informado';
    }

    String cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cepLimpo.length == 8) {
      return '${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}';
    }
    return cep;
  }

  String getBiografia() {
    String? biografia = dadosPrestador?['biografia']?.toString();
    if (biografia != null && biografia.isNotEmpty) {
      return biografia;
    }
    return 'Biografia não informada';
  }

  bool temBiografia() {
    String? biografia = dadosPrestador?['biografia']?.toString();
    return biografia != null && biografia.isNotEmpty;
  }

  int getTotalServicos() {
    return servicosPrestador.length;
  }

  double getMediaAvaliacoes() {
    if (avaliacoesPrestador.isEmpty) {
      return 0.0;
    }

    double somaNotas = 0.0;
    int contador = 0;

    for (var avaliacao in avaliacoesPrestador) {
      double? nota = avaliacao['nota']?.toDouble();
      if (nota != null) {
        somaNotas += nota;
        contador++;
      }
    }

    if (contador == 0) {
      return 0.0;
    }

    return somaNotas / contador;
  }

  int getTotalAvaliacoes() {
    return avaliacoesPrestador.length;
  }

  List<Map<String, dynamic>> getServicos() {
    return servicosPrestador;
  }

  List<Map<String, dynamic>> getAvaliacoes() {
    return avaliacoesPrestador;
  }

  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> salvarBiografia(String cpfCnpj, String biografia) async {
    try {
      await _ref.child('usuarios/$cpfCnpj').update({
        'biografia': biografia.trim(),
      });

      if (dadosPrestador != null) {
        dadosPrestador!['biografia'] = biografia.trim();
      }

      print("Biografia salva com sucesso");
    } catch (e) {
      print("Erro ao salvar biografia: $e");
      throw Exception("Erro ao salvar biografia");
    }
  }

  Future<void> salvarNome(String cpfCnpj, String nome) async {
    try {
      if (nome.trim().isEmpty) {
        throw Exception("Nome não pode estar vazio");
      }

      await _ref.child('usuarios/$cpfCnpj').update({
        'nome': nome.trim(),
      });

      if (dadosPrestador != null) {
        dadosPrestador!['nome'] = nome.trim();
      }

      print("Nome salvo com sucesso");
    } catch (e) {
      print("Erro ao salvar nome: $e");
      throw Exception("Erro ao salvar nome");
    }
  }

  Future<void> salvarTelefone(String cpfCnpj, String telefone) async {
    try {
      String telefoneLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');

      if (telefoneLimpo.isEmpty) {
        throw Exception("Telefone não pode estar vazio");
      }

      if (telefoneLimpo.length != 10 && telefoneLimpo.length != 11) {
        throw Exception("Telefone inválido");
      }

      await _ref.child('usuarios/$cpfCnpj').update({
        'telefone': telefoneLimpo,
      });

      if (dadosPrestador != null) {
        dadosPrestador!['telefone'] = telefoneLimpo;
      }

      print("Telefone salvo com sucesso");
    } catch (e) {
      print("Erro ao salvar telefone: $e");
      throw Exception("Erro ao salvar telefone");
    }
  }

  Future<void> salvarLogradouro(String cpfCnpj, String logradouro) async {
    try {
      if (logradouro.trim().isEmpty) {
        throw Exception("Logradouro não pode estar vazio");
      }

      await _ref.child('usuarios/$cpfCnpj').update({
        'logradouro': logradouro.trim(),
      });

      if (dadosPrestador != null) {
        dadosPrestador!['logradouro'] = logradouro.trim();
      }

      print("Logradouro salvo com sucesso");
    } catch (e) {
      print("Erro ao salvar logradouro: $e");
      throw Exception("Erro ao salvar logradouro");
    }
  }

  Future<void> salvarCep(String cpfCnpj, String cep) async {
    try {
      String cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');

      if (cepLimpo.isEmpty) {
        throw Exception("CEP não pode estar vazio");
      }

      if (cepLimpo.length != 8) {
        throw Exception("CEP inválido");
      }

      await _ref.child('usuarios/$cpfCnpj').update({
        'cep': cepLimpo,
      });

      if (dadosPrestador != null) {
        dadosPrestador!['cep'] = cepLimpo;
      }

      print("CEP salvo com sucesso");
    } catch (e) {
      print("Erro ao salvar CEP: $e");
      throw Exception("Erro ao salvar CEP");
    }
  }

  void dispose() {
  }
}