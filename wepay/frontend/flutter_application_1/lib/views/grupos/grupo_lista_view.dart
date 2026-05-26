import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class GrupoListaView extends StatefulWidget {
  const GrupoListaView({super.key});

  @override
  State<GrupoListaView> createState() => _GrupoListaViewState();
}

class _GrupoListaViewState extends State<GrupoListaView> {
  List<dynamic> _grupos = [];
  bool _carregando = true;
  bool _inicializado = false;
  String? _mensagemInicial;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    _mensagemInicial = args?['mensagem'] as String?;
    if (_mensagemInicial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mensagemInicial!),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  Future<void> _carregarGrupos() async {
    setState(() => _carregando = true);
    final dados = await ApiService.getGrupos();
    if (!mounted) return;
    setState(() {
      _grupos = dados;
      _carregando = false;
    });
  }

  void _deletarGrupo(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text(
          'Excluir o grupo "$nome"? Todas as despesas serão removidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final sucesso = await ApiService.deletarGrupo(id);
    if (!mounted) return;
    if (sucesso) {
      _carregarGrupos();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Grupo removido!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao remover grupo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _fmtSaldo(dynamic saldo) {
    final v = (saldo is num)
        ? saldo.toDouble()
        : double.tryParse(saldo?.toString() ?? '0') ?? 0.0;
    return v.toStringAsFixed(2);
  }

  Color _corSaldo(dynamic saldo) {
    final v = (saldo is num)
        ? saldo.toDouble()
        : double.tryParse(saldo?.toString() ?? '0') ?? 0.0;
    if (v > 0) return Colors.green;
    if (v < 0) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Grupos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: _carregarGrupos,
              child: _grupos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'Nenhum grupo encontrado.\nToque em + para criar um.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _grupos.length,
                      itemBuilder: (context, index) {
                        final grupo = _grupos[index];
                        final saldo = _fmtSaldo(grupo['saldo']);
                        final corSaldo = _corSaldo(grupo['saldo']);
                        final participantes = grupo['participantes'] ?? 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: const Icon(
                                Icons.group,
                                color: Colors.teal,
                              ),
                            ),
                            title: Text(
                              grupo['nome'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((grupo['descricao'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      grupo['descricao'].toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$participantes participante${participantes != 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Saldo: R\$ $saldo',
                                      style: TextStyle(
                                        color: corSaldo,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.receipt_long,
                                        color: Colors.teal,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Despesas',
                                        style: TextStyle(color: Colors.teal),
                                      ),
                                      onPressed: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/despesas',
                                          arguments: grupo,
                                        );
                                        _carregarGrupos();
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.people,
                                        color: Colors.indigo,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Participantes',
                                        style: TextStyle(color: Colors.indigo),
                                      ),
                                      onPressed: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/participantes',
                                          arguments: grupo,
                                        );
                                        _carregarGrupos();
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Saldos',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/saldos',
                                        arguments: grupo,
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Editar',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/grupo-form',
                                          arguments: grupo,
                                        );
                                        _carregarGrupos();
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Excluir',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () => _deletarGrupo(
                                        grupo['id'],
                                        grupo['nome'] ?? '',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Grupo', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.pushNamed(context, '/grupo-form');
          _carregarGrupos();
        },
      ),
    );
  }
}
