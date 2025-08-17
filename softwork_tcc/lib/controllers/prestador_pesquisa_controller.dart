import 'package:firebase_database/firebase_database.dart';

class PrestadorPesquisaController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Function(bool)? onLoadingChanged;
  Function(List<Map<String, dynamic>>)? onResultsChanged;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? resultsCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onResultsChanged = resultsCallback;
    onError = errorCallback;
  }

  Future<void> pesquisarPrestadores(String query) async {
    print("Pesquisando prestadores: $query");

    if (query.trim().isEmpty) {
      onLoadingChanged?.call(false);
      onResultsChanged?.call([]);
      return;
    }

    onLoadingChanged?.call(true);

    try {
      List<Map<String, dynamic>> prestadores = await _buscarPrestadoresNoFirebase(query);

      onLoadingChanged?.call(false);
      onResultsChanged?.call(prestadores);

    } catch (e) {
      onLoadingChanged?.call(false);
      onResultsChanged?.call([]);
      onError?.call("Erro ao pesquisar prestadores");

      print("Erro na pesquisa: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _buscarPrestadoresNoFirebase(String query) async {
    final snapshot = await _ref.child('usuarios').get();

    if (!snapshot.exists) {
      print("Nenhum usuário encontrado no banco de dados");
      return [];
    }

    Map<dynamic, dynamic> usuariosData = snapshot.value as Map<dynamic, dynamic>;
    List<Map<String, dynamic>> prestadoresEncontrados = [];

    usuariosData.forEach((cpfCnpj, userData) {
      Map<String, dynamic> usuario = Map<String, dynamic>.from(userData);

      if (usuario['tipoConta'] == false) {
        String nomeUsuario = usuario['nome']?.toString().toLowerCase() ?? '';
        String queryLower = query.toLowerCase();

        if (nomeUsuario.contains(queryLower)) {
          prestadoresEncontrados.add({
            'cpfCnpj': cpfCnpj,
            'nome': usuario['nome'] ?? '',
            'email': usuario['email'] ?? '',
            'telefone': usuario['telefone'] ?? '',
            'logradouro': usuario['logradouro'] ?? '',
            'cep': usuario['cep'] ?? '',
            'idade': usuario['idade'] ?? 0,
            'tipoConta': usuario['tipoConta'] ?? false,
          });
        }
      }
    });

    prestadoresEncontrados.sort((a, b) =>
        a['nome'].toString().toLowerCase().compareTo(b['nome'].toString().toLowerCase())
    );

    print("Prestadores encontrados: ${prestadoresEncontrados.length}");
    return prestadoresEncontrados;
  }

  Future<Map<String, dynamic>?> buscarPrestadorPorCpfCnpj(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('usuarios/$cpfCnpj').get();

      if (snapshot.exists) {
        Map<String, dynamic> prestador = Map<String, dynamic>.from(snapshot.value as Map);

        if (prestador['tipoConta'] == false) {
          prestador['cpfCnpj'] = cpfCnpj;
          return prestador;
        }
      }

      return null;
    } catch (e) {
      print("Erro ao buscar prestador: $e");
      throw Exception("Erro ao buscar prestador: $e");
    }
  }
}