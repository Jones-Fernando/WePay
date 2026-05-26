import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, dynamic> _dados = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  void _carregarDashboard() async {
    final dados = await ApiService.getDashboard();
    if (!mounted) return;
    setState(() {
      _dados = dados;
      _carregando = false;
    });
  }

  String _fmt(dynamic valor) {
    final v = (valor is num)
        ? valor.toDouble()
        : double.tryParse(valor?.toString() ?? '0') ?? 0.0;
    return v.toStringAsFixed(2);
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    String titulo,
    String descricao,
    IconData icone,
    Color cor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cor.withAlpha((0.14 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                descricao,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF056E63), Color(0xFF0EA37B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo ao WePay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acompanhe seus grupos e despesas de forma simples e rápida.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grupos ativos',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_dados['total_grupos'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.24 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: const Text(
                  'Atualizado',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'WePay',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() => _carregando = true);
                _carregarDashboard();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                ApiService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Visão Geral', icon: Icon(Icons.bar_chart)),
              Tab(text: 'Atalhos', icon: Icon(Icons.grid_view)),
            ],
          ),
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : TabBarView(
                children: [_buildVisaoGeral(context), _buildAtalhos(context)],
              ),
      ),
    );
  }

  Widget _buildVisaoGeral(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _carregarDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 20),
          const Text(
            'Visão geral',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _metricTile(
                'Grupos',
                '${_dados['total_grupos'] ?? 0}',
                Colors.teal,
              ),
              _metricTile(
                'A Receber',
                'R\$ ${_fmt(_dados['receber'])}',
                Colors.green,
              ),
              _metricTile(
                'A Pagar',
                'R\$ ${_fmt(_dados['pagar'])}',
                Colors.red,
              ),
              _metricTile(
                'Total Gasto',
                'R\$ ${_fmt(_dados['total_gasto_geral'])}',
                Colors.deepOrange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dica rápida',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use a seção de grupos para organizar despesas e acompanhar participantes com mais facilidade.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtalhos(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _carregarDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Atalhos rápidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _menuItem(
                'Grupos',
                'Gerencie seus grupos',
                Icons.group,
                Colors.teal,
                () async {
                  await Navigator.pushNamed(context, '/grupos');
                  _carregarDashboard();
                },
              ),
              _menuItem(
                'Despesas',
                'Abra um grupo para ver e adicionar despesas',
                Icons.receipt_long,
                Colors.deepOrange,
                () async {
                  await Navigator.pushNamed(
                    context,
                    '/grupos',
                    arguments: {
                      'mensagem':
                          'Selecione um grupo para ver ou cadastrar despesas.',
                    },
                  );
                  _carregarDashboard();
                },
              ),
              _menuItem(
                'Participantes',
                'Abra um grupo para gerenciar participantes',
                Icons.person_add,
                Colors.blueAccent,
                () async {
                  await Navigator.pushNamed(
                    context,
                    '/grupos',
                    arguments: {
                      'mensagem':
                          'Selecione um grupo para ver e gerenciar participantes.',
                    },
                  );
                  _carregarDashboard();
                },
              ),
              _menuItem(
                'Saldos',
                'Abra um grupo para conferir os saldos',
                Icons.account_balance_wallet,
                Colors.green,
                () async {
                  await Navigator.pushNamed(
                    context,
                    '/grupos',
                    arguments: {
                      'mensagem':
                          'Selecione um grupo para ver o saldo detalhado.',
                    },
                  );
                  _carregarDashboard();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
