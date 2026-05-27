import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() => _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _carregando = false;
  bool _enviado = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    final res = await ApiService.recuperarSenha(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _carregando = false;
      _enviado = res['status'] == 'sucesso';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['mensagem'] ?? 'Resultado'),
        backgroundColor: res['status'] == 'sucesso' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insira seu e-mail cadastrado para receber uma nova senha.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: !_enviado,
                decoration: const InputDecoration(
                  labelText: 'Seu E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 24),
              if (_enviado)
                const Card(
                  color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(child: Text('Nova senha enviada! Verifique seu e-mail.', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: _carregando ? null : _enviar,
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Enviar Nova Senha', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              if (_enviado) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar ao Login', style: TextStyle(color: Colors.teal)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
