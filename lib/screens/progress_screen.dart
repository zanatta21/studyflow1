import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final auth = context.watch<AuthService>();
    final name = auth.userName ?? 'Estudante';

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Olá, $name!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Visão geral dos seus estudos', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          // Resumo em cards
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.school, label: 'Disciplinas', value: '${data.subjects.length}', color: AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.task_alt, label: 'Tarefas', value: '${data.completedTasks}/${data.totalTasks}', color: AppTheme.task)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.quiz, label: 'Provas', value: '${data.completedExams}/${data.totalExams}', color: AppTheme.exam)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.flag, label: 'Metas', value: '${data.completedGoals}/${data.totalGoals}', color: AppTheme.goal)),
            ],
          ),
          const SizedBox(height: 28),

          Text('Progresso geral', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProgressRow(label: 'Provas Realizadas', percent: data.taskProgress, color: AppTheme.task),
                  const SizedBox(height: 16),
                  _ProgressRow(label: 'Tarefas Concluidas ', percent: data.examProgress, color: AppTheme.exam),
                  const SizedBox(height: 16),
                  _ProgressRow(label: 'Metas atingidas', percent: data.goalProgress, color: AppTheme.goal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Próximas provas
          Text('Próximas provas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (data.upcomingExams.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Nenhuma prova agendada', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              ),
            )
          else
            ...data.upcomingExams.take(3).map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.exam.withOpacity(0.15),
                      child: const Icon(Icons.quiz, color: AppTheme.exam, size: 20),
                    ),
                    title: Text(e.title),
                    subtitle: Text('${e.subjectName} • ${DateFormat('dd/MM/yyyy').format(e.date)}'),
                  ),
                )),
          const SizedBox(height: 28),

          // Tarefas pendentes
          Text('Tarefas pendentes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (data.pendingTasks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Nenhuma tarefa pendente 🎉', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              ),
            )
          else
            ...data.pendingTasks.take(5).map((t) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.task.withOpacity(0.15),
                      child: const Icon(Icons.task_alt, color: AppTheme.task, size: 20),
                    ),
                    title: Text(t.title),
                    subtitle: Text(t.subjectName + (t.dueDate != null ? ' • ${DateFormat('dd/MM').format(t.dueDate!)}' : '')),
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _ProgressRow({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${(percent * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 10,
          percent: percent,
          backgroundColor: AppTheme.border,
          progressColor: color,
          barRadius: const Radius.circular(5),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
