class GrupoModel {
  final int? id;
  final String nome;
  final int participantes;
  final double saldo;

  GrupoModel({this.id, required this.nome, this.participantes = 1, this.saldo = 0.0});

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      participantes: json['participantes'] ?? 1,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nome': nome,
  };
}