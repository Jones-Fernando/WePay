import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class DespesaListaView extends StatefulWidget {
  const DespesaListaView({super.key});

  @override
  State<DespesaListaView> createState() => _DespesaListaViewState();
}

class _DespesaListaViewState extends State<DespesaListaView> {
  List<dynamic> _despesas = [];
  bool _carregando = true;
  bool _inicializado = false;
  late Map grupo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    grupo = ModalRoute.of(context)!.settings.arguments as Map;
    _carregarDespesas();
  }

  void _carregarDespesas() async {
    setState(() => _carregando = true);
    final dados = await ApiService.getDespesas(grupo['id']);
    if (!mounted) return;
    setState(() {
      _despesas = dados;
      _carregando = false;
    });
  }

  void _deletarDespesa(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Despesa'),
        content: const Text('Tem certeza que deseja excluir esta despesa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final sucesso = await ApiService.deletarDespesa(id);
    if (!mounted) return;
    if (sucesso) {
      _carregarDespesas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Despesa removida!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Despesas - ${grupo['nome'] ?? ''}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _despesas.isEmpty
              ? const Center(child: Text('Nenhuma despesa encontrada.'))
              : ListView.builder(
                  itemCount: _despesas.length,
                  itemBuilder: (context, index) {
                    final d = _despesas[index];
                    final valor = (d['valor'] is num)
                        ? (d['valor'] as num).toStringAsFixed(2)
                        : d['valor']?.toString() ?? '0.00';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.teal),
                        title: Text(
                          d['descricao'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pago por: ${d['pagador'] ?? ''}\nData: ${d['data'] ?? ''}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'R\$ $valor',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/despesa-form',
                                  arguments: {'despesa': d, 'grupo': grupo},
                                );
                                _carregarDespesas();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletarDespesa(d['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/despesa-form',
            arguments: {'grupo': grupo},
          );
          _carregarDespesas();
        },
      ),
    );
  }
}
