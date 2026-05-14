import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/api_provider.dart';
import '../../core/theme/app_theme.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    super.key,
    required this.id,
    this.classId,
    this.moduleId,
    this.title,
  });

  final String id;
  final String? classId;
  final String? moduleId;
  final String? title;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  Map<String, dynamic>? _quiz;
  final Map<String, String> _answers = <String, String>{};
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quiz = await ref.read(apiClientProvider).get('/v1/students/me/quizzes/${widget.id}');
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    final quiz = _quiz;
    if (quiz == null || _submitting) return;

    final questions = (quiz['questions'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    if (_answers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reponds a toutes les questions avant de valider.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      final dio = ref.read(dioProvider);
      final maxScore = (quiz['max_score'] as num?)?.toInt() ?? questions.length;
      final moduleId = widget.moduleId ?? quiz['module_id']?.toString() ?? '';
      final classId = widget.classId ?? quiz['class_id']?.toString() ?? '';

      final attempt = await api.post(
        '/v1/students/me/quizzes/${widget.id}/attempts',
        body: {
          'module_id': moduleId,
          'class_id': classId,
          'max_score': maxScore,
          'max_attempts': 3,
        },
      );

      final attemptId = attempt['id']?.toString();
      if (attemptId == null || attemptId.isEmpty) {
        throw StateError('Attempt id manquant.');
      }

      await dio.put(
        '/v1/students/me/attempts/$attemptId/answers',
        data: {
          'answers': questions.map((question) {
            final questionId = question['id'].toString();
            return {
              'question_id': questionId,
              'selected_option_ids': [_answers[questionId]!],
            };
          }).toList(growable: false),
        },
      );

      final result = await api.post(
        '/v1/students/me/attempts/$attemptId/submit',
        body: {
          'pass_threshold_pct': quiz['pass_threshold_pct'],
          'time_spent_seconds': null,
          'evaluations': questions.map((question) {
            return {
              'question_id': question['id'],
              'correct_option_ids': question['correct_option_ids'],
              'points': question['points'],
            };
          }).toList(growable: false),
        },
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de soumettre le quiz: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;

    return Scaffold(
      backgroundColor: MiraTheme.warmBeige,
      appBar: AppBar(
        title: Text(widget.title ?? 'QCM'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: MiraTheme.miraRed))
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!),
                ))
              : _result != null
                  ? _QuizResultView(
                      quizTitle: quiz?['title']?.toString() ?? 'Quiz',
                      skillName: quiz?['skill_name']?.toString() ?? 'Skill',
                      score: (_result!['score'] as num?)?.toInt() ?? 0,
                      maxScore: (_result!['max_score'] as num?)?.toInt() ?? 0,
                      scorePct: _result!['score_pct']?.toString() ?? '0',
                      passed: (_result!['passed'] as bool?) ?? false,
                    )
                  : _QuizQuestionView(
                      quiz: quiz!,
                      answers: _answers,
                      submitting: _submitting,
                      onAnswerChanged: (questionId, optionId) {
                        setState(() => _answers[questionId] = optionId);
                      },
                      onSubmit: _submitQuiz,
                    ),
    );
  }
}

class _QuizQuestionView extends StatelessWidget {
  const _QuizQuestionView({
    required this.quiz,
    required this.answers,
    required this.submitting,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final Map<String, dynamic> quiz;
  final Map<String, String> answers;
  final bool submitting;
  final void Function(String questionId, String optionId) onAnswerChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final questions = (quiz['questions'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          quiz['title']?.toString() ?? 'Quiz',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${quiz['question_count']} questions • badge ${quiz['skill_name']}',
          style: const TextStyle(color: MiraTheme.muted),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < questions.length; i++) ...[
          _QuestionCard(
            index: i + 1,
            question: questions[i],
            selectedOptionId: answers[questions[i]['id'].toString()],
            onChanged: (optionId) => onAnswerChanged(questions[i]['id'].toString(), optionId),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: submitting ? null : onSubmit,
          child: Text(submitting ? 'Validation...' : 'Valider mon QCM'),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedOptionId,
    required this.onChanged,
  });

  final int index;
  final Map<String, dynamic> question;
  final String? selectedOptionId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = (question['options'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $index',
              style: const TextStyle(
                color: MiraTheme.miraRed,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question['prompt']?.toString() ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final option in options)
              RadioListTile<String>(
                value: option['id'].toString(),
                groupValue: selectedOptionId,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
                title: Text(option['label']?.toString() ?? ''),
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.quizTitle,
    required this.skillName,
    required this.score,
    required this.maxScore,
    required this.scorePct,
    required this.passed,
  });

  final String quizTitle;
  final String skillName;
  final int score;
  final int maxScore;
  final String scorePct;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed ? Icons.workspace_premium_rounded : Icons.flag_outlined,
                  size: 56,
                  color: passed ? MiraTheme.gold : MiraTheme.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  quizTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '$score / $maxScore • $scorePct%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MiraTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  passed
                      ? 'Bravo ! Skill "$skillName" validée.'
                      : 'Encore un effort pour valider la skill "$skillName".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: MiraTheme.muted, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
