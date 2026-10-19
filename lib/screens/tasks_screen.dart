import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'todas';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final list = data.tasks.where((t) {
      if (_filter == 'pendentes') return !t.completed;
      if (_filter == 'concluidas') return t.completed;
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _Chip(label: 'Todas', selected: _filter == 'todas', onTap: () => setState(() => _filter = 'todas')),
                const SizedBox(width: 8),
                _Chip(label: 'Pendentes', selected: _filter == 'pendentes', onTap: () => setState(() => _filter = 'pendentes')),
                const SizedBox(width: 8),
                _Chip(label: 'Concluídas', selected: _filter == 'concluidas', onTap: () => setState(() => _filter = 'concluidas')),
              ],
            ),
          ),
          Expanded(
            child: data.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? Center(child: Text('Nenhuma tarefa', style: Theme.of(context).textTheme.bodyMedium))
                    : RefreshIndicator(
                        onRefresh: () => data.loadAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final t = list[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () => data.toggleTask(t),
                                  child: Icon(
                                    t.completed ? Icons.check_circle : Icons.circle_outlined,
                                    color: t.completed ? AppTheme.success : AppTheme.textSecondary,
                                  ),
                                ),
                                title: Text(
                                  t.title,
                                  style: TextStyle(
                                    decoration: t.completed ? TextDecoration.lineThrough : null,
                                    color: t.completed ? AppTheme.textSecondary : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${t.subjectName}${t.dueDate != null ? ' • ${DateFormat('dd/MM').format(t.dueDate!)}' : ''}'
                                  ' • ${_priorityLabel(t.priority)}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _openForm(context, task: t);
                                    if (v == 'delete') _delete(context, t);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'alta':
        return 'Alta';
      case 'baixa':
        return 'Baixa';
      default:
        return 'Média';
    }
  }

  void _openForm(BuildContext context, {TaskModel? task}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _TaskForm(task: task)));
  }

  Future<void> _delete(BuildContext context, TaskModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Excluir "${t.title}"?'),
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
      await context.read<DataService>().deleteTask(t.id);
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

class _TaskForm extends StatefulWidget {
  final TaskModel? task;
  const _TaskForm({this.task});

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String? _subjectId;
  String _subjectName = '';
  String _priority = 'media';
  DateTime? _dueDate;
  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description = TextEditingController(text: widget.task?.description ?? '');
    _subjectId = widget.task?.subjectId;
    _subjectName = widget.task?.subjectName ?? '';
    _priority = widget.task?.priority ?? 'media';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
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
    bool ok;
    if (isEdit) {
      ok = await data.updateTask(widget.task!.copyWith(
        title: _title.text,
        description: _description.text,
        subjectId: _subjectId,
        subjectName: _subjectName,
        priority: _priority,
        dueDate: _dueDate,
      ));
    } else {
      ok = await data.createTask(TaskModel(
        id: '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        subjectId: _subjectId!,
        subjectName: _subjectName,
        dueDate: _dueDate,
        completed: false,
        priority: _priority,
        userId: uid,
        createdAt: DateTime.now(),
      ));
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Tarefa atualizada!' : 'Tarefa criada!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<DataService>().subjects;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar tarefa' : 'Nova tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _title,
                label: 'Título',
                hint: 'Ex: Resolver exercícios',
                prefixIcon: Icons.title,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _description,
                label: 'Descrição',
                hint: 'Detalhes (opcional)',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
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
                title: Text(_dueDate == null ? 'Data de entrega (opcional)' : DateFormat('dd/MM/yyyy').format(_dueDate!)),
                trailing: _dueDate != null
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueDate = null))
                    : null,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _dueDate = d);
                },
              ),
              const SizedBox(height: 12),
              Text('Prioridade', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PrioChip(label: 'Baixa', value: 'baixa', selected: _priority == 'baixa', color: AppTheme.success, onTap: () => setState(() => _priority = 'baixa')),
                  const SizedBox(width: 8),
                  _PrioChip(label: 'Média', value: 'media', selected: _priority == 'media', color: AppTheme.warning, onTap: () => setState(() => _priority = 'media')),
                  const SizedBox(width: 8),
                  _PrioChip(label: 'Alta', value: 'alta', selected: _priority == 'alta', color: AppTheme.danger, onTap: () => setState(() => _priority = 'alta')),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Salvar' : 'Criar tarefa')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrioChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PrioChip({required this.label, required this.value, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : AppTheme.border, width: selected ? 2 : 1),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? color : AppTheme.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
        ),
      ),
    );
  }
}
