class DespesaModel {
  final int? id;
  final int grupoId;
  final String descricao;
  final double valor;
  final String pagador;
  final DateTime data;

  DespesaModel({
    this.id,
    required this.grupoId,
    required this.descricao,
    required this.valor,
    required this.pagador,
    required this.data,
  });

  factory DespesaModel.fromJson(Map<String, dynamic> json) {
    return DespesaModel(
      id: json['id'],
      grupoId: json['grupo_id'] ?? 0,
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      pagador: json['pagador'] ?? '',
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
    );
  }

  String? get nome => null;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'grupo_id': grupoId,
    'descricao': descricao,
    'valor': valor,
    'pagador': pagador,
    'data': data.toIso8601String(),
  };
}