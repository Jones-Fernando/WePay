import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _carregando = true;
  bool _atualizando = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    final perfil = await ApiService.getProfile();
    if (!mounted) return;
    setState(() {
      _nomeCtrl.text = perfil['nome'] ?? '';
      _emailCtrl.text = perfil['email'] ?? '';
      _carregando = false;
    });
  }

  void _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e email sao obrigatorios.')),
      );
      return;
    }
    setState(() => _atualizando = true);
    final sucesso = await ApiService.atualizarPerfil(
      _nomeCtrl.text.trim(),
      _emailCtrl.text.trim(),
      senha: _senhaCtrl.text.trim().isEmpty ? null : _senhaCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _atualizando = false);
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
      _senhaCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil.')),
      );
    }
  }

  void _deletarConta() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir conta'),
          content: const Text('Deseja realmente excluir sua conta?'),
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
    final sucesso = await ApiService.deletarConta();
    if (!mounted) return;
    if (sucesso) {
      ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao excluir a conta.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nova senha (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: _atualizando ? null : _salvar,
                      child: _atualizando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar alteracoes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _deletarConta,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Excluir conta'),
                  ),
                ],
              ),
            ),
    );
  }
}
