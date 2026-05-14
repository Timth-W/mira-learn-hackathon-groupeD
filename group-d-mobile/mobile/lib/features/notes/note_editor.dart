import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_model.dart';
import 'notes_provider.dart';
import '../../core/theme/app_theme.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Note? note;
  final String? moduleId;
  final String? classId;
  const NoteEditor({super.key, this.note, this.moduleId, this.classId});

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  late TextEditingController _controller;
  late TextEditingController _conceptController;

  static const _defaultConcepts = <String>[
    'pitch',
    'storytelling',
    'objection',
    'seo',
    'growth',
    'feedback',
    'communication',
    'leadership',
    'general',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note?.content ?? '');
    _conceptController = TextEditingController(
      text: widget.note?.tags.isNotEmpty == true ? widget.note!.tags.first : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existingConcepts = ref
            .watch(notesProvider)
            .valueOrNull
            ?.expand((note) => note.tags)
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList() ??
        const <String>[];
    final concepts = {..._defaultConcepts, ...existingConcepts}.toList()
      ..sort();

    return Container(
      decoration: const BoxDecoration(
        color: MiraTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MiraTheme.rule,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.note == null ? 'Nouvelle note' : 'Modifier la note',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MiraTheme.charcoal,
              ),
            ),
            if (widget.moduleId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pour le Module ${widget.moduleId}',
                style: const TextStyle(color: MiraTheme.muted, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 7,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Que souhaites-tu retenir ?',
                hintStyle: const TextStyle(color: MiraTheme.muted),
                filled: true,
                fillColor: MiraTheme.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: MiraTheme.rule),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: MiraTheme.rule),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: MiraTheme.miraRed, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Concept',
              style: TextStyle(
                color: MiraTheme.charcoal,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _conceptController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Ex: pitch, seo, objection...',
                hintStyle: const TextStyle(color: MiraTheme.muted),
                filled: true,
                fillColor: MiraTheme.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: MiraTheme.rule),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: MiraTheme.rule),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: MiraTheme.miraRed, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final concept in concepts.take(10))
                  ActionChip(
                    label: Text('#$concept'),
                    backgroundColor: MiraTheme.beigeDeep,
                    side: const BorderSide(color: MiraTheme.mutedSoft),
                    onPressed: () {
                      setState(() => _conceptController.text = concept);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final content = _controller.text.trim();
                if (content.isEmpty) return;
                final concept = _conceptController.text.trim();

                if (widget.note == null) {
                  ref.read(notesProvider.notifier).addNote(
                        content,
                        moduleId: widget.moduleId,
                        classId: widget.classId,
                        concept: concept,
                      );
                } else {
                  ref.read(notesProvider.notifier).updateNote(
                        widget.note!.id,
                        content,
                        concept: concept,
                      );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Enregistrer la note'),
            ),
          ],
        ),
      ),
    );
  }
}
