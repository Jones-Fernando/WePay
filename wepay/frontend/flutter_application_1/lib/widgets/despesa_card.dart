import 'package:flutter/material.dart';
import '../models/despesa_model.dart';

class DespesaCard extends StatelessWidget {
  final DespesaModel despesa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DespesaCard({
    super.key,
    required this.despesa,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.attach_money, color: Colors.blue.shade700),
        ),
        title: Text(
          despesa.nome ?? 'Nome não disponível',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Valor: R\$ ${despesa.valor.toStringAsFixed(2)}'),
            Text('Data: ${despesa.data.toString().substring(0, 10)}'),
            if (despesa.descricao.isNotEmpty)
              Text('Descrição: ${despesa.descricao}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}