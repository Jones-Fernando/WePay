import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/services/api_services.dart';

class DespesaFormView extends StatefulWidget {
  const DespesaFormView({Key? key}) : super(key: key);

  @override
  State<DespesaFormView> createState() => _DespesaFormViewState();
}

class _DespesaFormViewState extends State<DespesaFormView> {
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  int? _idEdicao;
  late Map grupo;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    grupo = args['grupo'] as Map;
    final despesa = args['despesa'] as Map?;
    if (despesa != null) {
      _idEdicao = despesa['id'];
      _descricaoCtrl.text = despesa['descricao'] ?? '';
      _valorCtrl.text = despesa['valor']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  void _salvar() async {
    final descricao = _descricaoCtrl.text.trim();
    final valorTexto = _valorCtrl.text.trim();
    if (descricao.isEmpty || valorTexto.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    final valor = double.tryParse(valorTexto.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido maior que zero')),
      );
      return;
    }

    final dados = {
      'grupo_id': grupo['id'],
      'descricao': descricao,
      'valor': valor,
    };
    final sucesso = await ApiService.salvarDespesa(dados, id: _idEdicao);
    if (!mounted) return;
    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _idEdicao == null
                ? 'Despesa criada com sucesso!'
                : 'Despesa atualizada com sucesso!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar despesa')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _idEdicao == null ? 'Nova Despesa' : 'Editar Despesa',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Grupo: ${grupo['nome'] ?? ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if ((grupo['descricao'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                grupo['descricao'].toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _descricaoCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
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
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 125,00',
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
                  'Salvar Despesa',
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
