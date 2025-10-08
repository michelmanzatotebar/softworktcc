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

  void dispose() {
  }
}