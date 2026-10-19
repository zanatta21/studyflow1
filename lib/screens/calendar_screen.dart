import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../models/exam_model.dart';
import '../models/subject_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  Future<void> _adicionarAtividade() async {
    final data = context.read<DataService>();

    if (data.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre uma disciplina antes de adicionar uma atividade.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final localController = TextEditingController();

    String tipo = 'Tarefa';
    String prioridade = 'media';
    SubjectModel disciplina = data.subjects.first;
    DateTime dataAtividade = _selected;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova atividade'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: tipo,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de atividade',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Tarefa',
                              child: Text('Tarefa'),
                            ),
                            DropdownMenuItem(
                              value: 'Prova',
                              child: Text('Prova'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => tipo = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            hintText: 'Ex.: Trabalho de matemática',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<SubjectModel>(
                          value: disciplina,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Disciplina',
                          ),
                          items: data.subjects.map((subject) {
                            return DropdownMenuItem<SubjectModel>(
                              value: subject,
                              child: Text(
                                subject.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => disciplina = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descricaoController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição / observações',
                          ),
                          maxLines: 2,
                        ),
                        if (tipo == 'Tarefa') ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: prioridade,
                            decoration: const InputDecoration(
                              labelText: 'Prioridade',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'baixa',
                                child: Text('Baixa'),
                              ),
                              DropdownMenuItem(
                                value: 'media',
                                child: Text('Média'),
                              ),
                              DropdownMenuItem(
                                value: 'alta',
                                child: Text('Alta'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(
                                      () => prioridade = value,
                                );
                              }
                            },
                          ),
                        ],
                        if (tipo == 'Prova') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: localController,
                            decoration: const InputDecoration(
                              labelText: 'Local da prova (opcional)',
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            DateFormat(
                              'dd/MM/yyyy',
                              'pt_BR',
                            ).format(dataAtividade),
                          ),
                          onPressed: () async {
                            final escolhida = await showDatePicker(
                              context: context,
                              initialDate: dataAtividade,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              locale: const Locale('pt', 'BR'),
                            );

                            if (escolhida != null) {
                              setDialogState(() {
                                dataAtividade = escolhida;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final bool salvo;

                    if (tipo == 'Tarefa') {
                      salvo = await data.createTask(
                        TaskModel(
                          id: '',
                          title: tituloController.text.trim(),
                          description:
                          descricaoController.text.trim(),
                          subjectId: disciplina.id,
                          subjectName: disciplina.name,
                          dueDate: dataAtividade,
                          completed: false,
                          priority: prioridade,
                          userId: '',
                          createdAt: DateTime.now(),
                        ),
                      );
                    } else {
                      salvo = await data.createExam(
                        ExamModel(
                          id: '',
                          title: tituloController.text.trim(),
                          subjectId: disciplina.id,
                          subjectName: disciplina.name,
                          date: dataAtividade,
                          location: localController.text.trim(),
                          notes: descricaoController.text.trim(),
                          completed: false,
                          userId: '',
                          createdAt: DateTime.now(),
                        ),
                      );
                    }

                    if (!dialogContext.mounted) return;

                    if (salvo) {
                      Navigator.pop(dialogContext, true);
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            data.errorMessage ??
                                'Não foi possível salvar a atividade.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    tituloController.dispose();
    descricaoController.dispose();
    localController.dispose();

    if (resultado == true && mounted) {
      setState(() {
        _selected = dataAtividade;
        _focused = dataAtividade;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atividade salva com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataService>();
    final dayTasks = data.tasksForDate(_selected);
    final dayExams = data.examsForDate(_selected);

    return Column(
      children: [
        TableCalendar<dynamic>(
          locale: 'pt_BR',
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focused,
          selectedDayPredicate: (day) => isSameDay(day, _selected),
          calendarFormat: _format,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mês',
            CalendarFormat.twoWeeks: '2 semanas',
            CalendarFormat.week: 'Semana',
          },
          onFormatChanged: (format) {
            setState(() => _format = format);
          },
          onDaySelected: (selected, focused) {
            setState(() {
              _selected = selected;
              _focused = focused;
            });
          },
          onPageChanged: (focused) => _focused = focused,
          eventLoader: (day) => [
            ...data.tasksForDate(day),
            ...data.examsForDate(day),
          ],
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppTheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat(
                    "EEEE, dd 'de' MMMM 'de' yyyy",
                    'pt_BR',
                  ).format(_selected),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: _adicionarAtividade,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: dayTasks.isEmpty && dayExams.isEmpty
              ? Center(
            child: Text(
              'Nada agendado neste dia',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
              : ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            children: [
              ...dayExams.map(
                    (exam) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.quiz,
                        color: AppTheme.exam,
                      ),
                    ),
                    title: Text(exam.title),
                    subtitle: Text(
                      'Prova • ${exam.subjectName}'
                          '${exam.location.isNotEmpty ? '\n${exam.location}' : ''}'
                          '${exam.notes.isNotEmpty ? '\n${exam.notes}' : ''}',
                    ),
                    isThreeLine: exam.location.isNotEmpty ||
                        exam.notes.isNotEmpty,
                  ),
                ),
              ),
              ...dayTasks.map(
                    (task) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      AppTheme.task.withOpacity(0.15),
                      child: Icon(
                        task.completed
                            ? Icons.check_circle
                            : Icons.task_alt,
                        color: AppTheme.task,
                      ),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      'Tarefa • ${task.subjectName}'
                          '${task.description.isNotEmpty ? '\n${task.description}' : ''}',
                    ),
                    isThreeLine: task.description.isNotEmpty,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}