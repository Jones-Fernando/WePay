class ParticipanteModel {
  final int id;
  final String nome;

  ParticipanteModel({required this.id, required this.nome});

  factory ParticipanteModel.fromJson(Map<String, dynamic> json) {
    return ParticipanteModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
    );
  }
}