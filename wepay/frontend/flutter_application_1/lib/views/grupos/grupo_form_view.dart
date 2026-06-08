import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class GrupoFormView extends StatefulWidget {
  const GrupoFormView({super.key});

  @override
  State<GrupoFormView> createState() => _GrupoFormViewState();
}

class _GrupoFormViewState extends State<GrupoFormView> {
  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  int? _idEdicao;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final Map? dadosGrupo = ModalRoute.of(context)!.settings.arguments as Map?;
    if (dadosGrupo != null) {
      _idEdicao = dadosGrupo['id'];
      _nomeCtrl.text = dadosGrupo['nome'] ?? '';
      _descricaoCtrl.text = dadosGrupo['descricao'] ?? '';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  void _salvar() async {
    // Verifica se há token de autenticação antes de tentar salvar
    if (ApiService.authToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para criar um grupo.'),
        ),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    final nome = _nomeCtrl.text.trim();
    final descricao = _descricaoCtrl.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome do grupo.')));
      return;
    }

    if (nome.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome do grupo deve ter ao menos 2 caracteres.'),
        ),
      );
      return;
    }

    final resultado = await ApiService.salvarGrupo(
      nome,
      descricao: descricao.isEmpty ? null : descricao,
      id: _idEdicao,
    );

    if (!mounted) return;

    if (resultado['ok'] == true) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resultado['mensagem'] as String)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _idEdicao == null ? 'Novo Grupo' : 'Editar Grupo',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição do Grupo (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Ex: gastos de viagem, casa ou faculdade',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: _salvar,
                child: const Text(
                  'Salvar Grupo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
