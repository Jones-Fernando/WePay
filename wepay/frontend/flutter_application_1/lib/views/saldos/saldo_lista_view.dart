import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class SaldoListaView extends StatefulWidget {
  const SaldoListaView({super.key});

  @override
  State<SaldoListaView> createState() => _SaldoListaViewState();
}

class _SaldoListaViewState extends State<SaldoListaView> {
  List<dynamic> _saldos = [];
  bool _carregando = true;
  bool _inicializado = false;
  late Map grupo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    grupo = ModalRoute.of(context)!.settings.arguments as Map;
    _carregarSaldos();
  }

  void _carregarSaldos() async {
    setState(() => _carregando = true);

    final dados = await ApiService.getSaldos(grupo['id']);

    if (!mounted) return;

    setState(() {
      _saldos = dados;
      _carregando = false;
    });
  }

  void _deletarSaldo(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover saldo'),
          content: const Text('Tem certeza que deseja excluir este saldo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    final sucesso = await ApiService.deletarSaldo(id);

    if (!mounted) return;

    if (sucesso) {
      _carregarSaldos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo excluído com sucesso.')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao excluir saldo.')));
    }
  }

  String _fmt(dynamic valor) {
    final v = (valor is num)
        ? valor.toDouble()
        : double.tryParse(valor?.toString() ?? '0') ?? 0.0;

    return v.abs().toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saldos - ${grupo['nome'] ?? ''}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _carregarSaldos,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _saldos.isEmpty
          ? const Center(child: Text('Nenhum saldo encontrado.'))
          : RefreshIndicator(
              onRefresh: () async => _carregarSaldos(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Saldos atualizados automaticamente após cada despesa criada ou editada neste grupo.',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._saldos.map((s) {
                    final saldo = (s['saldo'] is num)
                        ? (s['saldo'] as num).toDouble()
                        : double.tryParse(s['saldo']?.toString() ?? '0') ?? 0.0;

                    final positivo = saldo >= 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: positivo
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                positivo
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: positivo ? Colors.green : Colors.red,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['nome'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s['email'] ?? '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  positivo ? 'A receber' : 'A pagar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: positivo ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  'R\$ ${_fmt(saldo)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: positivo ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/saldo-form',
                                  arguments: {'grupo': grupo, 'saldo': s},
                                ).then((_) => _carregarSaldos());
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletarSaldo(s['id'] as int),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/saldo-form',
            arguments: {'grupo': grupo},
          ).then((_) => _carregarSaldos());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
