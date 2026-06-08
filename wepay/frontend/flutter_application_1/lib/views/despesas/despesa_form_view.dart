import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/services/api_services.dart';

class DespesaFormView extends StatefulWidget {
  const DespesaFormView({super.key});

  @override
  State<DespesaFormView> createState() => _DespesaFormViewState();
}

class _DespesaFormViewState extends State<DespesaFormView> {
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  int? _idEdicao;
  late Map grupo;
  bool _inicializado = false;
  List<dynamic> _participantes = [];
  int? _pagadorId;

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
      // se estiver editando, preenche pagador se disponível
      if (despesa['pagador_id'] != null) {
        _pagadorId = despesa['pagador_id'] as int?;
      }
    }
    // carregar participantes do grupo para selecionar pagador
    _carregarParticipantes();
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  void _carregarParticipantes() async {
    final participantes = await ApiService.getParticipantes(grupo['id']);
    if (!mounted) return;
    setState(() {
      _participantes = participantes;
      // se não houver pagador selecionado, escolher o primeiro (ou manter nulo)
      if (_pagadorId == null && participantes.isNotEmpty) {
        _pagadorId = participantes.first['usuario_id'] as int?;
      }
    });
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
      if (_pagadorId != null) 'pagador_id': _pagadorId,
    };
    final sucesso = await ApiService.salvarDespesa(dados, id: _idEdicao);
    if (!mounted) return;
    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _idEdicao == null
                ? 'Despesa criada e dividida automaticamente entre o grupo!'
                : 'Despesa atualizada e divisão recalculada automaticamente!',
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
      body: SingleChildScrollView(
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
            const SizedBox(height: 8),
            const Text(
              'Esta despesa será dividida automaticamente entre todos os participantes do grupo.',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (_participantes.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                initialValue: _pagadorId,
                decoration: const InputDecoration(
                  labelText: 'Pagador',
                  border: OutlineInputBorder(),
                ),
                items: _participantes.map<DropdownMenuItem<int>>((p) {
                  final uid = p['usuario_id'] as int?;
                  final nome = p['nome'] ?? p['email'] ?? 'Usuário';
                  return DropdownMenuItem<int>(value: uid, child: Text(nome));
                }).toList(),
                onChanged: (v) => setState(() => _pagadorId = v),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
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
