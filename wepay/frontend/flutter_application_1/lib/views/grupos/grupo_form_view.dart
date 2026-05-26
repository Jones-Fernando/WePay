import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class GrupoFormView extends StatefulWidget {
  const GrupoFormView({Key? key}) : super(key: key);

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
    if (_nomeCtrl.text.isEmpty) return;
    final sucesso = await ApiService.salvarGrupo(
      _nomeCtrl.text,
      descricao: _descricaoCtrl.text,
      id: _idEdicao,
    );
    if (!mounted) return;
    if (sucesso) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar grupo')));
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
