import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';

class ParticipanteListaView extends StatefulWidget {
  const ParticipanteListaView({super.key});

  @override
  State<ParticipanteListaView> createState() => _ParticipanteListaViewState();
}

class _ParticipanteListaViewState extends State<ParticipanteListaView> {
  List<dynamic> _participantes = [];
  bool _carregando = true;
  late Map grupo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    grupo = ModalRoute.of(context)!.settings.arguments as Map;
    _carregarParticipantes();
  }

  void _carregarParticipantes() async {
    setState(() => _carregando = true);
    final dados = await ApiService.getParticipantes(grupo['id']);
    if (!mounted) return;
    setState(() {
      _participantes = dados;
      _carregando = false;
    });
  }

  void _removerParticipante(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover Participante'),
        content: Text('Remover "$nome" do grupo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    final sucesso = await ApiService.removerParticipante(id);
    if (!mounted) return;
    if (sucesso) {
      _carregarParticipantes();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Participante removido!')));
    }
  }

  void _adicionarParticipante() async {
    final usuarios = await ApiService.getUsuarios();
    if (!mounted) return;

    final idsJaNoGrupo = _participantes.map((p) => p['usuario_id']).toSet();
    final disponiveis = usuarios.where((u) => !idsJaNoGrupo.contains(u['id'])).toList();

    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os usuários já estão no grupo')),
      );
      return;
    }

    final selecionado = await showDialog<Map>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Participante'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: disponiveis.length,
            itemBuilder: (context, index) {
              final u = disponiveis[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(u['nome'] ?? ''),
                subtitle: Text(u['email'] ?? ''),
                onTap: () => Navigator.pop(context, u),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );

    if (selecionado == null) return;
    final sucesso = await ApiService.adicionarParticipante(grupo['id'], selecionado['id']);
    if (!mounted) return;
    if (sucesso) {
      _carregarParticipantes();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Participante adicionado!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao adicionar participante')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes - ${grupo['nome'] ?? ''}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _participantes.isEmpty
              ? const Center(child: Text('Nenhum participante encontrado.'))
              : ListView.builder(
                  itemCount: _participantes.length,
                  itemBuilder: (context, index) {
                    final p = _participantes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(p['nome'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p['email'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removerParticipante(p['id'], p['nome'] ?? ''),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _adicionarParticipante,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
