class Perfil {
  String biografia;

  Perfil({
    required this.biografia,
  });

  Perfil.fromMap(Map<String, dynamic> map)
      : biografia = map['biografia'];

  Map<String, dynamic> toMap() {
    return {
      'biografia': biografia,
    };
  }
}