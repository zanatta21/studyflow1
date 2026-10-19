import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/exam_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();

    return Scaffold(
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Nenhuma prova cadastrada', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Toque no + para agendar', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => data.loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: data.exams.length,
                    itemBuilder: (_, i) {
                      final e = data.exams[i];
                      final isPast = e.date.isBefore(DateTime.now()) && !e.completed;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: (e.completed ? AppTheme.success : AppTheme.exam).withOpacity(0.15),
                            child: Icon(
                              e.completed ? Icons.check : Icons.quiz,
                              color: e.completed ? AppTheme.success : AppTheme.exam,
                            ),
                          ),
                          title: Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${e.subjectName} • ${DateFormat('dd/MM/yyyy').format(e.date)}'),
                              if (e.location.isNotEmpty) Text(e.location, style: Theme.of(context).textTheme.bodySmall),
                              if (e.grade != null)
                                Text('Nota: ${e.grade!.toStringAsFixed(1)}',
                                    style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13)),
                              if (isPast)
                                const Text('Atrasada', style: TextStyle(color: AppTheme.danger, fontSize: 12)),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _openForm(context, exam: e);
                              if (v == 'delete') _delete(context, e);
                              if (v == 'done') {
                                data.updateExam(e.copyWith(completed: true));
                              }
                            },
                            itemBuilder: (_) => [
                              if (!e.completed)
                                const PopupMenuItem(value: 'done', child: Text('Marcar como realizada')),
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

  void _openForm(BuildContext context, {ExamModel? exam}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ExamForm(exam: exam)));
  }

  Future<void> _delete(BuildContext context, ExamModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir prova'),
        content: Text('Excluir "${e.title}"?'),
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
      await context.read<DataService>().deleteExam(e.id);
    }
  }
}

class _ExamForm extends StatefulWidget {
  final ExamModel? exam;
  const _ExamForm({this.exam});

  @override
  State<_ExamForm> createState() => _ExamFormState();
}

class _ExamFormState extends State<_ExamForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late final TextEditingController _grade;
  String? _subjectId;
  String _subjectName = '';
  DateTime _date = DateTime.now();
  bool get isEdit => widget.exam != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.exam?.title ?? '');
    _location = TextEditingController(text: widget.exam?.location ?? '');
    _notes = TextEditingController(text: widget.exam?.notes ?? '');
    _grade = TextEditingController(text: widget.exam?.grade?.toString() ?? '');
    _subjectId = widget.exam?.subjectId;
    _subjectName = widget.exam?.subjectName ?? '';
    _date = widget.exam?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    _grade.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma disciplina'), backgroundColor: AppTheme.danger));
      return;
    }
    final data = context.read<DataService>();
    final uid = context.read<AuthService>().userId;
    final gradeVal = double.tryParse(_grade.text);
    bool ok;
    if (isEdit) {
      ok = await data.updateExam(widget.exam!.copyWith(
        title: _title.text,
        subjectId: _subjectId,
        subjectName: _subjectName,
        date: _date,
        location: _location.text,
        notes: _notes.text,
        grade: gradeVal,
      ));
    } else {
      ok = await data.createExam(ExamModel(
        id: '',
        title: _title.text.trim(),
        subjectId: _subjectId!,
        subjectName: _subjectName,
        date: _date,
        location: _location.text.trim(),
        notes: _notes.text.trim(),
        grade: gradeVal,
        completed: false,
        userId: uid,
        createdAt: DateTime.now(),
      ));
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Prova atualizada!' : 'Prova criada!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<DataService>().subjects;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar prova' : 'Nova prova')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _title,
                label: 'Título da prova',
                hint: 'Ex: Prova bimestral',
                prefixIcon: Icons.quiz_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _subjectId,
                decoration: const InputDecoration(labelText: 'Disciplina', prefixIcon: Icon(Icons.school_outlined)),
                items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) {
                  setState(() {
                    _subjectId = v;
                    _subjectName = subjects.firstWhere((s) => s.id == v).name;
                  });
                },
                validator: (v) => v == null ? 'Selecione a disciplina' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(DateFormat('dd/MM/yyyy').format(_date)),
                subtitle: const Text('Data da prova'),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _date = d);
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _location,
                label: 'Local',
                hint: 'Sala / local da prova',
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notes,
                label: 'Observações',
                hint: 'Conteúdo, materiais...',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _grade,
                label: 'Nota (opcional)',
                hint: 'Ex: 8.5',
                prefixIcon: Icons.grade_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Salvar' : 'Criar prova')),
            ],
          ),
        ),
      ),
    );
  }
}
