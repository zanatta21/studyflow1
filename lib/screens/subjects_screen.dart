import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();

    return Scaffold(
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Nenhuma disciplina', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Toque no + para adicionar', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => data.loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: data.subjects.length,
                    itemBuilder: (_, i) {
                      final s = data.subjects[i];
                      final color = Color(int.parse(s.color.replaceFirst('#', '0xFF')));
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(Icons.school, color: color),
                          ),
                          title: Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(
                            s.professor.isNotEmpty ? 'Prof. ${s.professor}' : s.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _openForm(context, subject: s);
                              if (v == 'delete') _confirmDelete(context, s);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Editar')),
                              const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: AppTheme.danger))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, {SubjectModel? subject}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _SubjectForm(subject: subject)));
  }

  Future<void> _confirmDelete(BuildContext context, SubjectModel s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir disciplina'),
        content: Text('Excluir "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<DataService>().deleteSubject(s.id);
    }
  }
}

class _SubjectForm extends StatefulWidget {
  final SubjectModel? subject;
  const _SubjectForm({this.subject});

  @override
  State<_SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<_SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _professor;
  late final TextEditingController _description;
  String _color = '#0F766E';
  bool get isEdit => widget.subject != null;

  static const _colors = ['#0F766E', '#2563EB', '#7C3AED', '#DC2626', '#F59E0B', '#10B981', '#EC4899'];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.subject?.name ?? '');
    _professor = TextEditingController(text: widget.subject?.professor ?? '');
    _description = TextEditingController(text: widget.subject?.description ?? '');
    _color = widget.subject?.color ?? '#0F766E';
  }

  @override
  void dispose() {
    _name.dispose();
    _professor.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = context.read<DataService>();
    final uid = context.read<AuthService>().userId;
    bool ok;
    if (isEdit) {
      ok = await data.updateSubject(widget.subject!.copyWith(
        name: _name.text,
        professor: _professor.text,
        description: _description.text,
        color: _color,
      ));
    } else {
      ok = await data.createSubject(SubjectModel(
        id: '',
        name: _name.text.trim(),
        professor: _professor.text.trim(),
        description: _description.text.trim(),
        color: _color,
        userId: uid,
        createdAt: DateTime.now(),
      ));
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Disciplina atualizada!' : 'Disciplina criada!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar disciplina' : 'Nova disciplina')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _name,
                label: 'Nome da disciplina',
                hint: 'Ex: Matemática',
                prefixIcon: Icons.book_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _professor,
                label: 'Professor(a)',
                hint: 'Nome do professor',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _description,
                label: 'Descrição',
                hint: 'Observações',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Cor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colors.map((c) {
                  final selected = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: AppTheme.textPrimary, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Salvar' : 'Criar disciplina')),
            ],
          ),
        ),
      ),
    );
  }
}
