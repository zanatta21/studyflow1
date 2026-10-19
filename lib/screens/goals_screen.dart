import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();

    return Scaffold(
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Nenhuma meta definida', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Toque no + para criar uma meta', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => data.loadAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: data.goals.length,
                    itemBuilder: (_, i) {
                      final g = data.goals[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    g.completed ? Icons.flag : Icons.flag_outlined,
                                    color: g.completed ? AppTheme.success : AppTheme.goal,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(g.title, style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'edit') _openForm(context, goal: g);
                                      if (v == 'delete') _delete(context, g);
                                      if (v == 'add') _addProgress(context, g);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'add', child: Text('Registrar progresso')),
                                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                      const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: AppTheme.danger))),
                                    ],
                                  ),
                                ],
                              ),
                              if (g.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(g.description, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                              const SizedBox(height: 12),
                              LinearPercentIndicator(
                                lineHeight: 12,
                                percent: g.progress,
                                backgroundColor: AppTheme.border,
                                progressColor: g.completed ? AppTheme.success : AppTheme.goal,
                                barRadius: const Radius.circular(6),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${g.currentValue} / ${g.targetValue} ${g.unit}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${(g.progress * 100).round()}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: g.completed ? AppTheme.success : AppTheme.goal,
                                    ),
                                  ),
                                ],
                              ),
                              if (g.deadline != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Prazo: ${DateFormat('dd/MM/yyyy').format(g.deadline!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
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

  void _openForm(BuildContext context, {GoalModel? goal}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _GoalForm(goal: goal)));
  }

  Future<void> _delete(BuildContext context, GoalModel g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir meta'),
        content: Text('Excluir "${g.title}"?'),
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
      await context.read<DataService>().deleteGoal(g.id);
    }
  }

  Future<void> _addProgress(BuildContext context, GoalModel g) async {
    final controller = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar progresso'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Valor a adicionar (${g.unit})'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (value != null && value > 0 && context.mounted) {
      await context.read<DataService>().updateGoal(
            g.copyWith(currentValue: g.currentValue + value),
          );
    }
  }
}

class _GoalForm extends StatefulWidget {
  final GoalModel? goal;
  const _GoalForm({this.goal});

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _target;
  String _unit = 'horas';
  DateTime? _deadline;
  bool get isEdit => widget.goal != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.goal?.title ?? '');
    _description = TextEditingController(text: widget.goal?.description ?? '');
    _target = TextEditingController(text: widget.goal?.targetValue.toString() ?? '');
    _unit = widget.goal?.unit ?? 'horas';
    _deadline = widget.goal?.deadline;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = context.read<DataService>();
    final uid = context.read<AuthService>().userId;
    final target = int.tryParse(_target.text) ?? 0;
    bool ok;
    if (isEdit) {
      ok = await data.updateGoal(widget.goal!.copyWith(
        title: _title.text,
        description: _description.text,
        targetValue: target,
        unit: _unit,
        deadline: _deadline,
      ));
    } else {
      ok = await data.createGoal(GoalModel(
        id: '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        targetValue: target,
        currentValue: 0,
        unit: _unit,
        deadline: _deadline,
        completed: false,
        userId: uid,
        createdAt: DateTime.now(),
      ));
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Meta atualizada!' : 'Meta criada!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar meta' : 'Nova meta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _title,
                label: 'Título da meta',
                hint: 'Ex: Estudar 20 horas este mês',
                prefixIcon: Icons.flag_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _description,
                label: 'Descrição',
                hint: 'Detalhes da meta',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _target,
                label: 'Valor da meta',
                hint: 'Ex: 20',
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: 'Unidade', prefixIcon: Icon(Icons.straighten)),
                items: const [
                  DropdownMenuItem(value: 'horas', child: Text('Horas')),
                  DropdownMenuItem(value: 'tarefas', child: Text('Tarefas')),
                  DropdownMenuItem(value: 'provas', child: Text('Provas')),
                  DropdownMenuItem(value: 'páginas', child: Text('Páginas')),
                ],
                onChanged: (v) => setState(() => _unit = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(_deadline == null ? 'Prazo (opcional)' : DateFormat('dd/MM/yyyy').format(_deadline!)),
                trailing: _deadline != null
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _deadline = null))
                    : null,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _deadline = d);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Salvar' : 'Criar meta')),
            ],
          ),
        ),
      ),
    );
  }
}
