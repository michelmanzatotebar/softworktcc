import 'pessoa.dart';

class Login {
  List<Pessoa> usuarios;

  Login({
    required this.usuarios,
  });

  Login.fromMap(Map<String, dynamic> map)
      : usuarios = (map['usuarios'] as List<dynamic>)
      .map((u) => Pessoa.fromMap(u))
      .toList();

  Map<String, dynamic> toMap() {
    return {
      'usuarios': usuarios.map((u) => u.toMap()).toList(),
    };
  }
}