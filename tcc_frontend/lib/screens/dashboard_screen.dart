import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../auth_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _chamados = [];
  bool _carregando = true;

  final List<String> _statusOpcoes = ['Pendente', 'Em andamento', 'Concluído'];

  @override
  void initState() {
    super.initState();
    if (!AuthState.logado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _carregarChamados();
    }
  }

  Future<void> _carregarChamados() async {
    setState(() => _carregando = true);
    final lista = await ApiService.getChamados();
    setState(() {
      _chamados = lista;
      _carregando = false;
    });
  }

  Future<void> _atualizarStatus(int id, String novoStatus) async {
    await ApiService.atualizarStatus(id, novoStatus);
    await _carregarChamados();
  }

  Future<void> _remover(int id, String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar remoção',
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Deseja remover o chamado de $nome?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ApiService.removerChamado(id);
      await _carregarChamados();
    }
  }

  void _logout() {
    AuthState.logado = false;
    Navigator.pushReplacementNamed(context, '/');
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'Concluído':    return const Color(0xFF2E7D32);
      case 'Em andamento': return const Color(0xFFE65100);
      default:             return const Color(0xFFC62828);
    }
  }

  Color _bgStatus(String status) {
    switch (status) {
      case 'Concluído':    return const Color(0xFFE8F5E9);
      case 'Em andamento': return const Color(0xFFFFF3E0);
      default:             return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Painel Admin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _carregarChamados,
            tooltip: 'Atualizar',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
              label: const Text('Sair', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _chamados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
                        ),
                        child: Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                      ),
                      const SizedBox(height: 16),
                      Text('Nenhum chamado ainda',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text('Os chamados registrados aparecerão aqui.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Contador
                    Container(
                      color: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_chamados.length} chamado${_chamados.length != 1 ? 's' : ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chamados.length,
                        itemBuilder: (context, index) {
                          final c = _chamados[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F5E9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text('${c['id']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                              fontSize: 13,
                                            )),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(c['nome'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Color(0xFF1A1A1A),
                                          )),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _bgStatus(c['status_chamado']),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(c['status_chamado'],
                                          style: TextStyle(
                                            color: _corStatus(c['status_chamado']),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  Divider(color: Colors.grey.shade100, height: 1),
                                  const SizedBox(height: 12),

                                  _info(Icons.email_outlined, c['email']),
                                  const SizedBox(height: 6),
                                  _info(Icons.phone_outlined, c['telefone']),
                                  const SizedBox(height: 6),
                                  _info(Icons.access_time_rounded, c['criado_em']),
                                  const SizedBox(height: 10),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(c['descricao'],
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: c['status_chamado'],
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: Colors.grey.shade200),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: Colors.grey.shade200),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          items: _statusOpcoes.map((s) =>
                                            DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                                          onChanged: (novo) {
                                            if (novo != null) _atualizarStatus(c['id'], novo);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () => _remover(c['id'], c['nome']),
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                        tooltip: 'Remover',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}