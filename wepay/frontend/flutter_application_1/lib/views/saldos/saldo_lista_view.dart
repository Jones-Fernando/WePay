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

  String _fmt(dynamic valor) {
    final v = (valor is num) ? valor.toDouble() : double.tryParse(valor?.toString() ?? '0') ?? 0.0;
    return v.abs().toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saldos - ${grupo['nome'] ?? ''}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _saldos.length,
                    itemBuilder: (context, index) {
                      final s = _saldos[index];
                      final saldo = (s['saldo'] is num) ? (s['saldo'] as num).toDouble() : double.tryParse(s['saldo']?.toString() ?? '0') ?? 0.0;
                      final positivo = saldo >= 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: positivo ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              positivo ? Icons.arrow_downward : Icons.arrow_upward,
                              color: positivo ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(s['nome'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s['email'] ?? ''),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                positivo ? 'A receber' : 'A pagar',
                                style: TextStyle(fontSize: 11, color: positivo ? Colors.green : Colors.red),
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
