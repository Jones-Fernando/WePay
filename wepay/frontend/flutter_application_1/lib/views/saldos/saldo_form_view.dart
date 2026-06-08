import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/services/api_services.dart';

class SaldoFormView extends StatefulWidget {
  const SaldoFormView({super.key});

  @override
  State<SaldoFormView> createState() => _SaldoFormViewState();
}

class _SaldoFormViewState extends State<SaldoFormView> {
  final _valorCtrl = TextEditingController();
  int? _usuarioId;
  late Map grupo;
  Map? saldo;
  List<dynamic> _participantes = [];
  bool _inicializado = false;
  bool _carregando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    grupo = args['grupo'] as Map;
    saldo = args['saldo'] as Map?;
    if (saldo != null) {
      _usuarioId = saldo!['usuario_id'] as int?;
      _valorCtrl.text = saldo!['saldo']?.toString() ?? '';
    }
    _carregarParticipantes();
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarParticipantes() async {
    final participantes = await ApiService.getParticipantes(grupo['id']);
    if (!mounted) return;
    setState(() {
      _participantes = participantes;
      if (_usuarioId == null && participantes.isNotEmpty) {
        _usuarioId = participantes.first['usuario_id'] as int?;
      }
      _carregando = false;
    });
  }

  void _salvar() async {
    final valorTexto = _valorCtrl.text.trim();
    if (_usuarioId == null || valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    final valor = double.tryParse(valorTexto.replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um valor valido.')));
      return;
    }

    final body = {
      'grupo_id': grupo['id'],
      'usuario_id': _usuarioId,
      'saldo': valor,
    };

    final success = saldo == null
        ? await ApiService.criarSaldo(body)
        : await ApiService.atualizarSaldo(
            saldo!['id'] as int,
            valor,
            usuarioId: _usuarioId,
          );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saldo == null
                ? 'Saldo criado com sucesso!'
                : 'Saldo atualizado com sucesso!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar o saldo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          saldo == null ? 'Novo Saldo' : 'Editar Saldo',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Grupo: ${grupo['nome'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _usuarioId,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        border: OutlineInputBorder(),
                      ),
                      items: _participantes.map((p) {
                        return DropdownMenuItem<int>(
                          value: p['usuario_id'] as int,
                          child: Text(p['nome'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        setState(() => _usuarioId = valor);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _valorCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Saldo (R\$)',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 125,50',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: _salvar,
                        child: const Text(
                          'Salvar Saldo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
    );
  }
}
