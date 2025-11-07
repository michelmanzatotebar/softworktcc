import 'package:firebase_database/firebase_database.dart';

class TelaPrincipalClienteController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  static final Map<String, List<Map<String, dynamic>>> _servicosRecentesPorCliente = {};

  Function(List<Map<String, dynamic>>)? onServicosRecentesChanged;
  Function(String)? onError;
  Function(bool)? onLoadingChanged;

  void setCallbacks({
    Function(List<Map<String, dynamic>>)? servicosRecentesCallback,
    Function(String)? errorCallback,
    Function(bool)? loadingCallback,
  }) {
    onServicosRecentesChanged = servicosRecentesCallback;
    onError = errorCallback;
    onLoadingChanged = loadingCallback;
  }
// Carrega serviços pesquisados recentemente pelo cliente
  Future<void> carregarServicosRecentes(String cpfCnpj) async {
    try {
      onLoadingChanged?.call(true);

      final servicosRecentes = _servicosRecentesPorCliente[cpfCnpj] ?? [];

      onServicosRecentesChanged?.call(servicosRecentes);
      onLoadingChanged?.call(false);
    } catch (e) {
      onLoadingChanged?.call(false);
      onError?.call("Erro ao carregar serviços recentes");
      print("Erro ao carregar serviços recentes: $e");
    }
  }
// Adiciona serviço à lista de recentes
  Future<void> adicionarServicoRecente(Map<String, dynamic> servico, String cpfCnpj) async {
    try {
      List<Map<String, dynamic>> servicosRecentes = [];

      servicosRecentes.insert(0, servico);

      _servicosRecentesPorCliente[cpfCnpj] = servicosRecentes;

      onServicosRecentesChanged?.call(servicosRecentes);
    } catch (e) {
      onError?.call("Erro ao salvar serviço recente");
      print("Erro ao salvar serviço recente: $e");
    }
  }
// Limpa lista de serviços recentes
  Future<void> limparServicosRecentes(String cpfCnpj) async {
    try {
      _servicosRecentesPorCliente[cpfCnpj] = [];
      onServicosRecentesChanged?.call([]);
    } catch (e) {
      onError?.call("Erro ao limpar serviços recentes");
      print("Erro ao limpar serviços recentes: $e");
    }
  }
}