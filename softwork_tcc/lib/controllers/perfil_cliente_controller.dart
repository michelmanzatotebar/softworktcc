import 'package:firebase_database/firebase_database.dart';

class PerfilClienteController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  bool isLoading = false;
  Map<String, dynamic>? dadosCliente;

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

  Future<void> carregarDadosCliente(String cpfCnpj) async {
    try {
      isLoading = true;
      onLoadingChanged?.call(true);

      await _buscarDadosUsuario(cpfCnpj);

      isLoading = false;
      onLoadingChanged?.call(false);
      onDataLoaded?.call();
    } catch (e) {
      print("Erro ao carregar dados do cliente: $e");
      isLoading = false;
      onLoadingChanged?.call(false);
      onError?.call("Erro ao carregar dados do cliente");
    }
  }

  Future<void> _buscarDadosUsuario(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('usuarios/$cpfCnpj').get();

      if (snapshot.exists) {
        dadosCliente = Map<String, dynamic>.from(snapshot.value as Map);
        dadosCliente!['cpfCnpj'] = cpfCnpj;
        print("Dados do cliente carregados com sucesso");
      } else {
        print("Cliente não encontrado");
        dadosCliente = null;
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      throw e;
    }
  }

  String getNome() {
    return dadosCliente?['nome']?.toString() ?? 'Nome não informado';
  }

  String getIdade() {
    int? idade = dadosCliente?['idade'];
    if (idade != null) {
      return '$idade anos';
    }
    return 'Idade não informada';
  }

  String getEmail() {
    return dadosCliente?['email']?.toString() ?? 'Email não informado';
  }

  String getTelefone() {
    String telefone = dadosCliente?['telefone']?.toString() ?? '';
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
    return dadosCliente?['logradouro']?.toString() ?? 'Endereço não informado';
  }

  String getCep() {
    String cep = dadosCliente?['cep']?.toString() ?? '';
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
    String? biografia = dadosCliente?['biografia']?.toString();
    if (biografia != null && biografia.isNotEmpty) {
      return biografia;
    }
    return 'Biografia não informada';
  }

  bool temBiografia() {
    String? biografia = dadosCliente?['biografia']?.toString();
    return biografia != null && biografia.isNotEmpty;
  }

  Future<void> salvarBiografia(String cpfCnpj, String biografia) async {
    try {
      await _ref.child('usuarios/$cpfCnpj').update({
        'biografia': biografia.trim(),
      });

      if (dadosCliente != null) {
        dadosCliente!['biografia'] = biografia.trim();
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

      if (dadosCliente != null) {
        dadosCliente!['nome'] = nome.trim();
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

      if (dadosCliente != null) {
        dadosCliente!['telefone'] = telefoneLimpo;
      }

      print("Telefone salvo com sucesso");
    } catch (e) {
      print("Erro ao salvar telefone: $e");
      throw Exception("Erro ao salvar telefone");
    }
  }

  void dispose() {
  }
}